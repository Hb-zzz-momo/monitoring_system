import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'session_storage.dart';
import '../models/device_model.dart';
import '../models/alarm_model.dart';
import '../models/work_order_model.dart';
import '../models/metrics_model.dart';
import '../models/component_model.dart';
import '../models/realtime_event_model.dart';
import '../models/realtime_stream_payload_model.dart';

/// Base URL for the backend API server.
/// • Local development : http://localhost:8000
/// • Android emulator  : http://10.0.2.2:8000
/// • Physical device   : http://your-machine-ip:8000
/// Override this constant (or use Flutter --dart-define) when targeting
/// a staging / production server.
const String _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

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
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return await _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return await _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return await _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return await _handleResponse(response);
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    if (response.statusCode == 401 && (_token?.isNotEmpty ?? false)) {
      // Handle token expiration once in a centralized place.
      unawaited(handleUnauthorizedStatus());
    }

    String detail = response.body;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      detail = json['detail']?.toString() ?? detail;
    } catch (_) {}
    throw ApiException(response.statusCode, detail);
  }
}

String _buildMetricsWsUrl({String? deviceId}) {
  final uri = Uri.parse(_kBaseUrl);
  final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
  final params = <String, String>{};
  if (deviceId != null && deviceId.isNotEmpty) {
    params['device_id'] = deviceId;
  }
  if (apiClient.token != null && apiClient.token!.isNotEmpty) {
    params['token'] = apiClient.token!;
  }
  return Uri(
    scheme: scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: '/metrics/stream',
    queryParameters: params.isEmpty ? null : params,
  ).toString();
}

/// Singleton API client instance shared across the app.
final ApiClient apiClient = ApiClient();
Map<String, dynamic>? _currentUser;
Future<void> Function()? _onUnauthorized;
bool _isHandlingUnauthorized = false;

Map<String, dynamic>? get currentUser => _currentUser;

bool get isLoggedIn => apiClient.token != null && apiClient.token!.isNotEmpty;

String? get currentUsername => _currentUser?['username']?.toString();

void setUnauthorizedHandler(Future<void> Function()? handler) {
  _onUnauthorized = handler;
}

Map<String, dynamic>? _normalizeUser(dynamic value) {
  if (value is! Map) {
    return null;
  }
  return value.map((key, val) => MapEntry(key.toString(), val));
}

void _setCurrentUserFromAuthPayload(Map<String, dynamic> data) {
  _currentUser = {
    'username': data['username'],
    'role': data['role'],
    'displayName': data['displayName'] ?? data['display_name'],
    'email': data['email'],
    'phone': data['phone'],
  };
}

Future<void> _persistAuthSession() async {
  final token = apiClient.token;
  if (token == null || token.isEmpty) {
    await clearAuthSession();
    return;
  }

  await writeAuthSession({
    'token': token,
    'user': _currentUser,
  });
}

Future<void> restoreAuthSession() async {
  final session = await readAuthSession();
  if (session == null) {
    apiClient.clearToken();
    _currentUser = null;
    return;
  }

  final token = session['token']?.toString() ?? '';
  if (token.isEmpty) {
    apiClient.clearToken();
    _currentUser = null;
    await clearAuthSession();
    return;
  }

  apiClient.setToken(token);
  _currentUser = _normalizeUser(session['user']);
}

Future<void> logout() async {
  apiClient.clearToken();
  _currentUser = null;
  await clearAuthSession();
}

Future<void> handleUnauthorizedStatus() async {
  if (_isHandlingUnauthorized) {
    return;
  }

  _isHandlingUnauthorized = true;
  try {
    await logout();
    final handler = _onUnauthorized;
    if (handler != null) {
      await handler();
    }
  } finally {
    _isHandlingUnauthorized = false;
  }
}

// ── Auth ──────────────────────────────────────────────────────────────────────

/// Login and store the token in [apiClient]. Returns user info.
Future<Map<String, dynamic>> login(String username, String password) async {
  final data = await apiClient.post('/auth/login', {
    'username': username,
    'password': password,
  }) as Map<String, dynamic>;
  apiClient.setToken(data['token'] as String);
  _setCurrentUserFromAuthPayload(data);
  await _persistAuthSession();
  return data;
}

/// Register and store the token in [apiClient]. Returns user info.
Future<Map<String, dynamic>> register(
  String username,
  String password, {
  String? displayName,
  String? email,
  String? phone,
}) async {
  final payload = <String, dynamic>{
    'username': username,
    'password': password,
  };
  if (displayName != null && displayName.trim().isNotEmpty) {
    payload['displayName'] = displayName.trim();
  }
  if (email != null && email.trim().isNotEmpty) {
    payload['email'] = email.trim();
  }
  if (phone != null && phone.trim().isNotEmpty) {
    payload['phone'] = phone.trim();
  }

  final data = await apiClient.post('/auth/register', payload) as Map<String, dynamic>;
  apiClient.setToken(data['token'] as String);
  _setCurrentUserFromAuthPayload(data);
  await _persistAuthSession();
  return data;
}

// ── Devices ───────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchDevices() async {
  final data = await apiClient.get('/devices') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

/// Typed wrapper: returns [DeviceModel] list.
Future<List<DeviceModel>> fetchDeviceModels() async {
  final raw = await fetchDevices();
  return raw.map(DeviceModel.fromJson).toList();
}

Future<Map<String, dynamic>> fetchDevice(String id) async {
  return await apiClient.get('/devices/$id') as Map<String, dynamic>;
}

/// Typed wrapper: returns a single [DeviceModel].
Future<DeviceModel> fetchDeviceModel(String id) async {
  final raw = await fetchDevice(id);
  return DeviceModel.fromJson(raw);
}

Future<Map<String, dynamic>> updateDevice(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/devices/$id', fields) as Map<String, dynamic>;
}

// ── Alarms ────────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchAlarms({
  String? deviceId,
  String? deviceName,
}) async {
  final data = await apiClient.get('/alarms') as List<dynamic>;
  final alarms = data.cast<Map<String, dynamic>>();
  if ((deviceId == null || deviceId.isEmpty) &&
      (deviceName == null || deviceName.isEmpty)) {
    return alarms;
  }

  return alarms.where((alarm) {
    final device = alarm['device']?.toString() ?? '';
    if (device.isEmpty) {
      return true;
    }
    if (deviceId != null && deviceId.isNotEmpty && device == deviceId) {
      return true;
    }
    if (deviceName != null && deviceName.isNotEmpty && device == deviceName) {
      return true;
    }
    return false;
  }).toList();
}

/// Typed wrapper: returns [AlarmModel] list.
Future<List<AlarmModel>> fetchAlarmModels({
  String? deviceId,
  String? deviceName,
}) async {
  final raw = await fetchAlarms(deviceId: deviceId, deviceName: deviceName);
  return raw.map(AlarmModel.fromJson).toList();
}

Future<Map<String, dynamic>> fetchAlarm(String id) async {
  return await apiClient.get('/alarms/$id') as Map<String, dynamic>;
}

/// Typed wrapper: returns a single [AlarmModel].
Future<AlarmModel> fetchAlarmModel(String id) async {
  final raw = await fetchAlarm(id);
  return AlarmModel.fromJson(raw);
}

Future<Map<String, dynamic>> updateAlarm(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/alarms/$id', fields) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> createWorkOrderFromAlarm(String alarmId) async {
  return await apiClient.post('/alarms/$alarmId/work-order', const {})
      as Map<String, dynamic>;
}

// ── Work Orders ───────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchWorkOrders() async {
  final data = await apiClient.get('/work-orders') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

/// Typed wrapper: returns [WorkOrderModel] list.
Future<List<WorkOrderModel>> fetchWorkOrderModels() async {
  final raw = await fetchWorkOrders();
  return raw.map(WorkOrderModel.fromJson).toList();
}

Future<Map<String, dynamic>> fetchWorkOrder(String id) async {
  return await apiClient.get('/work-orders/$id') as Map<String, dynamic>;
}

/// Typed wrapper: returns a single [WorkOrderModel].
Future<WorkOrderModel> fetchWorkOrderModel(String id) async {
  final raw = await fetchWorkOrder(id);
  return WorkOrderModel.fromJson(raw);
}

Future<Map<String, dynamic>> updateWorkOrder(
    String id, Map<String, dynamic> fields) async {
  return await apiClient.put('/work-orders/$id', fields)
      as Map<String, dynamic>;
}

// ── Metrics ───────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> fetchDeviceMetrics({String? deviceId}) async {
  if (deviceId != null && deviceId.isNotEmpty) {
    final data =
        await apiClient.get('/metrics/devices/$deviceId') as Map<String, dynamic>;
    final metrics = data['metrics'];
    if (metrics is Map<String, dynamic>) {
      return metrics;
    }
  }
  return await apiClient.get('/metrics') as Map<String, dynamic>;
}

/// Typed wrapper: returns a [MetricsModel] for the given device.
Future<MetricsModel> fetchDeviceMetricsModel({String? deviceId}) async {
  final raw = await fetchDeviceMetrics(deviceId: deviceId);
  return MetricsModel.fromJson(raw);
}

Future<List<Map<String, dynamic>>> fetchRealtimeEvents({String? deviceId}) async {
  if (deviceId != null && deviceId.isNotEmpty) {
    final data = await apiClient.get('/metrics/devices/$deviceId/events')
        as Map<String, dynamic>;
    final events = data['events'];
    if (events is List<dynamic>) {
      return events.cast<Map<String, dynamic>>();
    }
  }
  final data = await apiClient.get('/metrics/events') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<List<RealtimeEventModel>> fetchRealtimeEventModels({String? deviceId}) async {
  final raw = await fetchRealtimeEvents(deviceId: deviceId);
  return raw.map(RealtimeEventModel.fromJson).toList();
}

class MetricsRealtimeConnection {
  final WebSocketChannel _channel;
  final Stream<RealtimeStreamPayloadModel> stream;

  MetricsRealtimeConnection(this._channel, this.stream);

  void close() {
    _channel.sink.close();
  }
}

MetricsRealtimeConnection connectMetricsStream({String? deviceId}) {
  final channel = WebSocketChannel.connect(
    Uri.parse(_buildMetricsWsUrl(deviceId: deviceId)),
  );

  final stream = channel.stream
      .map((event) {
        if (event is String) {
          return RealtimeStreamPayloadModel.fromJson(
            jsonDecode(event) as Map<String, dynamic>,
          );
        }
        if (event is List<int>) {
          return RealtimeStreamPayloadModel.fromJson(
            jsonDecode(utf8.decode(event)) as Map<String, dynamic>,
          );
        }
        return const RealtimeStreamPayloadModel();
      })
      .asBroadcastStream();

  return MetricsRealtimeConnection(channel, stream);
}

Future<Map<String, dynamic>> fetchHealthData() async {
  return await apiClient.get('/metrics/health') as Map<String, dynamic>;
}

Future<Map<String, dynamic>> fetchDeviceHealthData(String deviceId) async {
  final data =
      await apiClient.get('/metrics/devices/$deviceId/health') as Map<String, dynamic>;
  final health = data['health'];
  if (health is Map<String, dynamic>) {
    return health;
  }
  return await apiClient.get('/metrics/health') as Map<String, dynamic>;
}

/// Typed wrapper: returns a [HealthModel] for the given device.
Future<HealthModel> fetchDeviceHealthModel(String deviceId) async {
  final raw = await fetchDeviceHealthData(deviceId);
  return HealthModel.fromJson(raw);
}

Future<List<Map<String, double>>> fetchMetricHistory(
  String metric, {
  int points = 60,
  String? deviceId,
}) async {
  dynamic data;
  if (deviceId != null && deviceId.isNotEmpty) {
    data = await apiClient.get(
      '/metrics/devices/$deviceId/history?metric=$metric&points=$points',
    );
    if (data is Map<String, dynamic>) {
      data = data['points'];
    }
  } else {
    data = await apiClient.get('/metrics/history?metric=$metric&points=$points');
  }
  final listData = data as List<dynamic>;
  return listData
      .map((item) => {
            'x': (item['x'] as num).toDouble(),
            'y': (item['y'] as num).toDouble(),
          })
      .toList();
}

// ── Components ────────────────────────────────────────────────────────────────

Future<List<Map<String, dynamic>>> fetchComponents({
  String? deviceId,
  String? deviceName,
}) async {
  final data = await apiClient.get('/components') as List<dynamic>;
  final components = data.cast<Map<String, dynamic>>();
  if ((deviceId == null || deviceId.isEmpty) &&
      (deviceName == null || deviceName.isEmpty)) {
    return components;
  }

  final filtered = components.where((component) {
    final componentDeviceId = component['deviceId']?.toString() ??
        component['device_id']?.toString() ??
        '';
    final componentDeviceName = component['device']?.toString() ??
        component['deviceName']?.toString() ??
        component['device_name']?.toString() ??
        '';
    if (componentDeviceId.isEmpty && componentDeviceName.isEmpty) {
      return false;
    }
    if (deviceId != null && deviceId.isNotEmpty && componentDeviceId == deviceId) {
      return true;
    }
    if (deviceName != null && deviceName.isNotEmpty && componentDeviceName == deviceName) {
      return true;
    }
    return false;
  }).toList();

  // Fallback for old backends that don't return device fields on components.
  return filtered.isNotEmpty ? filtered : components;
}

Future<List<ComponentModel>> fetchComponentModels({
  String? deviceId,
  String? deviceName,
}) async {
  final raw = await fetchComponents(deviceId: deviceId, deviceName: deviceName);
  return raw.map(ComponentModel.fromJson).toList();
}

Future<Map<String, dynamic>> fetchComponent(String id) async {
  return await apiClient.get('/components/$id') as Map<String, dynamic>;
}

Future<ComponentModel> fetchComponentModel(String id) async {
  final raw = await fetchComponent(id);
  return ComponentModel.fromJson(raw);
}

// ── Sensors ───────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> ingestSensorData(Map<String, dynamic> payload) async {
  return await apiClient.post('/sensors/ingest', payload) as Map<String, dynamic>;
}

// ── AI Training ───────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> collectDeviceTrainingSamples() async {
  return await apiClient.post('/ai/training/samples/collect/device', const {})
      as Map<String, dynamic>;
}

Future<Map<String, dynamic>> collectAlarmTrainingSamples() async {
  return await apiClient.post('/ai/training/samples/collect/alarm', const {})
      as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> fetchTrainingSamples({int limit = 200}) async {
  final data = await apiClient.get('/ai/training/samples?limit=$limit') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<void> deleteTrainingSample(int sampleId) async {
  await apiClient.delete('/ai/training/samples/$sampleId');
}

Future<Map<String, dynamic>> createManualTrainingSample({
  required String input,
  required String expectedOutput,
}) async {
  return await apiClient.post('/ai/training/samples', {
    'input': input,
    'expectedOutput': expectedOutput,
    'source': 'manual',
  }) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> startLocalTrainingJob() async {
  return await apiClient.post('/ai/training/jobs/start', const {})
      as Map<String, dynamic>;
}

Future<List<Map<String, dynamic>>> fetchTrainingJobs({int limit = 20}) async {
  final data = await apiClient.get('/ai/training/jobs?limit=$limit') as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
}

Future<Map<String, dynamic>> getAiRecommendation(
  String deviceId, {
  bool createWorkOrder = false,
}) async {
  return await apiClient.post(
    '/ai/recommendations/devices/$deviceId?create_work_order=$createWorkOrder',
    const {},
  ) as Map<String, dynamic>;
}
