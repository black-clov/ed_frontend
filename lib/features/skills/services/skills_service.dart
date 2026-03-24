import '../models/skills_model.dart';

class SkillsService {
  static const int maxSkills = 3;

  final List<String> _selectedSkills = [];

  List<String> get skillsCatalog => const [
        'مهارات التواصل',
        'المهارات الرقمية',
        'المهارات التقنية/اليدوية',
        'العمل الجماعي',
        'إدارة الوقت',
        'الإبداع',
        'المبيعات/التفاوض',
      ];

  SkillsModel getCurrentSelection() {
    return SkillsModel(selectedSkills: List<String>.from(_selectedSkills));
  }

  bool toggleSkill(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
      return true;
    }

    if (_selectedSkills.length >= maxSkills) {
      return false;
    }

    _selectedSkills.add(skill);
    return true;
  }
}
