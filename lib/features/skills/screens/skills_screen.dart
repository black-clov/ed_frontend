import 'package:flutter/material.dart';

import '../services/skills_service.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final SkillsService _skillsService = SkillsService();

  @override
  Widget build(BuildContext context) {
    final selectedSkills = _skillsService.getCurrentSelection().selectedSkills;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختر أهم مهاراتك')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'اختر حتى ${SkillsService.maxSkills} مهارات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skillsService.skillsCatalog.map((skill) {
                  final isSelected = selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (_) {
                      final changed = _skillsService.toggleSkill(skill);
                      if (!changed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يمكنك اختيار حتى 3 مهارات فقط.'),
                          ),
                        );
                        return;
                      }
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('المهارات المختارة: ${selectedSkills.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
