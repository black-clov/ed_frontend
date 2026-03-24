import '../../../services/api_service.dart';
import '../models/needs_model.dart';

class NeedsService {
  final ApiService _api = ApiService();

  List<NeedsOption> getLocalOptions() {
    return const [
      NeedsOption(key: 'learning', label: 'التعلم والتكوين', icon: '📚'),
      NeedsOption(key: 'training', label: 'تدريب مهني', icon: '🏋️'),
      NeedsOption(key: 'confidence', label: 'الثقة بالنفس', icon: '💪'),
      NeedsOption(key: 'cv', label: 'المساعدة في الـ CV', icon: '📄'),
      NeedsOption(key: 'jobs', label: 'البحث عن عمل', icon: '💼'),
      NeedsOption(key: 'networking', label: 'بناء شبكة علاقات', icon: '🤝'),
      NeedsOption(key: 'languages', label: 'تعلم اللغات', icon: '🌍'),
      NeedsOption(key: 'digital', label: 'المهارات الرقمية', icon: '💻'),
      NeedsOption(key: 'entrepreneurship', label: 'ريادة الأعمال', icon: '🚀'),
    ];
  }

  Future<List<NeedsOption>> fetchOptions() async {
    try {
      final resp = await _api.get('/needs/options');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => NeedsOption.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalOptions();
  }

  Future<bool> submitNeeds({String? userId, required List<String> needs}) async {
    try {
      await _api.post('/needs', data: {'userId': userId ?? 'anonymous', 'needs': needs});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getUserNeeds(String? userId) async {
    try {
      final resp = await _api.get('/needs/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is List) return data.cast<String>();
    } catch (_) {}
    return [];
  }
}
