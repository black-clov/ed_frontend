class SupportCategory {
  final String category;
  final String label;
  final String icon;
  final String description;
  final List<SupportChoice> choices;

  const SupportCategory({
    required this.category,
    required this.label,
    required this.icon,
    this.description = '',
    required this.choices,
  });

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'] as List? ?? [];
    return SupportCategory(
      category: json['category'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '',
      description: json['description'] as String? ?? '',
      choices: rawChoices.map((c) => SupportChoice.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }
}

class SupportChoice {
  final String key;
  final String label;

  const SupportChoice({required this.key, required this.label});

  factory SupportChoice.fromJson(Map<String, dynamic> json) {
    return SupportChoice(
      key: json['key'] as String,
      label: json['label'] as String,
    );
  }
}
