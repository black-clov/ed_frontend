class ContentModel {
  final String id;
  final String title;
  final String? body;
  final String type;
  final String? category;
  final String? fileUrl;
  final String? imageUrl;
  final bool published;
  final int order;
  final String? createdAt;

  ContentModel({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    this.category,
    this.fileUrl,
    this.imageUrl,
    this.published = true,
    this.order = 0,
    this.createdAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'],
      type: json['type'] ?? 'article',
      category: json['category'],
      fileUrl: json['fileUrl'],
      imageUrl: json['imageUrl'],
      published: json['published'] ?? true,
      order: json['order'] ?? 0,
      createdAt: json['createdAt'],
    );
  }

  String get typeLabel {
    switch (type) {
      case 'article':
        return 'مقال';
      case 'document':
        return 'مستند';
      case 'guide':
        return 'دليل';
      default:
        return type;
    }
  }
}
