import 'package:flutter/material.dart';

class MentorCard extends StatelessWidget {
  final String name;
  final String subtitle;

  const MentorCard({
    super.key,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(subtitle),
      ),
    );
  }
}
