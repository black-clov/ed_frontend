import 'api_service.dart';

class AnalyticsService {
  final ApiService _api = ApiService();

  Future<void> track(String action, {String? target, Map<String, dynamic>? metadata}) async {
    try {
      await _api.post('/analytics/track', data: {
        'action': action,
        if (target != null) 'target': target,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (_) {
      // Fire-and-forget — don't block the UI on tracking failures
    }
  }
}
