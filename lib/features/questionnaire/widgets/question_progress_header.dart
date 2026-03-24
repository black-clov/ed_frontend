import 'package:flutter/material.dart';

class QuestionProgressHeader extends StatelessWidget {
  final int current;
  final int total;

  const QuestionProgressHeader({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Question $current/$total');
  }
}
