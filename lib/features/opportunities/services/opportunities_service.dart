import '../../../services/api_service.dart';
import '../models/opportunity_model.dart';

class OpportunitiesService {
  final ApiService _apiService = ApiService();

  Future<List<OpportunityModel>> getOpportunities() async {
    try {
      final resp = await _apiService.get('/opportunities');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => OpportunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return _mockOpportunities();
  }

  Future<List<OpportunityModel>> getMatchedOpportunities(String? userId) async {
    try {
      final uid = userId ?? 'anonymous';
      final resp = await _apiService.get('/opportunities/matched/$uid');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => OpportunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return _mockOpportunities();
  }

  List<OpportunityModel> _mockOpportunities() {
    return const [
      OpportunityModel(
        title: 'مساعد دعم العملاء',
        type: 'job',
        location: 'الدار البيضاء',
        description: 'تدريب لمدة 3 أشهر مع دعم وتوجيه عملي في خدمة الزبناء.',
        matchScore: 75,
        matchReasons: ['يلبي احتياجاتك'],
      ),
      OpportunityModel(
        title: 'برنامج أساسيات التجارة الإلكترونية',
        type: 'training',
        location: 'مراكش',
        description: 'برنامج لمدة 6 أسابيع يركز على أساسيات البيع عبر الإنترنت.',
        matchScore: 60,
        matchReasons: ['يتوافق مع اهتماماتك'],
      ),
      OpportunityModel(
        title: 'مساعد مبيعات مبتدئ',
        type: 'job',
        location: 'أكادير',
        description: 'فرصة عمل للمبتدئين مع تدريب على المبيعات والتواصل.',
        matchScore: 40,
      ),
    ];
  }
}
