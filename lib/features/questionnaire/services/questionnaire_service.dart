import '../../../services/api_service.dart';
import '../models/question_model.dart';

class QuestionnaireService {
  final ApiService _api = ApiService();
  final Map<String, String> _answers = {};

  Future<List<QuestionModel>> fetchQuestions() async {
    // Arabic questions and options for testing
    return [
      QuestionModel(
        id: '1',
        question: 'هل تستمتع بالعمل ضمن فريق؟',
        options: [
          'أوافق بشدة',
          'أوافق',
          'محايد',
          'لا أوافق',
          'لا أوافق بشدة',
        ],
      ),
      QuestionModel(
        id: '2',
        question: 'هل تفضل التخطيط قبل البدء في العمل؟',
        options: [
          'أوافق بشدة',
          'أوافق',
          'محايد',
          'لا أوافق',
          'لا أوافق بشدة',
        ],
      ),
      QuestionModel(
        id: '3',
        question: 'هل تجد سهولة في التكيف مع التغييرات؟',
        options: [
          'أوافق بشدة',
          'أوافق',
          'محايد',
          'لا أوافق',
          'لا أوافق بشدة',
        ],
      ),
    ];
  }

  void saveAnswer(String questionId, String selectedOption) {
    _answers[questionId] = selectedOption;
  }

  Map<String, String> getAnswers() {
    return Map<String, String>.from(_answers);
  }

  Future<bool> submitAnswers({String? userId}) async {
    final payload = {
      if (userId != null) 'userId': userId,
      'answers': _answers.entries
          .map((e) => {'questionId': e.key, 'answer': e.value})
          .toList(),
    };
    final response = await _api.post('/questionnaire/answers', data: payload);
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
