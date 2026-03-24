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
      label: json['label'] as String,
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
      label: json['label'] as String,
    );
  }
}
