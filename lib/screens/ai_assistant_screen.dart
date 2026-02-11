import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chat_provider.dart';
import '../models/chat_message.dart';

/// AI Assistant screen for chatting with AI expert
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text;
    if (content.trim().isEmpty) return;

    final provider = Provider.of<AIChatProvider>(context, listen: false);
    provider.sendMessage(content);
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
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
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 8),
            Text('AI 专家助手'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Provider.of<AIChatProvider>(context, listen: false).clearMessages();
            },
            tooltip: '清除对话',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
            tooltip: '设置',
          ),
        ],
      ),
      body: Consumer<AIChatProvider>(
        builder: (context, provider, child) {
          if (!provider.isConfigured) {
            return _buildConfigureView(context, provider);
          }

          return Column(
            children: [
              // Quick action chips
              _buildQuickActions(context, provider),
              
              // Chat messages
              Expanded(
                child: provider.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(provider.messages),
              ),
              
              // Loading indicator
              if (provider.isLoading)
                const LinearProgressIndicator(),
              
              // Input area
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfigureView(BuildContext context, AIChatProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.smart_toy,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              '欢迎使用 AI 专家助手',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '请先配置 OpenAI API Key 以开始使用',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showSettingsDialog(context),
              icon: const Icon(Icons.settings),
              label: const Text('配置 API Key'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AIChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip(
              context,
              '工单建议',
              Icons.assignment,
              () => _sendQuickMessage('请给出工单建议'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              context,
              '告警分析',
              Icons.warning_amber,
              () => _sendQuickMessage('分析当前告警情况'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              context,
              '预测维护',
              Icons.build,
              () => _sendQuickMessage('预测设备维护需求'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              context,
              '设备诊断',
              Icons.device_hub,
              () => _sendQuickMessage('诊断设备状态'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  void _sendQuickMessage(String message) {
    final provider = Provider.of<AIChatProvider>(context, listen: false);
    provider.sendMessage(message);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '开始与 AI 专家对话',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试点击上方的快捷操作或输入您的问题',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color.fromRGBO(39, 99, 255, 1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI 助手',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: message.isUser
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                  ),
                ),
                if (message.status == MessageStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.red[300],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入您的问题...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<AIChatProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
                color: const Color.fromRGBO(39, 99, 255, 1),
                disabledColor: Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final TextEditingController apiKeyController = TextEditingController();
    final provider = Provider.of<AIChatProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置 OpenAI API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请输入您的 OpenAI API Key:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Text(
              '注意: API Key 将存储在本地',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (apiKeyController.text.trim().isNotEmpty) {
                provider.setApiKey(apiKeyController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key 已配置')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
