class SectorOption {
  final String key;
  final String label;
  final String icon;

  const SectorOption({required this.key, required this.label, required this.icon});

  factory SectorOption.fromJson(Map<String, dynamic> json) {
    return SectorOption(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String? ?? '',
    );
  }
}
