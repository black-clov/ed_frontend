import '../../../services/api_service.dart';
import '../models/interview_tip_model.dart';

class InterviewService {
  final ApiService _api = ApiService();

  List<InterviewTipModel> getTips() {
    return const [
      InterviewTipModel(
        title: 'التحضير',
        tip: 'ابحث على الشركة وحضر 3 نقاط قوة باش تشاركهم',
      ),
      InterviewTipModel(
        title: 'التواصل',
        tip: 'جاوب بوضوح مع أمثلة قصيرة من تجربتك',
      ),
      InterviewTipModel(
        title: 'لغة الجسد',
        tip: 'خلي عينيك فالمحاور، كون جالس مزيان، وما تسرعش فالهضرة',
      ),
    ];
  }

  List<String> getPracticeQuestions() {
    return const [
      'عرف براسك فدقيقة',
      'علاش بغيتي هاد الخدمة؟',
      'أشنو هي نقاط القوة ديالك؟',
    ];
  }

  Future<List<SimulationQuestion>> fetchSimulationQuestions({String? role}) async {
    try {
      final params = role != null ? {'role': role} : null;
      final response = await _api.get('/interview/simulation/questions', queryParameters: params);
      final List<dynamic> raw = response.data['questions'] ?? [];
      return raw.map((e) => SimulationQuestion.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultQuestions();
    }
  }

  Future<SimulationResult> submitSimulation({
    required String userId,
    required String targetRole,
    required List<Map<String, String>> answers,
  }) async {
    try {
      final response = await _api.post('/interview/simulation/submit', data: {
        'userId': userId,
        'targetRole': targetRole,
        'answers': answers,
      });
      return SimulationResult.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return _evaluateLocally(answers);
    }
  }

  SimulationResult _evaluateLocally(List<Map<String, String>> answers) {
    int total = 0;
    final evals = <Map<String, dynamic>>[];
    for (final a in answers) {
      final len = (a['answer'] ?? '').length;
      int score;
      String feedback;
      if (len < 20) {
        score = 5;
        feedback = 'الجواب قصير بزاف، حاول تشرح أكثر';
      } else if (len < 80) {
        score = 12;
        feedback = 'جواب مقبول، حاول تزيد تفاصيل وأمثلة';
      } else {
        score = 18;
        feedback = 'جواب مفصل ومزيان';
      }
      total += score;
      evals.add({'questionId': a['questionId'], 'score': score, 'maxScore': 20, 'feedback': [feedback]});
    }
    final maxScore = answers.length * 20;
    final percentage = maxScore > 0 ? ((total / maxScore) * 100).round() : 0;
    String overallFeedback;
    if (percentage >= 80) {
      overallFeedback = 'أداء ممتاز! أنت جاهز للمقابلة';
    } else if (percentage >= 60) {
      overallFeedback = 'أداء جيد، مع شوية تحسين غادي تكون جاهز';
    } else if (percentage >= 40) {
      overallFeedback = 'أداء مقبول، خاصك تتدرب أكثر';
    } else {
      overallFeedback = 'خاصك تتدرب بزاف، شوف الفيديوهات والنصائح';
    }
    return SimulationResult(
      totalScore: total,
      maxScore: maxScore,
      percentage: percentage,
      overallFeedback: overallFeedback,
      evaluations: evals,
    );
  }

  List<SimulationQuestion> _defaultQuestions() {
    return const [
      SimulationQuestion(id: 'q1', question: 'عرف براسك فدقيقة', category: 'introduction', tips: 'ركز على الاسم، المستوى الدراسي، والمهارات اللي عندك', maxScore: 20),
      SimulationQuestion(id: 'q2', question: 'علاش بغيتي هاد الخدمة؟', category: 'motivation', tips: 'بين حماسك وربط الجواب بالمهارات ديالك', maxScore: 20),
      SimulationQuestion(id: 'q3', question: 'أشنو هي نقاط القوة ديالك؟', category: 'strengths', tips: 'عطي أمثلة عملية، ماشي غير كلام عام', maxScore: 20),
      SimulationQuestion(id: 'q4', question: 'كيفاش كتعامل مع مشكل فالخدمة؟', category: 'problem_solving', tips: 'استعمل طريقة STAR: الموقف، المهمة، الفعل، النتيجة', maxScore: 20),
      SimulationQuestion(id: 'q5', question: 'واش عندك شي سؤال لينا؟', category: 'engagement', tips: 'سول على ثقافة الشركة أو فرص التطور', maxScore: 20),
    ];
  }
}

class SimulationQuestion {
  final String id;
  final String question;
  final String category;
  final String tips;
  final int maxScore;

  const SimulationQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.tips,
    required this.maxScore,
  });

  factory SimulationQuestion.fromJson(Map<String, dynamic> json) {
    return SimulationQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String? ?? '',
      tips: json['tips'] as String? ?? '',
      maxScore: json['maxScore'] as int? ?? 20,
    );
  }
}

class SimulationResult {
  final int totalScore;
  final int maxScore;
  final int percentage;
  final String overallFeedback;
  final List<Map<String, dynamic>> evaluations;

  const SimulationResult({
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.overallFeedback,
    required this.evaluations,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      totalScore: json['totalScore'] as int? ?? 0,
      maxScore: json['maxScore'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
      overallFeedback: json['overallFeedback'] as String? ?? '',
      evaluations: (json['evaluations'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
