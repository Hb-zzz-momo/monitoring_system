import 'metrics_model.dart';
import 'realtime_event_model.dart';

class RealtimeStreamPayloadModel {
  final MetricsModel? metrics;
  final List<RealtimeEventModel> events;
  final List<Map<String, double>> temperatureTrend;

  const RealtimeStreamPayloadModel({
    this.metrics,
    this.events = const [],
    this.temperatureTrend = const [],
  });

  factory RealtimeStreamPayloadModel.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['metrics'];
    final rawEvents = json['events'];
    final rawTrend = json['trend'];

    return RealtimeStreamPayloadModel(
      metrics: rawMetrics is Map<String, dynamic>
          ? MetricsModel.fromJson(rawMetrics)
          : null,
      events: rawEvents is List
          ? rawEvents
              .whereType<Map>()
              .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
              .map(RealtimeEventModel.fromJson)
              .toList()
          : const [],
      temperatureTrend: rawTrend is List
          ? rawTrend
              .whereType<Map>()
              .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
              .map((point) => {
                    'x': (point['x'] as num).toDouble(),
                    'y': (point['y'] as num).toDouble(),
                  })
              .toList()
          : const [],
    );
  }
}
