import 'package:flutter/material.dart';

import '../models/mentor_model.dart';
import '../services/mentorship_service.dart';
import 'package:flutter_application_1/core/i18n/app_i18n.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('emp2_mentorship_title'))),
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
                  title: Text(mentor.name, textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
                  subtitle: Text('${mentor.focusArea} - ${mentor.location}', textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
                  trailing: TextButton(
                    onPressed: () {},
                    child: Text(tr('emp2_contact'), textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
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
