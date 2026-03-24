import '../../../services/api_service.dart';
import '../models/soft_skill_model.dart';

class SoftSkillsService {
  final ApiService _api = ApiService();
  final Map<String, String> _answers = {};

  Future<List<SoftSkillQuestion>> fetchQuestions() async {
    try {
      final response = await _api.get('/questionnaire');
      final sections = response.data['sections'];
      final List<dynamic> raw = sections['softSkillsQuestions'] ?? [];
      return raw
          .map((e) => SoftSkillQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaultQuestions();
    }
  }

  void saveAnswer(String questionId, String answer) {
    _answers[questionId] = answer;
  }

  String? getAnswer(String questionId) => _answers[questionId];

  Map<String, String> getAllAnswers() => Map<String, String>.from(_answers);

  bool get allAnswered => _answers.length >= 6;

  List<SoftSkillQuestion> _defaultQuestions() {
    return const [
      SoftSkillQuestion(
        id: 's1',
        question: 'واش كتجي فالوقت ديالك للخدمة؟',
        options: ['ديما', 'غالبا', 'بعض المرات', 'قليل'],
      ),
      SoftSkillQuestion(
        id: 's2',
        question: 'كيفاش كتعامل مع الضغط فالخدمة؟',
        options: ['كنبقى هادي وكنلقى حلول', 'كنحاول نتأقلم', 'كنتوتر شوية', 'صعيب عليا'],
      ),
      SoftSkillQuestion(
        id: 's3',
        question: 'واش كتقبل الملاحظات من الناس؟',
        options: ['بكل ارتياح', 'غالبا نعم', 'كيقلقني شوية', 'ما كنقبلش بسهولة'],
      ),
      SoftSkillQuestion(
        id: 's4',
        question: 'واش كتقدر تخدم بوحدك بلا ما حد يراقبك؟',
        options: ['نعم، كنكون مستقل', 'غالبا نعم', 'كنحتاج توجيه أحيانا', 'كنحتاج مساعدة ديما'],
      ),
      SoftSkillQuestion(
        id: 's5',
        question: 'كيفاش كتنظم الوقت ديالك؟',
        options: ['عندي خطة واضحة ديما', 'كنحاول نتنظم', 'مرات كنضيع الوقت', 'ما عنديش تنظيم'],
      ),
      SoftSkillQuestion(
        id: 's6',
        question: 'واش كتواصل مزيان مع الآخرين؟',
        options: ['نعم، بسهولة', 'غالبا', 'كنلقى صعوبة أحيانا', 'صعيب عليا'],
      ),
    ];
  }
}
