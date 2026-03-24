import 'package:flutter/material.dart';

class BarrierTile extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const BarrierTile({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      title: Text(label),
      onChanged: onChanged,
    );
  }
}
