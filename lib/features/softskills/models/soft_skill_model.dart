class SoftSkillQuestion {
  final String id;
  final String question;
  final List<String> options;

  const SoftSkillQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory SoftSkillQuestion.fromJson(Map<String, dynamic> json) {
    return SoftSkillQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
    );
  }
}
