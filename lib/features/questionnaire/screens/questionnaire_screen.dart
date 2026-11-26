import 'package:flutter/material.dart';

import '../widgets/profile_quiz.dart';

/// "Personnalité" questionnaire (answers saved on the user's account).
class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProfileQuiz(kind: ProfileQuizKind.personality);
}
