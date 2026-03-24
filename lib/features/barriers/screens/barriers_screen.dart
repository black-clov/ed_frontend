import 'package:flutter/material.dart';

import '../services/barriers_service.dart';

class BarriersScreen extends StatefulWidget {
  const BarriersScreen({super.key});

  @override
  State<BarriersScreen> createState() => _BarriersScreenState();
}

class _BarriersScreenState extends State<BarriersScreen> {
  final BarriersService _barriersService = BarriersService();

  @override
  Widget build(BuildContext context) {
    final selected = _barriersService.getCurrentSelection().selectedBarriers;

    return Scaffold(
      appBar: AppBar(title: const Text('التحديات والعوائق')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر العوائق الحالية لديك',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._barriersService.barriersCatalog.map(
              (barrier) => CheckboxListTile(
                value: selected.contains(barrier),
                title: Text(barrier, textDirection: TextDirection.rtl),
                onChanged: (_) {
                  setState(() {
                    _barriersService.toggleBarrier(barrier);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
