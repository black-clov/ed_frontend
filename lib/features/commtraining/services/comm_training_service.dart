import '../../../services/api_service.dart';
import '../models/comm_module_model.dart';

class CommTrainingService {
  final ApiService _api = ApiService();

  List<CommModule> getLocalModules() {
    return const [
      CommModule(key: 'customer_talk', label: 'التواصل مع الزبون', icon: '🗣️', description: 'كيفاش تهضر مع الزبون بطريقة مهنية ومقنعة', tips: ['سمع مزيان قبل ما تهضر', 'استعمل أسئلة مفتوحة باش تفهم الاحتياج', 'كن واضح ومباشر فالشرح', 'بيّن القيمة اللي غادي يستافد منها الزبون']),
      CommModule(key: 'negotiation', label: 'التفاوض', icon: '🤝', description: 'مهارات التفاوض على الأثمنة والشروط', tips: ['حضر مزيان قبل أي تفاوض', 'عرف الحد الأدنى ديالك والحد الأقصى', 'قلّب على حلول win-win', 'ما تبانش يائس أو متسرع']),
      CommModule(key: 'persuasion', label: 'الإقناع', icon: '💎', description: 'فن الإقناع وكيفاش تخلي الناس يثقو فيك', tips: ['استعمل قصص وأمثلة واقعية', 'بيّن الأرقام والنتائج الملموسة', 'كن صادق وشفاف', 'استعمل لغة الجسد بطريقة إيجابية']),
      CommModule(key: 'presentation', label: 'العرض والتقديم', icon: '🎤', description: 'كيفاش تقدم المشروع ديالك بطريقة احترافية', tips: ['ابدأ بقصة أو سؤال يجذب الانتباه', 'استعمل صور وأرقام وماشي غير كلام', 'تدرب بزاف قبل العرض', 'خلي العرض قصير ومركز']),
      CommModule(key: 'networking', label: 'بناء العلاقات', icon: '🌐', description: 'كيفاش تبني شبكة علاقات مهنية قوية', tips: ['حضر الأحداث والملتقيات المهنية', 'كن مستعد تعرف براسك ف30 ثانية', 'تابع الناس اللي تعرفتي عليهم', 'قدم قيمة قبل ما تطلب شي حاجة']),
      CommModule(key: 'conflict_resolution', label: 'حل النزاعات', icon: '⚖️', description: 'كيفاش تدير مع الخلافات بطريقة بناءة', tips: ['بقى هادئ وما تاخدش الأمور بشكل شخصي', 'سمع لكل الأطراف قبل ما تحكم', 'قلّب على أرضية مشتركة', 'ركز على الحل ماشي على المشكل']),
    ];
  }

  Future<List<CommModule>> fetchModules() async {
    try {
      final resp = await _api.get('/commtraining/modules');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => CommModule.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return getLocalModules();
  }

  Future<bool> submit({
    String? userId,
    required List<String> skills,
    Map<String, int>? ratings,
    List<String>? completedModules,
  }) async {
    try {
      await _api.post('/commtraining', data: {
        'userId': userId ?? 'anonymous',
        'skills': skills,
        if (ratings != null) 'ratings': ratings,
        if (completedModules != null) 'completedModules': completedModules,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserData(String? userId) async {
    try {
      final resp = await _api.get('/commtraining/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'skills': [], 'ratings': null, 'completedModules': null};
  }
}
