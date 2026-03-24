import '../../../services/api_service.dart';

class BusinessPlanService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>?> generatePlan({
    String? userId,
    required String projectName,
    String? sector,
  }) async {
    try {
      final resp = await _api.post('/businessplan/generate', data: {
        'userId': userId ?? 'anonymous',
        'projectName': projectName,
        'sector': sector,
      });
      final data = resp.data;
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    // Local fallback
    return _localGenerate(projectName, sector);
  }

  Future<bool> savePlan({
    String? userId,
    required String projectName,
    required String description,
    required String valueProposition,
    required String targetCustomers,
    required String costs,
    required String firstSteps,
    String? sector,
  }) async {
    try {
      await _api.post('/businessplan/save', data: {
        'userId': userId ?? 'anonymous',
        'projectName': projectName,
        'description': description,
        'valueProposition': valueProposition,
        'targetCustomers': targetCustomers,
        'costs': costs,
        'firstSteps': firstSteps,
        'sector': sector,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSavedPlan(String? userId) async {
    try {
      final resp = await _api.get('/businessplan/${userId ?? 'anonymous'}');
      final data = resp.data;
      if (data is Map<String, dynamic> && data['projectName'] != null) return data;
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _localGenerate(String name, String? sector) {
    return {
      'projectName': name,
      'sector': sector ?? 'general',
      'sections': {
        'description':
            'مشروع "$name" هو فكرة مشروع واعدة تهدف إلى تلبية حاجة حقيقية في السوق المحلي، مع التركيز على البساطة والجودة.',
        'valueProposition':
            'القيمة المضافة: منتج/خدمة تلبي حاجة حقيقية - سعر مناسب - خدمة قريبة من الزبون.',
        'targetCustomers':
            'الزبناء المستهدفون: السكان المحليون - الشباب - المقاولات الصغيرة في المنطقة.',
        'costs':
            'التكاليف المتوقعة: رأس المال الأولي (5000-20000 درهم) - المصاريف الشهرية (2000-5000 درهم) - التسويق (1000 درهم/شهر).',
        'firstSteps':
            '1. دراسة السوق وتحليل المنافسين\n2. إعداد خطة عمل بسيطة\n3. البحث عن تمويل أولي\n4. إطلاق نسخة أولى من المنتج/الخدمة\n5. التقييم والتحسين المستمر',
      },
    };
  }
}
