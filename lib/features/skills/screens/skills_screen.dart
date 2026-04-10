import 'package:flutter/material.dart';

import '../services/skills_service.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final SkillsService _skillsService = SkillsService();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _skillsService.loadUserSkills();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await _skillsService.saveSkills();
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'تم حفظ المهارات بنجاح ✅' : 'فشل الحفظ، حاول مجدداً'),
          backgroundColor: ok ? const Color(0xFF2E7D32) : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSkills = _skillsService.getCurrentSelection().selectedSkills;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          title: const Text('المهارات'),
          centerTitle: true,
          backgroundColor: const Color(0xFFEF6C00),
          foregroundColor: Colors.white,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF6C00), Color(0xFFF57C00)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.psychology, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          const Text(
                            'اختر أهم مهاراتك',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر حتى ${SkillsService.maxSkills} مهارات تميزك',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...(_skillsService.skillsCatalog.map((skill) {
                      final isSelected = selectedSkills.contains(skill);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFEF6C00) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final changed = _skillsService.toggleSkill(skill);
                            if (!changed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('يمكنك اختيار حتى 3 مهارات فقط.')),
                              );
                              return;
                            }
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? const Color(0xFFEF6C00) : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFFEF6C00) : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
                    if (selectedSkills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF6C00).withAlpha(60)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedSkills.map((s) => Chip(
                            label: Text(s, style: const TextStyle(color: Color(0xFFE65100), fontSize: 13)),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFEF6C00)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              _skillsService.toggleSkill(s);
                              setState(() {});
                            },
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saving || selectedSkills.isEmpty ? null : _save,
                        icon: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          _saving ? 'جاري الحفظ...' : 'حفظ المهارات',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF6C00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}