import 'dart:convert';
import 'package:http/http.dart' as http;

/// AI Service for OpenAI integration
/// Handles communication with OpenAI API for expert model interactions
class AIService {
  // API configuration
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  // This should be loaded from secure storage or environment
  String? _apiKey;
  
  AIService({String? apiKey}) : _apiKey = apiKey;
  
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }
  
  /// Send a chat message and get AI response
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set. Please configure your OpenAI API key.');
    }
    
    final messages = <Map<String, String>>[];
    
    // Add system prompt for monitoring system context
    messages.add({
      'role': 'system',
      'content': 'You are an expert AI assistant for an industrial monitoring system. '
          'You help with device monitoring, alarm analysis, work order suggestions, '
          'and predictive maintenance. Provide concise, actionable insights.'
    });
    
    // Add conversation history if provided
    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }
    
    // Add current message
    messages.add({
      'role': 'user',
      'content': message,
    });
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with AI: $e');
    }
  }
  
  /// Get work order suggestions based on alarm data
  Future<String> getWorkOrderSuggestion({
    required String deviceName,
    required String alarmType,
    required String componentName,
    String? additionalContext,
  }) async {
    final prompt = '''
Based on the following alarm information, suggest appropriate work order actions:

Device: $deviceName
Component: $componentName
Alarm Type: $alarmType
${additionalContext != null ? 'Additional Context: $additionalContext' : ''}

Please provide:
1. Recommended immediate actions
2. Required parts or materials
3. Estimated time for completion
4. Priority level
''';
    
    return await sendMessage(prompt);
  }
  
  /// Analyze alarm and provide insights
  Future<String> analyzeAlarm({
    required String alarmType,
    required String deviceName,
    required String componentName,
    required double currentValue,
    required double threshold,
    String? historicalData,
  }) async {
    final prompt = '''
Analyze this alarm condition:

Alarm Type: $alarmType
Device: $deviceName
Component: $componentName
Current Value: $currentValue
Threshold: $threshold
${historicalData != null ? 'Historical Data: $historicalData' : ''}

Please provide:
1. Root cause analysis
2. Potential risks if not addressed
3. Recommended actions
4. Prevention measures for future
''';
    
    return await sendMessage(prompt);
  }
  
  /// Get predictive maintenance suggestions
  Future<String> getPredictiveMaintenance({
    required String deviceName,
    required Map<String, dynamic> deviceMetrics,
  }) async {
    final metricsStr = deviceMetrics.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    
    final prompt = '''
Based on the following device metrics, provide predictive maintenance recommendations:

Device: $deviceName
Current Metrics:
$metricsStr

Please provide:
1. Components requiring attention
2. Estimated remaining useful life
3. Recommended maintenance schedule
4. Risk assessment
''';
    
    return await sendMessage(prompt);
  }
}
