import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

/// Provider for managing AI chat state
class AIChatProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _apiKey;
  
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  
  /// Configure API key
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    _aiService.setApiKey(apiKey);
    notifyListeners();
  }
  
  /// Send a message to AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    notifyListeners();
    
    // Show loading
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get conversation history for context
      final conversationHistory = _messages.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      }).toList();
      
      // Get AI response
      final response = await _aiService.sendMessage(
        content,
        conversationHistory: conversationHistory.length > 10 
            ? conversationHistory.sublist(conversationHistory.length - 10)
            : conversationHistory,
      );
      
      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(aiMessage);
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
      
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear chat history
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
  
  /// Get work order suggestion
  Future<String?> getWorkOrderSuggestion({
    required String deviceName,
    required String alarmType,
    required String componentName,
    String? additionalContext,
  }) async {
    if (!isConfigured) return null;
    
    try {
      return await _aiService.getWorkOrderSuggestion(
        deviceName: deviceName,
        alarmType: alarmType,
        componentName: componentName,
        additionalContext: additionalContext,
      );
    } catch (e) {
      return 'Error getting suggestion: $e';
    }
  }
  
  /// Analyze alarm
  Future<String?> analyzeAlarm({
    required String alarmType,
    required String deviceName,
    required String componentName,
    required double currentValue,
    required double threshold,
    String? historicalData,
  }) async {
    if (!isConfigured) return null;
    
    try {
      return await _aiService.analyzeAlarm(
        alarmType: alarmType,
        deviceName: deviceName,
        componentName: componentName,
        currentValue: currentValue,
        threshold: threshold,
        historicalData: historicalData,
      );
    } catch (e) {
      return 'Error analyzing alarm: $e';
    }
  }
}
