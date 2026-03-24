import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String title;
  final String message;

  const TipCard({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }
}
