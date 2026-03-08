part of '../ai_tab.dart';

extension _AiChatTab on _AiTabState {
  Widget _buildChatTab() {
    return Column(
      children: [
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
}
