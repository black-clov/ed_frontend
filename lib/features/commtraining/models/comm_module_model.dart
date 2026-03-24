class CommModule {
  final String key;
  final String label;
  final String icon;
  final String description;
  final List<String> tips;

  const CommModule({
    required this.key,
    required this.label,
    required this.icon,
    this.description = '',
    this.tips = const [],
  });

  factory CommModule.fromJson(Map<String, dynamic> json) {
    return CommModule(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tips: (json['tips'] as List?)?.cast<String>() ?? [],
    );
  }
}
