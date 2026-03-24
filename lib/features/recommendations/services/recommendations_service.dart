import '../../../services/api_service.dart';
import '../models/recommendation_model.dart';

class RecommendationsService {
  final ApiService _apiService = ApiService();

  Future<List<RecommendationModel>> getRecommendations() async {
    try {
      await _apiService.get('/recommendations');
    } catch (_) {
      // Fallback to mock data while endpoint is not available.
    }

    return const [
      RecommendationModel(
        title: 'برنامج تدريبي: أساسيات التسويق الرقمي',
        description: 'بناء أساس عملي للوصول إلى وظائف المبتدئين.',
        actionLabel: 'عرض البرنامج',
      ),
      RecommendationModel(
        title: 'اقتراح وظيفة: وكيل دعم مجتمعي مبتدئ',
        description: 'مناسب لمهارات التواصل والتعاطف.',
        actionLabel: 'تقديم الطلب',
      ),
      RecommendationModel(
        title: 'تدريب: مؤسسة اجتماعية محلية',
        description: 'خبرة عملية في تنسيق المشاريع.',
        actionLabel: 'استكشاف',
      ),
    ];
  }
}
