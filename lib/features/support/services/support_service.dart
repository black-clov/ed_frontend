import '../../../services/api_service.dart';
import '../models/support_model.dart';

class SupportService {
  final ApiService _api = ApiService();

  List<SupportCategory> getLocalOptions() {
    return const [
      SupportCategory(
        category: 'incubator',
        label: 'الحاضنة',
        icon: '🏢',
        description: 'مكان يوفر ليك مكتب ومرافقة ودعم لوجيستيكي',
        choices: [
          SupportChoice(key: 'incubator_physical', label: 'حاضنة فمكان فيزيكي'),
          SupportChoice(key: 'incubator_virtual', label: 'حاضنة عن بعد (أونلاين)'),
          SupportChoice(key: 'incubator_none', label: 'ما محتاجش حاضنة'),
        ],
      ),
      SupportCategory(
        category: 'mentor_type',
        label: 'نوع المرشد',
        icon: '🧑‍🏫',
        description: 'شكون بغيتي يوجهك فالمشوار ديالك',
        choices: [
          SupportChoice(key: 'mentor_entrepreneur', label: 'مقاول ناجح'),
          SupportChoice(key: 'mentor_expert', label: 'خبير فالمجال ديالي'),
          SupportChoice(key: 'mentor_coach', label: 'كوتش تنمية ذاتية'),
          SupportChoice(key: 'mentor_peer', label: 'شاب مقاول بحالي'),
        ],
      ),
      SupportCategory(
        category: 'training_type',
        label: 'نوع التكوين',
        icon: '📖',
        description: 'شنو نوع التكوين اللي كيناسبك',
        choices: [
          SupportChoice(key: 'training_online', label: 'تكوين أونلاين (فيديوهات)'),
          SupportChoice(key: 'training_workshop', label: 'ورشات عمل حضورية'),
          SupportChoice(key: 'training_bootcamp', label: 'بوتكامب مكثف'),
          SupportChoice(key: 'training_one_on_one', label: 'تكوين فردي مخصص'),
        ],
      ),
      SupportCategory(
        category: 'funding_stage',
        label: 'مرحلة التمويل',
        icon: '💰',
        description: 'فين وصلتي فمسار التمويل',
        choices: [
          SupportChoice(key: 'funding_idea', label: 'عندي غير الفكرة'),
          SupportChoice(key: 'funding_seeking', label: 'كنقلب على تمويل'),
          SupportChoice(key: 'funding_applied', label: 'قدمت طلب تمويل'),
          SupportChoice(key: 'funding_self', label: 'غادي نمول راسي'),
          SupportChoice(key: 'funding_partner', label: 'كنقلب على شريك مالي'),
        ],
      ),
    ];
  }

  Future<List<SupportCategory>> fetchOptions() async {
    try {
      final resp = await _api.get('/support/options');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => SupportCategory.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalOptions();
  }

  Future<bool> submit({
    String? userId,
    required List<String> preferences,
    Map<String, String>? details,
  }) async {
    try {
      await _api.post('/support', data: {
        'userId': userId ?? 'anonymous',
        'preferences': preferences,
        if (details != null) 'details': details,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserData(String? userId) async {
    try {
      final resp = await _api.get('/support/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'preferences': [], 'details': null};
  }
}
