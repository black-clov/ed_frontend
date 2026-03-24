import '../../../services/api_service.dart';
import '../models/ent_barrier_model.dart';

class EntBarriersService {
  final ApiService _api = ApiService();

  List<EntBarrierOption> getLocalOptions() {
    return const [
      EntBarrierOption(key: 'unclear_idea', label: 'فكرة غير واضحة', icon: '🌫️', description: 'ما عنديش فكرة واضحة على المشروع اللي بغيت نديرو'),
      EntBarrierOption(key: 'fear_of_failure', label: 'الخوف من الفشل', icon: '😰', description: 'كنخاف المشروع ما ينجحش ونخسر فلوسي'),
      EntBarrierOption(key: 'lack_of_funding', label: 'نقص التمويل', icon: '💸', description: 'ما عنديش الميزانية الكافية باش نبدأ'),
      EntBarrierOption(key: 'unknown_procedures', label: 'ما كنعرفش الإجراءات', icon: '📋', description: 'ما فاهمش الخطوات القانونية والإدارية'),
      EntBarrierOption(key: 'no_network', label: 'ما عنديش شبكة علاقات', icon: '🔗', description: 'ما عنديش اتصالات أو ناس يساعدوني'),
      EntBarrierOption(key: 'lack_of_skills', label: 'نقص المهارات', icon: '📚', description: 'حاس بلي ناقصني تكوين فبعض المجالات'),
      EntBarrierOption(key: 'market_competition', label: 'المنافسة فالسوق', icon: '⚔️', description: 'السوق فيه بزاف ديال المنافسة'),
      EntBarrierOption(key: 'family_pressure', label: 'ضغط العائلة', icon: '👨‍👩‍👧', description: 'العائلة ما كتشجعنيش أو كتضغط عليا'),
      EntBarrierOption(key: 'time_constraints', label: 'ما عنديش الوقت', icon: '⏰', description: 'عندي التزامات أخرى كتاخد الوقت ديالي'),
      EntBarrierOption(key: 'lack_of_confidence', label: 'قلة الثقة فالنفس', icon: '🪞', description: 'ما كنحسش بلي قادر نجح فريادة الأعمال'),
    ];
  }

  Future<List<EntBarrierOption>> fetchOptions() async {
    try {
      final resp = await _api.get('/entbarriers/options');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => EntBarrierOption.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalOptions();
  }

  Future<bool> submit({
    String? userId,
    required List<String> barriers,
    String? notes,
  }) async {
    try {
      await _api.post('/entbarriers', data: {
        'userId': userId ?? 'anonymous',
        'barriers': barriers,
        if (notes != null) 'notes': notes,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserData(String? userId) async {
    try {
      final resp = await _api.get('/entbarriers/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'barriers': [], 'notes': null};
  }
}
