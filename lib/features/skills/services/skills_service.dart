import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';
import '../models/skills_model.dart';

class SkillsService {
  static const int maxSkills = 3;

  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  Future<void> loadUserSkills() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null) return;
    try {
      final cvResp = await _api.post('/cv/generate', data: {'userId': userId});
      final skills = List<String>.from(cvResp.data?['sections']?['skills'] ?? []);
      _selectedSkills.clear();
      _selectedSkills.addAll(skills);
    } catch (_) {}
  }

  Future<bool> saveSkills() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null) return false;
    try {
      await _api.post('/skills/user', data: {
        'userId': userId,
        'skills': _selectedSkills,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}