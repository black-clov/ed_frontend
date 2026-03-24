import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(description),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {}, child: Text(actionLabel)),
            ),
          ],
        ),
      ),
    );
  }
}
