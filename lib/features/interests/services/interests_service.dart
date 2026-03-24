import '../../../services/api_service.dart';
import '../models/interest_category_model.dart';

class InterestsService {
  final ApiService _api = ApiService();

  /// Selections: categoryId -> list of selected sub-item IDs
  final Map<String, List<String>> _selections = {};

  Future<List<InterestCategory>> fetchCategories() async {
    try {
      final response = await _api.get('/questionnaire');
      final sections = response.data['sections'];
      final List<dynamic> raw = sections['interestCategories'] ?? [];
      return raw
          .map((e) => InterestCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback categories if API fails
      return _defaultCategories();
    }
  }

  void toggleSubItem(String categoryId, String subItemId) {
    _selections.putIfAbsent(categoryId, () => []);
    final list = _selections[categoryId]!;
    if (list.contains(subItemId)) {
      list.remove(subItemId);
    } else {
      list.add(subItemId);
    }
  }

  bool isSelected(String categoryId, String subItemId) {
    return _selections[categoryId]?.contains(subItemId) ?? false;
  }

  Map<String, List<String>> getSelections() =>
      Map<String, List<String>>.from(_selections);

  int get totalSelected =>
      _selections.values.fold(0, (sum, list) => sum + list.length);

  List<InterestCategory> _defaultCategories() {
    return [
      InterestCategory(
        id: 'technology',
        label: 'التكنولوجيا',
        icon: 'computer',
        subItems: [
          InterestSubItem(id: 'tech_web', label: 'تطوير المواقع'),
          InterestSubItem(id: 'tech_mobile', label: 'تطبيقات الهاتف'),
          InterestSubItem(id: 'tech_data', label: 'تحليل البيانات'),
          InterestSubItem(id: 'tech_design', label: 'التصميم الرقمي'),
          InterestSubItem(id: 'tech_support', label: 'الدعم التقني'),
        ],
      ),
      InterestCategory(
        id: 'creativity',
        label: 'الإبداع',
        icon: 'palette',
        subItems: [
          InterestSubItem(id: 'crea_art', label: 'الفنون والحرف'),
          InterestSubItem(id: 'crea_photo', label: 'التصوير الفوتوغرافي'),
          InterestSubItem(id: 'crea_writing', label: 'الكتابة والتحرير'),
          InterestSubItem(id: 'crea_music', label: 'الموسيقى والصوت'),
          InterestSubItem(id: 'crea_fashion', label: 'الأزياء والتصميم'),
        ],
      ),
      InterestCategory(
        id: 'manual_service',
        label: 'الخدمات اليدوية',
        icon: 'build',
        subItems: [
          InterestSubItem(id: 'man_cook', label: 'الطبخ والمطعمة'),
          InterestSubItem(id: 'man_agri', label: 'الفلاحة'),
          InterestSubItem(id: 'man_mech', label: 'الميكانيك والصيانة'),
          InterestSubItem(id: 'man_beauty', label: 'التجميل والحلاقة'),
          InterestSubItem(id: 'man_craft', label: 'الصناعة التقليدية'),
        ],
      ),
      InterestCategory(
        id: 'people',
        label: 'التعامل مع الناس',
        icon: 'people',
        subItems: [
          InterestSubItem(id: 'ppl_sales', label: 'البيع والتجارة'),
          InterestSubItem(id: 'ppl_care', label: 'الرعاية الصحية'),
          InterestSubItem(id: 'ppl_teach', label: 'التعليم والتدريب'),
          InterestSubItem(id: 'ppl_social', label: 'العمل الاجتماعي'),
          InterestSubItem(id: 'ppl_tourism', label: 'السياحة والضيافة'),
        ],
      ),
    ];
  }
}
