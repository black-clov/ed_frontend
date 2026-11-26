import 'package:flutter/material.dart';

import '../../questionnaire/widgets/profile_quiz.dart';

/// "Savoir-être" (soft skills) questionnaire (answers saved on the account).
class SoftSkillsScreen extends StatelessWidget {
  const SoftSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProfileQuiz(kind: ProfileQuizKind.softSkills);
}
