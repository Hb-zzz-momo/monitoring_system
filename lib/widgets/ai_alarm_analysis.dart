import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chat_provider.dart';

/// Widget for AI-powered alarm analysis
class AIAlarmAnalysis extends StatefulWidget {
  final String alarmType;
  final String deviceName;
  final String componentName;
  final double currentValue;
  final double threshold;
  final String? historicalData;

  const AIAlarmAnalysis({
    super.key,
    required this.alarmType,
    required this.deviceName,
    required this.componentName,
    required this.currentValue,
    required this.threshold,
    this.historicalData,
  });

  @override
  State<AIAlarmAnalysis> createState() => _AIAlarmAnalysisState();
}

class _AIAlarmAnalysisState extends State<AIAlarmAnalysis> {
  String? _analysis;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(39, 99, 255, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color.fromRGBO(39, 99, 255, 1),
              ),
            ),
            title: const Text(
              'AI 告警分析',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: _analysis == null && !_isLoading
                ? const Text('点击获取 AI 分析')
                : null,
            trailing: _analysis == null && !_isLoading
                ? ElevatedButton.icon(
                    onPressed: _getAnalysis,
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('分析'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                      foregroundColor: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'AI 正在分析告警...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          if (_analysis != null && _isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue[200]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'AI 分析结果',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _analysis!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _getAnalysis,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新分析'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _createWorkOrder,
                        icon: const Icon(Icons.assignment),
                        label: const Text('创建工单'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getAnalysis() async {
    setState(() {
      _isLoading = true;
      _isExpanded = true;
    });

    try {
      final provider = Provider.of<AIChatProvider>(context, listen: false);
      
      if (!provider.isConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('请先在 AI 助手页面配置 API Key'),
              action: SnackBarAction(
                label: '去配置',
                onPressed: null, // Would navigate to AI settings
              ),
            ),
          );
        }
        return;
      }

      final analysis = await provider.analyzeAlarm(
        alarmType: widget.alarmType,
        deviceName: widget.deviceName,
        componentName: widget.componentName,
        currentValue: widget.currentValue,
        threshold: widget.threshold,
        historicalData: widget.historicalData,
      );

      if (mounted) {
        setState(() {
          _analysis = analysis;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分析失败: $e')),
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

  void _createWorkOrder() {
    // This would navigate to work order creation with AI analysis context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('基于 AI 分析创建工单'),
      ),
    );
  }
}
