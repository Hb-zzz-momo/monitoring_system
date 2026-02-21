import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL for the backend API server.
/// • Local development : http://localhost:8000
/// • Android emulator  : http://10.0.2.2:8000
/// • Physical device   : http://<your-machine-ip>:8000
/// Override this constant (or use Flutter --dart-define) when targeting
/// a staging / production server.
const String _kBaseUrl = 'http://localhost:8000';

/// Generic exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Low-level HTTP helper that adds common headers and error handling.
class ApiClient {
  final String baseUrl;
  String? _token;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? _kBaseUrl;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    String detail = response.body;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      detail = json['detail']?.toString() ?? detail;
    } catch (_) {}
    throw ApiException(response.statusCode, detail);
  }
}

/// Singleton API client instance shared across the app.
final ApiClient apiClient = ApiClient();

// ── Auth ──────────────────────────────────────────────────────────────────────

/// Login and store the token in [apiClient]. Returns user info.
Future<Map<String, dynamic>> login(String username, String password) async {
  final data = await apiClient.post('/auth/login', {
    'username': username,
    'password': password,
  }) as Map<String, dynamic>;
  apiClient.setToken(data['token'] as String);
  return data;
}

// ── Devices ───────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchDevices() async {
  final data = await apiClient.get('/devices') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> fetchDevice(String id) async {
  return await apiClient.get('/devices/$id') as Map<String, dynamic>;
}

Future<Map<String, dynamic>> updateDevice(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/devices/$id', fields) as Map<String, dynamic>;
}

// ── Alarms ────────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchAlarms() async {
  final data = await apiClient.get('/alarms') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> fetchAlarm(String id) async {
  return await apiClient.get('/alarms/$id') as Map<String, dynamic>;
}

Future<Map<String, dynamic>> updateAlarm(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/alarms/$id', fields) as Map<String, dynamic>;
}

// ── Work Orders ───────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchWorkOrders() async {
  final data = await apiClient.get('/work-orders') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> fetchWorkOrder(String id) async {
  return await apiClient.get('/work-orders/$id') as Map<String, dynamic>;
}

Future<Map<String, dynamic>> updateWorkOrder(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/work-orders/$id', fields)
      as Map<String, dynamic>;
}

// ── Metrics ───────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> fetchDeviceMetrics() async {
  return await apiClient.get('/metrics') as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> fetchRealtimeEvents() async {
  final data = await apiClient.get('/metrics/events') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> fetchHealthData() async {
  return await apiClient.get('/metrics/health') as Map<String, dynamic>;
}

// ── Components ────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchComponents() async {
  final data = await apiClient.get('/components') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> fetchComponent(String id) async {
  return await apiClient.get('/components/$id') as Map<String, dynamic>;
}
