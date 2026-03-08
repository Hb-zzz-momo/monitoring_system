import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../models/ai_models.dart';

class AiTab extends StatefulWidget {
  const AiTab({super.key});

  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AiService _aiService = AiService();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _aiService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    _apiKeyController.dispose();
    _scrollController.dispose();
    _aiService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
    // 自动滚到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 专家助手'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showConfigDialog,
            tooltip: 'API 设置',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subText,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: '智能对话'),
            Tab(icon: Icon(Icons.dataset), text: '训练数据'),
            Tab(icon: Icon(Icons.model_training), text: '模型训练'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildTrainingDataTab(),
          _buildTrainingJobTab(),
        ],
      ),
    );
  }

  // ===== 智能对话 Tab =====
  Widget _buildChatTab() {
    return Column(
      children: [
        // 对话列表
        Expanded(
          child: _aiService.messages.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _aiService.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_aiService.messages[index]);
                  },
                ),
        ),
        // 加载指示
        if (_aiService.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text('AI 思考中...', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
        // 快捷提问
        if (_aiService.messages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickAction('📊 设备温度分析', '当前设备温度情况如何？有没有过热风险？'),
                _buildQuickAction('🔔 告警处理建议', '当前有哪些告警需要处理？请给出建议。'),
                _buildQuickAction('🏥 健康评估', '请分析所有设备的健康状态和剩余寿命。'),
                _buildQuickAction('🤖 如何训练模型', '如何训练专家模型？请介绍训练流程。'),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // 输入栏
        _buildChatInput(),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'AI 专家助手',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Text(
            '基于设备监测数据，提供智能分析和建议',
            style: TextStyle(color: AppColors.subText, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _aiService.isConfigured ? '✅ 已连接 AI API' : '⚡ 演示模式（请配置 Base URL 和模型）',
            style: TextStyle(
              color: _aiService.isConfigured ? AppColors.success : AppColors.warning,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage message) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(message, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.info,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(AiMessage message, bool isUser) {
    if (isUser) {
      return SelectableText(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
        ),
      );
    }

    final lines = message.content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          return const SizedBox(height: 6);
        }

        final isHeading =
            trimmed.endsWith('分析') || trimmed.endsWith('建议') || trimmed.endsWith('结论');
        final isBullet = trimmed.startsWith('• ');
        final isNumbered = RegExp(r'^\d+\.').hasMatch(trimmed);

        if (isBullet || isNumbered) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBullet ? '• ' : '${trimmed.split('.').first}. ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    isBullet
                        ? trimmed.substring(2).trim()
                        : trimmed.replaceFirst(RegExp(r'^\d+\.'), '').trim(),
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: TextStyle(
              color: isHeading ? AppColors.primary : AppColors.text,
              fontSize: isHeading ? 15 : 14,
              fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAction(String label, String prompt) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => _aiService.sendMessage(prompt),
      backgroundColor: AppColors.card,
      side: BorderSide(color: AppColors.divider),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.subText,
              onPressed: () => _aiService.clearMessages(),
              tooltip: '清空对话',
            ),
            Expanded(
              child: TextField(
                controller: _chatController,
                decoration: InputDecoration(
                  hintText: '输入问题...',
                  hintStyle: TextStyle(color: AppColors.subText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: _handleSend,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: AppColors.primary),
              onPressed: () => _handleSend(_chatController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _aiService.isLoading) return;
    _chatController.clear();
    _aiService.sendMessage(trimmed);
  }

  // ===== 训练数据 Tab =====
  Widget _buildTrainingDataTab() {
    return Column(
      children: [
        // 操作栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '训练数据采集',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                '采集设备和告警数据，或手动添加问答对来训练专家模型',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _aiService.collectDeviceTrainingData(),
                      icon: const Icon(Icons.devices, size: 16),
                      label: const Text('采集设备数据', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _aiService.collectAlarmTrainingData(),
                      icon: const Icon(Icons.notifications, size: 16),
                      label: const Text('采集告警数据', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddTrainingDataDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('手动添加', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '共 ${_aiService.trainingData.length} 条样本',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const Spacer(),
              if (_aiService.trainingData.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    _tabController.animateTo(2); // 跳到训练 tab
                    _aiService.submitTrainingJob();
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('开始训练', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        const Divider(),
        // 训练数据列表
        Expanded(
          child: _aiService.trainingData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dataset, size: 48, color: AppColors.subText.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('暂无训练数据', style: TextStyle(color: AppColors.subText)),
                      const SizedBox(height: 4),
                      Text('点击上方按钮采集或手动添加', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _aiService.trainingData.length,
                  itemBuilder: (context, index) {
                    return _buildTrainingDataCard(_aiService.trainingData[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTrainingDataCard(TrainingDataItem item, int index) {
    final sourceIcon = {
      'device': Icons.devices,
      'alarm': Icons.notifications,
      'manual': Icons.edit,
    }[item.source] ?? Icons.data_object;
    final sourceLabel = {
      'device': '设备数据',
      'alarm': '告警数据',
      'manual': '手动添加',
    }[item.source] ?? item.source;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(sourceIcon, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(sourceLabel, style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                const Spacer(),
                InkWell(
                  onTap: () => _aiService.removeTrainingData(index),
                  child: Icon(Icons.close, size: 16, color: AppColors.subText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('输入:', style: TextStyle(fontSize: 11, color: AppColors.subText, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.input, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text('期望输出:', style: TextStyle(fontSize: 11, color: AppColors.subText, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.expectedOutput, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ===== 模型训练 Tab =====
  Widget _buildTrainingJobTab() {
    return _aiService.trainingJobs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.model_training, size: 48, color: AppColors.subText.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('暂无训练任务', style: TextStyle(color: AppColors.subText)),
                const SizedBox(height: 4),
                Text('采集训练数据后即可开始训练', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.dataset, size: 16),
                  label: const Text('去准备数据'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _aiService.trainingJobs.length,
            itemBuilder: (context, index) {
              return _buildTrainingJobCard(_aiService.trainingJobs[index]);
            },
          );
  }

  Widget _buildTrainingJobCard(TrainingJob job) {
    final statusColor = {
      'pending': AppColors.subText,
      'running': AppColors.info,
      'completed': AppColors.success,
      'failed': AppColors.danger,
    }[job.status] ?? AppColors.subText;
    final statusLabel = {
      'pending': '等待中',
      'running': '训练中',
      'completed': '已完成',
      'failed': '失败',
    }[job.status] ?? job.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.model_training, size: 20, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.modelName ?? job.id,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress,
                backgroundColor: AppColors.divider,
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${job.processedSamples} / ${job.totalSamples} 样本',
                  style: TextStyle(fontSize: 12, color: AppColors.subText),
                ),
                const Spacer(),
                Text(
                  '${(job.progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (job.status == 'completed' && job.modelName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      '模型 ${job.modelName} 训练完成，可用于推理',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===== 设置对话框 =====
  void _showConfigDialog() {
    _apiKeyController.text = _aiService.config.apiKey;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI API 配置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk-...',
                  helperText: '本地服务可留空（若服务要求鉴权请填写）',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Base URL',
                  hintText: _aiService.config.baseUrl,
                ),
                onChanged: (v) => _aiService.config.baseUrl = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _aiService.config.model,
                decoration: const InputDecoration(labelText: '模型'),
                items: const [
                  DropdownMenuItem(value: 'expert-local', child: Text('Expert Local (Trained)')),
                  DropdownMenuItem(value: 'gpt-4o-mini', child: Text('GPT-4o Mini')),
                  DropdownMenuItem(value: 'gpt-4o', child: Text('GPT-4o')),
                  DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
                  DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo')),
                ],
                onChanged: (v) {
                  if (v != null) _aiService.config.model = v;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _aiService.config.apiKey = _apiKeyController.text.trim();
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _aiService.isConfigured ? '✅ AI API 已配置' : '⚡ 已切换为演示模式',
                  ),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddTrainingDataDialog() {
    _inputController.clear();
    _outputController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加训练数据'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  labelText: '输入（用户问题）',
                  hintText: '例: 设备温度超过50度怎么办？',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _outputController,
                decoration: const InputDecoration(
                  labelText: '期望输出（专家回答）',
                  hintText: '例: 建议立即降低负载...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = _inputController.text.trim();
              final output = _outputController.text.trim();
              if (input.isNotEmpty && output.isNotEmpty) {
                _aiService.addTrainingData(input, output);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
