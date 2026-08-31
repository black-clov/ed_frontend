import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final String category;
  final int durationSeconds;

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.category,
    required this.durationSeconds,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: json['category'] as String,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Thumbnail to display: the provided one if set, otherwise the YouTube
  /// thumbnail derived from the video link (so admins only need to paste a URL).
  String? get displayThumbnail {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl;
    final ytId = YoutubePlayer.convertUrlToId(videoUrl);
    if (ytId != null) return 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    return null;
  }
}

class VideoCategory {
  final String id;
  final String label;

  const VideoCategory({required this.id, required this.label});

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}
