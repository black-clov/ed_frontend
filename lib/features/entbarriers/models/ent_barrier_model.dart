class EntBarrierOption {
  final String key;
  final String label;
  final String icon;
  final String description;

  const EntBarrierOption({
    required this.key,
    required this.label,
    required this.icon,
    this.description = '',
  });

  factory EntBarrierOption.fromJson(Map<String, dynamic> json) {
    return EntBarrierOption(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
