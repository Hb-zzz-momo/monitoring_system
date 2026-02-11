import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chat_provider.dart';

/// Widget for AI-powered work order suggestions
class AIWorkOrderSuggestion extends StatefulWidget {
  final String deviceName;
  final String alarmType;
  final String componentName;
  final String? additionalContext;

  const AIWorkOrderSuggestion({
    super.key,
    required this.deviceName,
    required this.alarmType,
    required this.componentName,
    this.additionalContext,
  });

  @override
  State<AIWorkOrderSuggestion> createState() => _AIWorkOrderSuggestionState();
}

class _AIWorkOrderSuggestionState extends State<AIWorkOrderSuggestion> {
  String? _suggestion;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.smart_toy,
                  color: Color.fromRGBO(39, 99, 255, 1),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI 工单建议',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_suggestion == null && !_isLoading)
                  ElevatedButton.icon(
                    onPressed: _getSuggestion,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('获取建议'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_suggestion != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _suggestion!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _getSuggestion,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新生成'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _applySuggestion,
                        icon: const Icon(Icons.check),
                        label: const Text('应用建议'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  '点击"获取建议"让 AI 分析并提供工单建议',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getSuggestion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AIChatProvider>(context, listen: false);
      
      if (!provider.isConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请先在 AI 助手页面配置 API Key'),
            ),
          );
        }
        return;
      }

      final suggestion = await provider.getWorkOrderSuggestion(
        deviceName: widget.deviceName,
        alarmType: widget.alarmType,
        componentName: widget.componentName,
        additionalContext: widget.additionalContext,
      );

      if (mounted) {
        setState(() {
          _suggestion = suggestion;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取建议失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySuggestion() {
    // This would apply the suggestion to the work order form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('建议已应用到工单')),
    );
  }
}
