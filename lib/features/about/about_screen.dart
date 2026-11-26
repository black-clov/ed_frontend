import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/app_i18n.dart';
import '../../services/api_service.dart';

const _red = Color(0xFFC62828);
const _green = Color(0xFF2E7D32);

/// "À propos" page. Its text, contacts and links are edited by the
/// association from the admin panel (GET /settings/about, public).
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Map<String, dynamic>? _about;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final resp = await ApiService().get('/settings/about');
      if (!mounted) return;
      setState(() {
        _about = resp.data is Map ? Map<String, dynamic>.from(resp.data) : {};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String get _description {
    final fr = (_about?['descriptionFr'] ?? '').toString().trim();
    final ar = (_about?['descriptionAr'] ?? '').toString().trim();
    final preferred = isRtl ? ar : fr;
    return preferred.isNotEmpty ? preferred : (isRtl ? fr : ar);
  }

  List<Map<String, String>> get _links {
    final raw = _about?['links'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((l) => {
              'label': (l['label'] ?? '').toString(),
              'url': (l['url'] ?? '').toString(),
            })
        .where((l) => l['url']!.startsWith('http'))
        .toList();
  }

  IconData _iconFor(String label, String url) {
    final s = '$label $url'.toLowerCase();
    if (s.contains('facebook')) return Icons.facebook_rounded;
    if (s.contains('instagram')) return Icons.camera_alt_outlined;
    if (s.contains('youtube')) return Icons.play_circle_outline_rounded;
    if (s.contains('linkedin')) return Icons.work_outline_rounded;
    if (s.contains('whatsapp')) return Icons.chat_outlined;
    return Icons.language_rounded;
  }

  Future<void> _open(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('about_open_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, _, _) => Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          title: Text(tr('about_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _red))
            : _error
                ? _buildError()
                : RefreshIndicator(onRefresh: _load, color: _red, child: _buildContent()),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(tr('about_load_error'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: Text(tr('retry'))),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final email = (_about?['contactEmail'] ?? '').toString().trim();
    final phone = (_about?['contactPhone'] ?? '').toString().trim();
    final links = _links;
    final description = _description;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Center(child: Image.asset('assets/images/logo_eidmaj.png', height: 90)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            tr('about_tagline'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        _card(
          title: tr('about_what_title'),
          icon: Icons.info_outline_rounded,
          child: Text(
            description.isNotEmpty ? description : tr('about_default_text'),
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ),
        if (email.isNotEmpty || phone.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card(
            title: tr('about_contact_title'),
            icon: Icons.mail_outline_rounded,
            child: Column(
              children: [
                if (email.isNotEmpty)
                  _linkTile(Icons.email_outlined, email, () => _open(Uri(scheme: 'mailto', path: email))),
                if (phone.isNotEmpty)
                  _linkTile(Icons.phone_outlined, phone,
                      () => _open(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')))),
              ],
            ),
          ),
        ],
        if (links.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card(
            title: tr('about_follow_title'),
            icon: Icons.share_outlined,
            child: Column(
              children: [
                for (final l in links)
                  _linkTile(
                    _iconFor(l['label']!, l['url']!),
                    l['label']!.isNotEmpty ? l['label']! : l['url']!,
                    () => _open(Uri.parse(l['url']!)),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _green, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _green)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _red.withAlpha(25),
        child: Icon(icon, color: _red, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
