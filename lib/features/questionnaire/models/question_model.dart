class QuestionModel {
  final String id;
  final String question;
  final List<String> options;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuestionnaireAnswer {
  final String questionId;
  final String selectedOption;

  const QuestionnaireAnswer({
    required this.questionId,
    required this.selectedOption,
  });
}
