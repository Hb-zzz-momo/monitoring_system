import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../models/ai_models.dart';

part 'ai/chat_tab.dart';
part 'ai/training_data_tab.dart';
part 'ai/training_jobs_tab.dart';
part 'ai/dialogs.dart';

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
}
