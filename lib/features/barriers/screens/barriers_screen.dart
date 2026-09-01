import 'package:flutter/material.dart';

import '../services/barriers_service.dart';
import '../../../core/i18n/app_i18n.dart';

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
      appBar: AppBar(title: Text(tr('ent_gen_barriers_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('ent_gen_barriers_subtitle'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._barriersService.barriersCatalog.map(
              (barrier) => CheckboxListTile(
                value: selected.contains(barrier),
                title: Text(barrier, textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr),
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
