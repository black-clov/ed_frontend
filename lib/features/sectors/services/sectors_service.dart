import '../../../services/api_service.dart';
import '../models/sector_model.dart';

class SectorsService {
  final ApiService _api = ApiService();

  List<SectorOption> getLocalOptions() {
    return const [
      SectorOption(key: 'innovation', label: 'الابتكار والتكنولوجيا', icon: '💡'),
      SectorOption(key: 'sales', label: 'المبيعات والتجارة', icon: '🛒'),
      SectorOption(key: 'marketing', label: 'التسويق والإعلان', icon: '📢'),
      SectorOption(key: 'manual_services', label: 'الخدمات اليدوية والحرفية', icon: '🔧'),
      SectorOption(key: 'management', label: 'الإدارة والتنظيم', icon: '📊'),
      SectorOption(key: 'people', label: 'العمل مع الناس', icon: '🤝'),
    ];
  }

  Future<List<SectorOption>> fetchOptions() async {
    try {
      final resp = await _api.get('/sectors/options');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => SectorOption.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalOptions();
  }

  Future<bool> submitSectors({String? userId, required List<String> sectors}) async {
    try {
      await _api.post('/sectors', data: {'userId': userId ?? 'anonymous', 'sectors': sectors});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> getUserSectors(String? userId) async {
    try {
      final resp = await _api.get('/sectors/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is List) return data.cast<String>();
    } catch (_) {}
    return [];
  }
}
