import 'package:flutter/material.dart';

import '../models/mentor_model.dart';
import '../services/mentorship_service.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإرشاد والبرامج')),
      body: FutureBuilder<List<MentorModel>>(
        future: MentorshipService().getMentors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final mentors = snapshot.data ?? const [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(mentor.name, textDirection: TextDirection.rtl),
                  subtitle: Text('${mentor.focusArea} - ${mentor.location}', textDirection: TextDirection.rtl),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('تواصل', textDirection: TextDirection.rtl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
