import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
import '../../services/session.dart';

const _red = Color(0xFFC62828);
const _green = Color(0xFF2E7D32);

/// The "portal": the young person picks which door to go through —
/// Employment, Entrepreneurship, or both. Used inside onboarding and from the
/// dashboard ("Changer de parcours").
class TrackPortal extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final String? current;

  const TrackPortal({super.key, required this.onSelected, this.current});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Image.asset('assets/images/logo_eidmaj.png', height: 64),
          const SizedBox(height: 18),
          Text(
            tr('portal_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _red),
          ),
          const SizedBox(height: 6),
          Text(
            tr('portal_subtitle'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DoorCard(
                  image: 'assets/images/porte_emploi.png',
                  title: tr('portal_employment'),
                  subtitle: tr('portal_employment_sub'),
                  icon: Icons.business_center_rounded,
                  color: _red,
                  selected: current == Tracks.employment,
                  onTap: () => onSelected(Tracks.employment),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DoorCard(
                  image: 'assets/images/porte_entreprenariat.png',
                  title: tr('portal_entrepreneurship'),
                  subtitle: tr('portal_entrepreneurship_sub'),
                  icon: Icons.rocket_launch_rounded,
                  color: _green,
                  selected: current == Tracks.entrepreneurship,
                  onTap: () => onSelected(Tracks.entrepreneurship),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => onSelected(Tracks.both),
              icon: Icon(
                current == Tracks.both ? Icons.check_circle_rounded : Icons.compare_arrows_rounded,
                color: Colors.black87,
              ),
              label: Text(
                tr('portal_both'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: current == Tracks.both ? Colors.black87 : Colors.grey.shade400,
                  width: current == Tracks.both ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr('portal_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _DoorCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DoorCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 6 : 2,
      shadowColor: color.withAlpha(80),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : color.withAlpha(50), width: selected ? 3 : 1),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stand-alone portal page, opened from the dashboard to switch track.
/// Pops with the chosen track (already saved locally and on the server).
class TrackPortalScreen extends StatelessWidget {
  final String? current;
  const TrackPortalScreen({super.key, this.current});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        foregroundColor: _red,
        title: Text(tr('portal_change_title'), style: const TextStyle(color: _red, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: TrackPortal(
          current: current,
          onSelected: (track) async {
            await Session.setTrack(track);
            if (context.mounted) Navigator.pop(context, track);
          },
        ),
      ),
    );
  }
}
