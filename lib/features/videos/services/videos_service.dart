import '../../../services/api_service.dart';
import '../models/video_model.dart';

class VideosService {
  final ApiService _api = ApiService();

  Future<List<VideoCategory>> fetchCategories() async {
    try {
      final response = await _api.get('/videos/categories');
      final List<dynamic> raw = response.data;
      return raw
          .map((e) => VideoCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Categories are static, safe to use defaults as fallback
      return _defaultCategories();
    }
  }

  Future<List<VideoModel>> fetchVideos({String? category}) async {
    final queryParams = category != null ? {'category': category} : null;
    final response =
        await _api.get('/videos', queryParameters: queryParams);
    final data = response.data;
    if (data is List) {
      return data
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  List<VideoCategory> _defaultCategories() {
    return const [
      VideoCategory(id: 'cv', label: 'كتابة السيرة الذاتية'),
      VideoCategory(id: 'interview', label: 'التحضير للمقابلة'),
      VideoCategory(id: 'skills', label: 'المهارات المطلوبة'),
      VideoCategory(id: 'softskills', label: 'المهارات الشخصية'),
      VideoCategory(id: 'opportunities', label: 'البحث عن الفرص'),
      VideoCategory(id: 'entrepreneurship', label: 'ريادة الأعمال'),
    ];
  }
}
