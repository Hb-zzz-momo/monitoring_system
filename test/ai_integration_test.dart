import 'package:flutter_test/flutter_test.dart';
import 'package:monitoring_system/services/ai_config.dart';
import 'package:monitoring_system/models/chat_message.dart';

void main() {
  group('AI Configuration Tests', () {
    test('API key validation should work correctly', () {
      // Valid API keys
      expect(AIConfig.isValidApiKey('sk-' + 'a' * 40), true);
      expect(AIConfig.isValidApiKey('sk-1234567890abcdefghijklmnopqrstuvwxyzABCDEF'), true);
      
      // Invalid API keys
      expect(AIConfig.isValidApiKey('invalid-key'), false);
      expect(AIConfig.isValidApiKey('sk-short'), false);
      expect(AIConfig.isValidApiKey(''), false);
    });

    test('System prompts should be available for all contexts', () {
      expect(AIConfig.getSystemPrompt(AIContext.general).isNotEmpty, true);
      expect(AIConfig.getSystemPrompt(AIContext.alarmAnalysis).isNotEmpty, true);
      expect(AIConfig.getSystemPrompt(AIContext.workOrder).isNotEmpty, true);
      expect(AIConfig.getSystemPrompt(AIContext.predictiveMaintenance).isNotEmpty, true);
    });

    test('Default configuration values should be reasonable', () {
      expect(AIConfig.temperature >= 0.0 && AIConfig.temperature <= 1.0, true);
      expect(AIConfig.maxTokens > 0, true);
      expect(AIConfig.maxConversationHistory > 0, true);
    });
  });

  group('Chat Message Model Tests', () {
    test('ChatMessage should be created correctly', () {
      final message = ChatMessage(
        id: '1',
        content: 'Test message',
        isUser: true,
        timestamp: DateTime.now(),
      );

      expect(message.id, '1');
      expect(message.content, 'Test message');
      expect(message.isUser, true);
      expect(message.status, MessageStatus.sent);
    });

    test('ChatMessage copyWith should work correctly', () {
      final original = ChatMessage(
        id: '1',
        content: 'Original',
        isUser: true,
        timestamp: DateTime.now(),
      );

      final modified = original.copyWith(
        content: 'Modified',
        status: MessageStatus.error,
      );

      expect(modified.id, original.id);
      expect(modified.content, 'Modified');
      expect(modified.isUser, original.isUser);
      expect(modified.status, MessageStatus.error);
    });
  });

  group('AI Feature Integration Tests', () {
    test('Feature flags should be configurable', () {
      expect(AIConfig.enableWorkOrderSuggestions, isNotNull);
      expect(AIConfig.enableAlarmAnalysis, isNotNull);
      expect(AIConfig.enablePredictiveMaintenance, isNotNull);
      expect(AIConfig.enableChatHistory, isNotNull);
    });

    test('Model selection should have valid options', () {
      expect(AIConfig.defaultModel.isNotEmpty, true);
      expect(AIConfig.fastModel.isNotEmpty, true);
      expect(AIConfig.advancedModel.isNotEmpty, true);
      
      // Check that models are GPT models
      expect(AIConfig.defaultModel.contains('gpt'), true);
    });

    test('Timeout and retry settings should be reasonable', () {
      expect(AIConfig.requestTimeout.inSeconds > 0, true);
      expect(AIConfig.maxRetries >= 0, true);
    });
  });
}
