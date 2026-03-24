import '../../../services/api_service.dart';

class PitchService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> generatePitch({
    String? userId,
    required String projectName,
    String? sector,
  }) async {
    try {
      final resp = await _api.post('/pitch/generate', data: {
        'userId': userId ?? 'anonymous',
        'projectName': projectName,
        if (sector != null) 'sector': sector,
      });
      if (resp.data is Map<String, dynamic>) return resp.data;
    } catch (_) {}
    // Local fallback
    return {
      'projectName': projectName,
      'sector': sector ?? 'general',
      'pitchText': 'كل يوم، فرص جديدة كتبان لللي عندو الشجاعة يبدأ.\n\n'
          'بزاف ديال المشاكل اليومية مازال ما لقاو حل مناسب.\n\n'
          '$projectName هو مشروع كيقدم حل عملي وبسيط لهاد المشاكل.\n\n'
          'اللي كيميزنا هو البساطة والقرب من الزبون.\n\n'
          'كنستهدفو المجتمع المحلي بجميع فئاته.\n\n'
          'ساعدنا نوصلو لأكبر عدد ديال الناس. شاركنا الرحلة.',
      'sections': {
        'hook': 'كل يوم، فرص جديدة كتبان لللي عندو الشجاعة يبدأ.',
        'problem': 'بزاف ديال المشاكل اليومية مازال ما لقاو حل مناسب.',
        'solution': '$projectName هو مشروع كيقدم حل عملي وبسيط لهاد المشاكل.',
        'value': 'اللي كيميزنا هو البساطة والقرب من الزبون.',
        'audience': 'كنستهدفو المجتمع المحلي بجميع فئاته.',
        'callToAction': 'ساعدنا نوصلو لأكبر عدد ديال الناس. شاركنا الرحلة.',
      },
      'tips': [
        {'key': 'hook', 'label': 'ابدأ بجملة قوية', 'icon': '🎣', 'description': 'ابدأ بسؤال أو إحصائية تجذب الانتباه'},
        {'key': 'problem', 'label': 'حدد المشكل', 'icon': '❓', 'description': 'وصف المشكل اللي كيعاني منو الناس'},
        {'key': 'solution', 'label': 'قدم الحل ديالك', 'icon': '💡', 'description': 'شرح كيفاش المشروع ديالك كيحل المشكل'},
        {'key': 'value', 'label': 'القيمة المضافة', 'icon': '⭐', 'description': 'شنو اللي كيميز المشروع ديالك'},
        {'key': 'audience', 'label': 'الفئة المستهدفة', 'icon': '🎯', 'description': 'شكون اللي غادي يستفاد من المشروع'},
        {'key': 'call_to_action', 'label': 'الخطوة الجاية', 'icon': '🚀', 'description': 'ختم بطلب واضح أو خطوة عملية'},
      ],
    };
  }

  Future<bool> savePitch({
    String? userId,
    required String projectName,
    required String pitchText,
    String? sector,
  }) async {
    try {
      await _api.post('/pitch/save', data: {
        'userId': userId ?? 'anonymous',
        'projectName': projectName,
        'pitchText': pitchText,
        if (sector != null) 'sector': sector,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSavedPitch(String? userId) async {
    try {
      final resp = await _api.get('/pitch/${userId ?? 'anonymous'}');
      if (resp.data is Map<String, dynamic>) return resp.data;
    } catch (_) {}
    return null;
  }
}
