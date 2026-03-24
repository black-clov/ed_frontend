import 'package:flutter/material.dart';

import '../services/interview_service.dart';
import 'mock_interview_screen.dart';

class InterviewPrepScreen extends StatelessWidget {
  const InterviewPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = InterviewService();
    final tips = service.getTips();
    final questions = service.getPracticeQuestions();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التحضير للمقابلة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Launch simulator button
            Card(
              color: Colors.indigo.shade50,
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
                        backgroundColor: Colors.indigo,
                        radius: 24,
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('محاكاة المقابلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            const SizedBox(height: 4),
                            Text('تدرب على أسئلة حقيقية واحصل على تقييم فوري', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_back_ios, color: Colors.indigo),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('نصائح', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...tips.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  title: Text(item.title),
                  subtitle: Text(item.tip),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('أسئلة للتدريب', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...questions.map((q) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.indigo),
                    title: Text(q),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
