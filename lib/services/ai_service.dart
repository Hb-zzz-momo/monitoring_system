import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_models.dart';
import 'api_service.dart';

class AiService extends ChangeNotifier {
  final AiConfig config;
  final List<AiMessage> _messages = [];
  final List<TrainingDataItem> _trainingData = [];
  final List<TrainingJob> _trainingJobs = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _lastDevices = [];
  List<Map<String, dynamic>> _lastAlarms = [];

  AiService({AiConfig? config}) : config = config ?? AiConfig();

  List<AiMessage> get messages => List.unmodifiable(_messages);
  List<TrainingDataItem> get trainingData => List.unmodifiable(_trainingData);
  List<TrainingJob> get trainingJobs => List.unmodifiable(_trainingJobs);
  bool get isLoading => _isLoading;
  bool get isConfigured => config.baseUrl.trim().isNotEmpty && config.model.trim().isNotEmpty;

  // ===== 对话功能 =====

  /// 发送消息给 OpenAI 并获取回复
  Future<void> sendMessage(String content) async {
    _messages.add(AiMessage(role: 'user', content: content));
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureContextData();
      if (!isConfigured) {
        // 未配置 API Key 时使用模拟回复
        await Future.delayed(const Duration(milliseconds: 800));
        _messages.add(AiMessage(
          role: 'assistant',
          content: _toReadableContent(_getMockResponse(content)),
        ));
      } else {
        final response = await _callOpenAI(content);
        _messages.add(
          AiMessage(role: 'assistant', content: _toReadableContent(response)),
        );
      }
    } catch (e) {
      _messages.add(AiMessage(
        role: 'assistant',
        content: _toReadableContent('请求失败: $e\n\n请检查 API Key 和网络设置。'),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 调用 OpenAI API
  Future<String> _callOpenAI(String userMessage) async {
    final systemPrompt = await _buildSystemPrompt();

    final body = jsonEncode({
      'model': config.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ..._messages.map((m) => m.toJson()),
      ],
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    });

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final apiKey = config.apiKey.trim();
    if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    } else if (_isUsingBackendProxy() && (apiClient.token?.isNotEmpty ?? false)) {
      headers['Authorization'] = 'Bearer ${apiClient.token!}';
    }

    final response = await http.post(
      Uri.parse('${config.baseUrl}/chat/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      if (response.statusCode == 401 && _isUsingBackendProxy()) {
        await handleUnauthorizedStatus();
      }
      throw Exception('API 错误 ${response.statusCode}: ${response.body}');
    }
  }

  bool _isUsingBackendProxy() {
    final base = config.baseUrl.trim();
    if (base.isEmpty) return false;
    return base.startsWith('${apiClient.baseUrl}/v1');
  }

  /// 构建系统提示词（注入设备监测领域知识）
  Future<void> _ensureContextData() async {
    try {
      _lastDevices = await fetchDevices();
      _lastAlarms = await fetchAlarms();
    } catch (_) {}
  }

  Future<String> _buildSystemPrompt() async {
    if (_lastDevices.isEmpty) {
      await _ensureContextData();
    }

    final deviceSummary = _lastDevices
        .map((d) =>
            '${d['name']}: 在线=${d['isOnline']}, 温度=${d['temperature']}°C, '
            '功率=${d['power']}kW, 健康=${d['healthIndex']}')
        .join('\n');

    return '''你是一个设备监测系统的AI专家助手。你的职责：
1. 分析设备运行数据，提供健康评估和维护建议
2. 解读告警信息，给出处理方案
3. 预测设备故障，建议预防措施
4. 回答设备监测相关的技术问题

当前系统设备概览：
$deviceSummary

请用中文回复，保持专业但易懂。''';
  }

  /// 模拟回复（API Key 未配置时）
  String _getMockResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('温度') || lower.contains('过热')) {
      return '📊 **温度分析**\n\n'
          '当前系统中，测试设备-04 温度最高 (45.2°C)，接近告警阈值。\n\n'
          '**建议：**\n'
          '1. 检查散热风扇运行状态\n'
          '2. 清洁设备通风口\n'
          '3. 考虑降低负载或增加散热措施\n\n'
          '> 💡 持续高温可能导致设备寿命缩短约30%';
    }

    if (lower.contains('告警') || lower.contains('报警')) {
      return '🔔 **告警分析**\n\n'
          '当前系统有 ${_lastAlarms.length} 条告警记录。\n\n'
          '**优先处理建议：**\n'
          '1. 高危告警应在 1 小时内响应\n'
          '2. 中危告警建议 4 小时内处理\n'
          '3. 建议建立告警升级机制\n\n'
          '需要我详细分析某条告警吗？';
    }

    if (lower.contains('健康') || lower.contains('寿命') || lower.contains('rul')) {
      return '🏥 **设备健康报告**\n\n'
          '| 设备 | 健康指数 | 剩余寿命 | 状态 |\n'
          '|------|---------|---------|------|\n'
          '| 主控设备-01 | 72% | 180天 | ⚠️ 关注 |\n'
          '| 监测设备-02 | 85% | 320天 | ✅ 良好 |\n'
          '| 备用设备-03 | 95% | 500天 | ✅ 优秀 |\n'
          '| 测试设备-04 | 58% | 90天 | 🔴 预警 |\n\n'
          '**重点关注：** 测试设备-04 健康指数偏低，建议尽快安排维护。';
    }

    if (lower.contains('训练') || lower.contains('模型')) {
      return '🤖 **模型训练说明**\n\n'
          '您可以通过以下方式训练专家模型：\n\n'
          '1. **设备数据**：自动采集设备运行参数作为训练样本\n'
          '2. **告警记录**：将历史告警和处理方案转为训练数据\n'
          '3. **人工标注**：手动添加问答对来增强模型能力\n\n'
          '点击「训练数据」标签可以管理训练样本。';
    }

    return '🤖 **AI 助手**\n\n'
        '我是设备监测系统的 AI 专家助手，可以帮您：\n\n'
        '• 📊 分析设备运行数据和趋势\n'
        '• 🔔 解读告警信息并给出处理建议\n'
        '• 🏥 评估设备健康状态和剩余寿命\n'
        '• 🛠️ 提供维护计划建议\n'
        '• 🤖 训练专家模型\n\n'
        '试试问我：「当前设备温度情况如何？」';
  }

  String _toReadableContent(String raw) {
    var text = raw.trim().replaceAll('\r\n', '\n');

    // Remove common markdown control chars for plain-text UI rendering.
    text = text
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'^\s*>\s?', multiLine: true), (_) => '提示: ')
        .replaceAllMapped(RegExp(r'^\s*-\s+', multiLine: true), (_) => '• ')
        .replaceAll('### ', '')
        .replaceAll('## ', '')
        .replaceAll('# ', '');

    // Round very long decimals like 0.925999999999 to 0.926.
    text = text.replaceAllMapped(
      RegExp(r'(-?\d+\.\d{3})\d+'),
      (m) => m.group(1) ?? m.group(0) ?? '',
    );

    return text;
  }

  // ===== 训练数据管理 =====

  Future<void> _reloadTrainingSamples() async {
    final samples = await fetchTrainingSamples(limit: 500);
    _trainingData
      ..clear()
      ..addAll(
        samples.map(
          (item) => TrainingDataItem(
            id: (item['id'] as num?)?.toInt(),
            input: item['input']?.toString() ?? '',
            expectedOutput: item['expectedOutput']?.toString() ?? '',
            source: item['source']?.toString() ?? 'manual',
            createdAt: DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        ),
      );
  }

  Future<void> _reloadTrainingJobs() async {
    final jobs = await fetchTrainingJobs(limit: 20);
    _trainingJobs
      ..clear()
      ..addAll(
        jobs.map(
          (job) => TrainingJob(
            id: job['id']?.toString() ?? '',
            status: job['status']?.toString() ?? 'pending',
            totalSamples: (job['totalSamples'] as num?)?.toInt() ?? 0,
            processedSamples: (job['processedSamples'] as num?)?.toInt() ?? 0,
            modelName: job['modelName']?.toString(),
            createdAt: DateTime.tryParse(job['createdAt']?.toString() ?? '') ?? DateTime.now(),
          ),
        ),
      );
  }

  /// 从设备数据自动生成训练样本
  Future<void> collectDeviceTrainingData() async {
    try {
      await collectDeviceTrainingSamples();
      await _reloadTrainingSamples();
    } catch (_) {}
    notifyListeners();
  }

  /// 从告警数据生成训练样本
  Future<void> collectAlarmTrainingData() async {
    try {
      await collectAlarmTrainingSamples();
      await _reloadTrainingSamples();
    } catch (_) {}
    notifyListeners();
  }

  /// 手动添加训练数据
  Future<void> addTrainingData(String input, String expectedOutput) async {
    try {
      await createManualTrainingSample(input: input, expectedOutput: expectedOutput);
      await _reloadTrainingSamples();
    } catch (_) {}
    notifyListeners();
  }

  /// 删除训练数据
  Future<void> removeTrainingData(int index) async {
    if (index < 0 || index >= _trainingData.length) return;

    final sampleId = _trainingData[index].id ?? -1;
    if (sampleId <= 0) return;

    try {
      await deleteTrainingSample(sampleId);
      await _reloadTrainingSamples();
    } catch (_) {}
    notifyListeners();
  }

  /// 提交训练任务（模拟）
  Future<void> submitTrainingJob() async {
    if (_trainingData.isEmpty) {
      await _reloadTrainingSamples();
    }
    if (_trainingData.isEmpty) return;

    try {
      await startLocalTrainingJob();
      await _reloadTrainingJobs();
    } catch (_) {}
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
