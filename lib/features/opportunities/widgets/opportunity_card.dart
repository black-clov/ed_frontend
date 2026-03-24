import 'package:flutter/material.dart';

class OpportunityCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;

  const OpportunityCard({
    super.key,
    required this.title,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(location),
            const SizedBox(height: 6),
            Text(description),
          ],
        ),
      ),
    );
  }
}
