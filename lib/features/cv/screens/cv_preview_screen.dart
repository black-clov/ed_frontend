import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cv_model.dart';
import '../services/cv_service.dart';

class CvPreviewScreen extends StatefulWidget {
  const CvPreviewScreen({super.key});

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  final CvService _service = CvService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  CvModel? _cv;
  bool _loading = true;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _loadCv();
  }

  Future<void> _loadCv() async {
    final userId = await _storage.read(key: 'userId');
    final backendCv = await _service.fetchCvFromBackend(userId: userId);
    final cv = backendCv ?? await _service.buildLocalPreview();
    setState(() {
      _cv = cv;
      _loading = false;
    });
  }

  Future<void> _exportPdf() async {
    setState(() => _downloading = true);
    final userId = await _storage.read(key: 'userId');
    final path = await _service.downloadPdf(userId: userId);
    setState(() => _downloading = false);

    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحميل الـ CV بنجاح!')),
      );
      // Offer to share
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: 'CV - E@Dmaj',
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل التحميل. تحقق من الاتصال بالخادم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السيرة الذاتية'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _downloading ? null : _exportPdf,
              icon: _downloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf),
              tooltip: 'تحميل PDF',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _cv == null
                ? const Center(child: Text('لا توجد بيانات'))
                : _buildCvPreview(),
      ),
    );
  }

  Widget _buildCvPreview() {
    final cv = _cv!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    cv.fullName.isNotEmpty ? cv.fullName[0] : '?',
                    style: const TextStyle(fontSize: 30, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cv.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'شاب(ة) باحث(ة) عن فرص مهنية',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skills
          _buildSection(
            icon: Icons.star,
            title: 'المهارات',
            color: const Color(0xFFE65100),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cv.skills
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 13)),
                        backgroundColor: const Color(0xFFFFF3E0),
                      ))
                  .toList(),
            ),
          ),

          // Interests
          _buildSection(
            icon: Icons.favorite,
            title: 'الاهتمامات',
            color: const Color(0xFF7B1FA2),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cv.interests
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 13)),
                        backgroundColor: const Color(0xFFF3E5F5),
                      ))
                  .toList(),
            ),
          ),

          // Personality
          _buildSection(
            icon: Icons.psychology,
            title: 'نقاط القوة',
            color: const Color(0xFF2E7D32),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cv.personalityHighlights
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 13)),
                        backgroundColor: const Color(0xFFE8F5E9),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Export button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _downloading ? null : _exportPdf,
              icon: _downloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _downloading ? 'جاري التحميل...' : 'تحميل CV بصيغة PDF',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
