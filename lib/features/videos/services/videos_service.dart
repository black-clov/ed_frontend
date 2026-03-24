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
      return _defaultCategories();
    }
  }

  Future<List<VideoModel>> fetchVideos({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response =
          await _api.get('/videos', queryParameters: queryParams);
      final List<dynamic> raw = response.data;
      return raw
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaultVideos();
    }
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

  List<VideoModel> _defaultVideos() {
    return const [
      VideoModel(
        id: '1',
        title: 'كيفاش تكتب CV مزيان',
        description:
            'فهاد الفيديو غادي نشرحو ليكم كيفاش تكتبو CV احترافي اللي غادي يعجب الشركات',
        videoUrl: 'https://example.com/videos/cv-writing.mp4',
        category: 'cv',
        durationSeconds: 180,
      ),
      VideoModel(
        id: '2',
        title: 'التحضير ديال المقابلة',
        description:
            'نصائح عملية باش تكون جاهز للمقابلة وتعطي أحسن صورة على راسك',
        videoUrl: 'https://example.com/videos/interview-prep.mp4',
        category: 'interview',
        durationSeconds: 240,
      ),
      VideoModel(
        id: '3',
        title: 'المهارات اللي كيطلبو الشركات',
        description:
            'غادي نهضرو على أهم المهارات اللي خاصك تديرهم فالCV باش تلقى خدمة',
        videoUrl: 'https://example.com/videos/top-skills.mp4',
        category: 'skills',
        durationSeconds: 150,
      ),
      VideoModel(
        id: '4',
        title: 'كيفاش تقدم راسك فالخدمة',
        description:
            'تعلم كيفاش تهضر على راسك بطريقة مقنعة قدام المسؤولين',
        videoUrl: 'https://example.com/videos/self-presentation.mp4',
        category: 'softskills',
        durationSeconds: 200,
      ),
      VideoModel(
        id: '5',
        title: 'فين تلقى الفرص ديال الخدمة',
        description:
            'المواقع والتطبيقات اللي فيهم فرص حقيقية للشباب المغربي',
        videoUrl: 'https://example.com/videos/finding-jobs.mp4',
        category: 'opportunities',
        durationSeconds: 160,
      ),
      VideoModel(
        id: '6',
        title: 'كيفاش تبدا مشروعك الخاص',
        description: 'خطوات عملية باش تبدا مشروع صغير ناجح من الصفر',
        videoUrl: 'https://example.com/videos/start-business.mp4',
        category: 'entrepreneurship',
        durationSeconds: 300,
      ),
    ];
  }
}
