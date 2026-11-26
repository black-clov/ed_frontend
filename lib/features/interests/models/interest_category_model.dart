import '../../../core/i18n/app_i18n.dart';

/// Label in the app's current language (server sends labelFr / labelAr since
/// v1.0.2; `label` is the older Arabic-only field, kept as fallback).
String _localized(Map<String, dynamic> json) {
  final fr = json['labelFr'] as String?;
  final ar = (json['labelAr'] ?? json['label']) as String?;
  final preferred = isRtl ? ar : fr;
  return (preferred != null && preferred.isNotEmpty) ? preferred : (ar ?? fr ?? '');
}

class InterestCategory {
  final String id;
  final String label;
  final String icon;
  final List<InterestSubItem> subItems;

  const InterestCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.subItems,
  });

  factory InterestCategory.fromJson(Map<String, dynamic> json) {
    return InterestCategory(
      id: json['id'] as String,
      label: _localized(json),
      icon: json['icon'] as String? ?? '',
      subItems: (json['subItems'] as List<dynamic>?)
              ?.map((e) => InterestSubItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class InterestSubItem {
  final String id;
  final String label;

  const InterestSubItem({required this.id, required this.label});

  factory InterestSubItem.fromJson(Map<String, dynamic> json) {
    return InterestSubItem(
      id: json['id'] as String,
      label: _localized(json),
    );
  }
}
