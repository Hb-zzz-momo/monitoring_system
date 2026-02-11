import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ai_models.dart';
import '../mock_data/mock_data.dart';

class AiService extends ChangeNotifier {
  final AiConfig config;
  final List<AiMessage> _messages = [];
  final List<TrainingDataItem> _trainingData = [];
  final List<TrainingJob> _trainingJobs = [];
  bool _isLoading = false;

  AiService({AiConfig? config}) : config = config ?? AiConfig();

  List<AiMessage> get messages => List.unmodifiable(_messages);
  List<TrainingDataItem> get trainingData => List.unmodifiable(_trainingData);
  List<TrainingJob> get trainingJobs => List.unmodifiable(_trainingJobs);
  bool get isLoading => _isLoading;
  bool get isConfigured => config.apiKey.isNotEmpty;

  // ===== 对话功能 =====

  /// 发送消息给 OpenAI 并获取回复
  Future<void> sendMessage(String content) async {
    _messages.add(AiMessage(role: 'user', content: content));
    _isLoading = true;
    notifyListeners();

    try {
      if (!isConfigured) {
        // 未配置 API Key 时使用模拟回复
        await Future.delayed(const Duration(milliseconds: 800));
        _messages.add(AiMessage(
          role: 'assistant',
          content: _getMockResponse(content),
        ));
      } else {
        final response = await _callOpenAI(content);
        _messages.add(AiMessage(role: 'assistant', content: response));
      }
    } catch (e) {
      _messages.add(AiMessage(
        role: 'assistant',
        content: '请求失败: $e\n\n请检查 API Key 和网络设置。',
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 调用 OpenAI API
  Future<String> _callOpenAI(String userMessage) async {
    final systemPrompt = _buildSystemPrompt();

    final body = jsonEncode({
      'model': config.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ..._messages.map((m) => m.toJson()),
      ],
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    });

    final response = await http.post(
      Uri.parse('${config.baseUrl}/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API 错误 ${response.statusCode}: ${response.body}');
    }
  }

  /// 构建系统提示词（注入设备监测领域知识）
  String _buildSystemPrompt() {
    final deviceSummary = MockData.devices
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
          '当前系统有 ${MockData.alarms.length} 条告警记录。\n\n'
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

  // ===== 训练数据管理 =====

  /// 从设备数据自动生成训练样本
  void collectDeviceTrainingData() {
    for (final device in MockData.devices) {
      final input = '设备 ${device['name']} 温度 ${device['temperature']}°C，'
          '功率 ${device['power']}kW，健康指数 ${device['healthIndex']}，'
          '状态：${device['isOnline'] ? '在线' : '离线'}。请分析。';

      final health = device['healthIndex'] as double;
      String assessment;
      if (health >= 0.8) {
        assessment = '运行良好，各项指标正常，建议保持当前维护计划。';
      } else if (health >= 0.6) {
        assessment = '需要关注，建议增加巡检频率，预防性维护优先处理。';
      } else {
        assessment = '状态堪忧，建议尽快安排全面检修，排查潜在故障隐患。';
      }

      _trainingData.add(TrainingDataItem(
        input: input,
        expectedOutput: assessment,
        source: 'device',
      ));
    }
    notifyListeners();
  }

  /// 从告警数据生成训练样本
  void collectAlarmTrainingData() {
    for (final alarm in MockData.alarms) {
      _trainingData.add(TrainingDataItem(
        input: '告警：${alarm['title']}，级别：${alarm['level']}，'
            '设备：${alarm['device']}。如何处理？',
        expectedOutput: '针对${alarm['title']}，建议：\n'
            '1. 立即检查相关传感器读数\n'
            '2. 对比历史数据确认是否为误报\n'
            '3. 根据${alarm['level']}级别启动对应处置流程',
        source: 'alarm',
      ));
    }
    notifyListeners();
  }

  /// 手动添加训练数据
  void addTrainingData(String input, String expectedOutput) {
    _trainingData.add(TrainingDataItem(
      input: input,
      expectedOutput: expectedOutput,
      source: 'manual',
    ));
    notifyListeners();
  }

  /// 删除训练数据
  void removeTrainingData(int index) {
    if (index >= 0 && index < _trainingData.length) {
      _trainingData.removeAt(index);
      notifyListeners();
    }
  }

  /// 提交训练任务（模拟）
  Future<void> submitTrainingJob() async {
    if (_trainingData.isEmpty) return;

    final job = TrainingJob(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      status: 'running',
      totalSamples: _trainingData.length,
    );
    _trainingJobs.insert(0, job);
    notifyListeners();

    // 模拟训练进度
    for (int i = 1; i <= _trainingData.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      _trainingJobs[0] = TrainingJob(
        id: job.id,
        status: i == _trainingData.length ? 'completed' : 'running',
        totalSamples: _trainingData.length,
        processedSamples: i,
        modelName: i == _trainingData.length ? 'expert-model-v${_trainingJobs.length}' : null,
        createdAt: job.createdAt,
      );
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
