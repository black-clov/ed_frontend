class NeedsOption {
  final String key;
  final String label;
  final String icon;

  const NeedsOption({required this.key, required this.label, required this.icon});

  factory NeedsOption.fromJson(Map<String, dynamic> json) {
    return NeedsOption(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '',
    );
  }
}
