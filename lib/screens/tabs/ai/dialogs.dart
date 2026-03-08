part of '../ai_tab.dart';

extension _AiDialogs on _AiTabState {
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
              _onServiceUpdate();
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
