import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cv_model.dart';
import '../services/cv_service.dart';

/// Arabic → French translation map for CV display
const _frenchMap = <String, String>{
  // Skills
  'مهارات التواصل': 'Communication',
  'المهارات الرقمية': 'Compétences numériques',
  'المهارات التقنية/اليدوية': 'Compétences techniques / manuelles',
  'العمل الجماعي': 'Travail d\'équipe',
  'إدارة الوقت': 'Gestion du temps',
  'الإبداع': 'Créativité',
  'المبيعات/التفاوض': 'Vente / Négociation',
  // Interest sub-items
  'تطوير المواقع': 'Développement web',
  'تطبيقات الهاتف': 'Applications mobiles',
  'تحليل البيانات': 'Analyse de données',
  'التصميم الرقمي': 'Design numérique',
  'الدعم التقني': 'Support technique',
  'الفنون والحرف': 'Arts et artisanat',
  'التصوير الفوتوغرافي': 'Photographie',
  'الكتابة والتحرير': 'Rédaction et édition',
  'الموسيقى والصوت': 'Musique et audio',
  'الأزياء والتصميم': 'Mode et design',
  'الطبخ والمطعمة': 'Cuisine et restauration',
  'الفلاحة': 'Agriculture',
  'الميكانيك والصيانة': 'Mécanique et maintenance',
  'التجميل والحلاقة': 'Coiffure et esthétique',
  'الصناعة التقليدية': 'Artisanat traditionnel',
  'البيع والتجارة': 'Vente et commerce',
  'الرعاية الصحية': 'Soins de santé',
  'التعليم والتدريب': 'Enseignement et formation',
  'العمل الاجتماعي': 'Travail social',
  'السياحة والضيافة': 'Tourisme et hôtellerie',
  // Interest categories
  'التكنولوجيا': 'Technologie',
  'الخدمات اليدوية': 'Services manuels',
  'التعامل مع الناس': 'Relations humaines',
  // Work Preferences (English keys from backend)
  'remote': 'Travail à distance',
  'hybrid': 'Hybride',
  'on-site': 'Sur site',
  'flexible-hours': 'Horaires flexibles',
  // Needs (keys or Arabic labels)
  'learning': 'Apprentissage et formation',
  'training': 'Formation professionnelle',
  'confidence': 'Confiance en soi',
  'cv': 'Aide au CV',
  'jobs': 'Recherche d\'emploi',
  'networking': 'Réseautage',
  'languages': 'Apprentissage des langues',
  'digital': 'Compétences numériques',
  'entrepreneurship': 'Entrepreneuriat',
  'التعلم والتكوين': 'Apprentissage et formation',
  'تدريب مهني': 'Formation professionnelle',
  'الثقة بالنفس': 'Confiance en soi',
  'المساعدة في الـ CV': 'Aide au CV',
  'البحث عن عمل': 'Recherche d\'emploi',
  'بناء شبكة علاقات': 'Réseautage',
  'تعلم اللغات': 'Apprentissage des langues',
  'ريادة الأعمال': 'Entrepreneuriat',
};

String _fr(String value) => _frenchMap[value] ?? value;

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
    final userId = await _storage.read(key: 'user_id');
    final backendCv = await _service.fetchCvFromBackend(userId: userId);
    final cv = backendCv ?? await _service.buildLocalPreview();
    setState(() {
      _cv = cv;
      _loading = false;
    });
  }

  Future<void> _exportPdf() async {
    setState(() => _downloading = true);
    final userId = await _storage.read(key: 'user_id');
    final path = await _service.downloadPdf(userId: userId);
    setState(() => _downloading = false);

    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CV téléchargé avec succès !'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: 'CV - إدماج',
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec du téléchargement. Vérifiez la connexion.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _cv == null
                ? const Center(child: Text('Aucune donnée disponible'))
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 200,
                        pinned: true,
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                              ),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _cv!.fullName.isNotEmpty ? _cv!.fullName[0] : '?',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Color(0xFF1565C0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _cv!.fullName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Jeune à la recherche d\'opportunités professionnelles',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                            tooltip: 'Télécharger PDF',
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Contact info
                              if (_cv!.email.isNotEmpty ||
                                  _cv!.phone.isNotEmpty ||
                                  _cv!.city.isNotEmpty ||
                                  _cv!.education.isNotEmpty ||
                                  _cv!.age.isNotEmpty)
                                _buildSection(
                                  icon: Icons.person,
                                  title: 'Informations personnelles',
                                  color: const Color(0xFF1565C0),
                                  child: Column(
                                    children: [
                                      if (_cv!.email.isNotEmpty) _infoRow(Icons.email, 'Email', _cv!.email),
                                      if (_cv!.phone.isNotEmpty) _infoRow(Icons.phone, 'Téléphone', _cv!.phone),
                                      if (_cv!.city.isNotEmpty) _infoRow(Icons.location_city, 'Ville', _cv!.city),
                                      if (_cv!.education.isNotEmpty) _infoRow(Icons.school, 'Niveau scolaire', _cv!.education),
                                      if (_cv!.age.isNotEmpty) _infoRow(Icons.cake, 'Âge', '${_cv!.age} ans'),
                                    ],
                                  ),
                                ),

                              // Skills
                              if (_cv!.skills.isNotEmpty)
                                _buildSection(
                                  icon: Icons.star,
                                  title: 'Compétences',
                                  color: const Color(0xFFE65100),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _cv!.skills
                                        .map((s) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFFEF6C00).withAlpha(80)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.check_circle, size: 16, color: Color(0xFFE65100)),
                                                  const SizedBox(width: 6),
                                                  Text(_fr(s), style: const TextStyle(fontSize: 13, color: Color(0xFFE65100), fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),

                              // Interests
                              if (_cv!.interests.isNotEmpty)
                                _buildSection(
                                  icon: Icons.favorite,
                                  title: 'Centres d\'intérêt',
                                  color: const Color(0xFF7B1FA2),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _cv!.interests
                                        .map((s) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3E5F5),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFF7B1FA2).withAlpha(60)),
                                              ),
                                              child: Text(_fr(s), style: const TextStyle(fontSize: 13, color: Color(0xFF6A1B9A))),
                                            ))
                                        .toList(),
                                  ),
                                ),

                              // Needs
                              if (_cv!.needs.isNotEmpty)
                                _buildSection(
                                  icon: Icons.lightbulb,
                                  title: 'Besoins',
                                  color: const Color(0xFF00838F),
                                  child: Column(
                                    children: _cv!.needs
                                        .map((n) => Padding(
                                              padding: const EdgeInsets.only(bottom: 6),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF00838F),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(child: Text(_fr(n), style: const TextStyle(fontSize: 14))),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),

                              // Work Preferences / Personality
                              if (_cv!.workPreferences.isNotEmpty)
                                _buildSection(
                                  icon: Icons.work,
                                  title: 'Préférences de travail',
                                  color: const Color(0xFF2E7D32),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _cv!.workPreferences
                                        .map((s) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: const Color(0xFF2E7D32).withAlpha(60)),
                                              ),
                                              child: Text(_fr(s), style: const TextStyle(fontSize: 13, color: Color(0xFF1B5E20))),
                                            ))
                                        .toList(),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Export button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _downloading ? null : _exportPdf,
                                  icon: _downloading
                                      ? const SizedBox(
                                          width: 18, height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.download, color: Colors.white),
                                  label: Text(
                                    _downloading ? 'Téléchargement...' : 'Télécharger CV en PDF',
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
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
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}