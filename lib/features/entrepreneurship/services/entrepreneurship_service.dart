import '../../../services/api_service.dart';
import '../models/entrepreneurship_model.dart';

class EntrepreneurshipService {
  final ApiService _api = ApiService();

  List<EntrepreneurshipOption> getLocalOptions() {
    return const [
      EntrepreneurshipOption(key: 'project_idea', label: 'فكرة المشروع', icon: '💡', description: 'القدرة على تطوير فكرة مشروع واضحة ومبتكرة'),
      EntrepreneurshipOption(key: 'management', label: 'التدبير والتسيير', icon: '📊', description: 'مهارات إدارة الموارد والوقت والفريق'),
      EntrepreneurshipOption(key: 'legal_basics', label: 'الأساسيات القانونية', icon: '⚖️', description: 'معرفة الإجراءات القانونية لإنشاء مقاولة'),
      EntrepreneurshipOption(key: 'financing', label: 'التمويل', icon: '💰', description: 'كيفية البحث عن التمويل وتدبير الميزانية'),
      EntrepreneurshipOption(key: 'marketing', label: 'التسويق', icon: '📢', description: 'استراتيجيات الترويج والوصول للزبناء'),
      EntrepreneurshipOption(key: 'partnerships', label: 'الشراكات', icon: '🤝', description: 'بناء علاقات مهنية وشراكات استراتيجية'),
    ];
  }

  Future<List<EntrepreneurshipOption>> fetchOptions() async {
    try {
      final resp = await _api.get('/entrepreneurship/options');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => EntrepreneurshipOption.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalOptions();
  }

  Future<bool> submitSkills({
    String? userId,
    required List<String> skills,
    Map<String, int>? ratings,
  }) async {
    try {
      await _api.post('/entrepreneurship', data: {
        'userId': userId ?? 'anonymous',
        'skills': skills,
        if (ratings != null) 'ratings': ratings,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserData(String? userId) async {
    try {
      final resp = await _api.get('/entrepreneurship/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'skills': [], 'ratings': null};
  }
}
