import 'package:flutter/material.dart';

import '../models/video_model.dart';
import '../services/videos_service.dart';
import 'video_player_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideosService _service = VideosService();
  List<VideoCategory> _categories = [];
  List<VideoModel> _videos = [];
  String? _selectedCategory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cats = await _service.fetchCategories();
      final videos = await _service.fetchVideos();
      setState(() {
        _categories = cats;
        _videos = videos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الفيديوهات. تحقق من الاتصال وأعد المحاولة.';
      });
    }
  }

  Future<void> _filterByCategory(String? categoryId) async {
    setState(() {
      _selectedCategory = categoryId;
      _loading = true;
      _error = null;
    });
    try {
      final videos = await _service.fetchVideos(category: categoryId);
      setState(() {
        _videos = videos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الفيديوهات. أعد المحاولة.';
      });
    }
  }

  IconData _iconForCategory(String catId) {
    switch (catId) {
      case 'cv':
        return Icons.description;
      case 'interview':
        return Icons.record_voice_over;
      case 'skills':
        return Icons.star;
      case 'softskills':
        return Icons.psychology;
      case 'opportunities':
        return Icons.work;
      case 'entrepreneurship':
        return Icons.rocket_launch;
      default:
        return Icons.play_circle;
    }
  }

  Color _colorForCategory(String catId) {
    switch (catId) {
      case 'cv':
        return const Color(0xFF1565C0);
      case 'interview':
        return const Color(0xFF7B1FA2);
      case 'skills':
        return const Color(0xFFE65100);
      case 'softskills':
        return const Color(0xFF2E7D32);
      case 'opportunities':
        return const Color(0xFF00838F);
      case 'entrepreneurship':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('فيديوهات تعليمية'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Category filter chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: const Text('الكل'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => _filterByCategory(null),
                    ),
                  ),
                  ..._categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        avatar: Icon(
                          _iconForCategory(cat.id),
                          size: 18,
                          color: _selectedCategory == cat.id
                              ? Colors.white
                              : _colorForCategory(cat.id),
                        ),
                        label: Text(cat.label),
                        selected: _selectedCategory == cat.id,
                        selectedColor: _colorForCategory(cat.id),
                        onSelected: (_) => _filterByCategory(
                          _selectedCategory == cat.id ? null : cat.id,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(_error!, style: const TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _videos.isEmpty
                      ? const Center(
                          child: Text(
                            'ما كاين حتى فيديو فهاد القسم',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            return _VideoCard(
                              video: video,
                              color: _colorForCategory(video.category),
                              icon: _iconForCategory(video.category),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final Color color;
  final IconData icon;

  const _VideoCard({
    required this.video,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showVideoDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                      Image.network(
                        video.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: color.withValues(alpha: 0.1),
                          child: Icon(Icons.play_circle_fill, size: 56, color: color),
                        ),
                      )
                    else
                      Container(
                        color: color.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(Icons.play_circle_fill, size: 56, color: color),
                        ),
                      ),
                    // Duration badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    // Play overlay
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.play_arrow, size: 36, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          video.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      video.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                video.description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.timer, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'المدة: ${video.formattedDuration}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          videoUrl: video.videoUrl,
                          title: video.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('شاهد الفيديو', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
