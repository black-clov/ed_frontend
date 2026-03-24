class OpportunityModel {
  final String id;
  final String title;
  final String type;
  final String location;
  final String description;
  final int matchScore;
  final List<String> matchReasons;

  const OpportunityModel({
    this.id = '',
    required this.title,
    this.type = '',
    required this.location,
    required this.description,
    this.matchScore = 0,
    this.matchReasons = const [],
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      matchScore: json['matchScore'] as int? ?? 0,
      matchReasons: (json['matchReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
