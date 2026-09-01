import 'package:flutter/material.dart';

import '../services/interview_service.dart';
import 'mock_interview_screen.dart';
import 'package:flutter_application_1/core/i18n/app_i18n.dart';

class InterviewPrepScreen extends StatelessWidget {
  const InterviewPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = InterviewService();
    final tips = service.getTips();
    final questions = service.getPracticeQuestions();

    return Scaffold(
      appBar: AppBar(title: Text(tr('emp2_interview_prep_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Launch simulator button
          Card(
            color: Color(0xFFFFEBEE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MockInterviewScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFC62828),
                      radius: 24,
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('emp2_mock_interview_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                          const SizedBox(height: 4),
                          Text(tr('emp2_mock_interview_subtitle'), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_back_ios, color: Color(0xFFC62828)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(tr('emp2_tips_title'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...tips.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline, color: Color(0xFFC62828)),
                title: Text(item.title),
                subtitle: Text(item.tip),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(tr('emp2_practice_questions_title'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...questions.map((q) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.help_outline, color: Color(0xFFC62828)),
                  title: Text(q),
                ),
              )),
        ],
      ),
    );
  }
}
