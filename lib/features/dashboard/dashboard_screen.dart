import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/i18n/app_i18n.dart';
import '../../core/i18n/language_toggle.dart';
import '../../services/api_service.dart';
import '../cv/screens/cv_preview_screen.dart';
import '../interview/screens/interview_prep_screen.dart';
import '../mentorship/screens/mentorship_screen.dart';
import '../needs/screens/needs_screen.dart';
import '../opportunities/screens/opportunities_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../recommendations/screens/recommendations_screen.dart';
import '../skills/screens/skills_screen.dart';
import '../interests/screens/interests_screen.dart';
import '../questionnaire/screens/questionnaire_screen.dart';
import '../softskills/screens/soft_skills_screen.dart';
import '../videos/screens/videos_screen.dart';
import '../sectors/screens/sectors_screen.dart';
import '../entrepreneurship/screens/entrepreneurship_screen.dart';
import '../businessplan/screens/businessplan_screen.dart';
import '../pitch/screens/pitch_screen.dart';
import '../entbarriers/screens/ent_barriers_screen.dart';
import '../support/screens/support_screen.dart';
import '../commtraining/screens/comm_training_screen.dart';
import '../admin/screens/admin_dashboard_screen.dart';
import '../content/screens/content_screen.dart';
import '../onboarding/track_portal.dart';
import '../about/about_screen.dart';
import '../../services/session.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isAdmin = false;
  String? _gender;
  /// 'employment' | 'entrepreneurship' | 'both' | null (treated as both).
  String? _track;
  String _userName = '';
  String _userVille = '';

  final _storage = const FlutterSecureStorage();

  List<_DashboardSection> get _employmentSections => [
    _DashboardSection(
      tr('dash_sec_profile_title'),
      Icons.person_outline_rounded,
      Color(0xFFC62828),
      ProfileScreen(),
      tr('dash_sec_profile_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_skills_title'),
      Icons.psychology_rounded,
      Color(0xFFC62828),
      SkillsScreen(),
      tr('dash_sec_skills_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_interests_title'),
      Icons.interests_outlined,
      Color(0xFFC62828),
      InterestsScreen(),
      tr('dash_sec_interests_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_personality_title'),
      Icons.emoji_people_rounded,
      Color(0xFFC62828),
      QuestionnaireScreen(),
      tr('dash_sec_personality_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_softskills_title'),
      Icons.self_improvement_rounded,
      Color(0xFFC62828),
      SoftSkillsScreen(),
      tr('dash_sec_softskills_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_opportunities_title'),
      Icons.work_outline_rounded,
      Color(0xFFC62828),
      OpportunitiesScreen(),
      tr('dash_sec_opportunities_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_cv_title'),
      Icons.article_outlined,
      Color(0xFFC62828),
      CvPreviewScreen(),
      tr('dash_sec_cv_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_interview_title'),
      Icons.record_voice_over_rounded,
      Color(0xFFC62828),
      InterviewPrepScreen(),
      tr('dash_sec_interview_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_videos_title'),
      Icons.play_circle_outline_rounded,
      Color(0xFFC62828),
      VideosScreen(),
      tr('dash_sec_videos_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_recommendations_title'),
      Icons.thumb_up_alt_outlined,
      Color(0xFFC62828),
      RecommendationsScreen(),
      tr('dash_sec_recommendations_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_needs_title'),
      Icons.checklist_rounded,
      Color(0xFFC62828),
      NeedsScreen(),
      tr('dash_sec_needs_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_mentorship_title'),
      Icons.groups_outlined,
      Color(0xFFC62828),
      MentorshipScreen(),
      tr('dash_sec_mentorship_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_content_title'),
      Icons.library_books_outlined,
      Color(0xFFC62828),
      ContentScreen(),
      tr('dash_sec_content_subtitle'),
    ),
  ];

  List<_DashboardSection> get _entrepreneurshipSections => [
    _DashboardSection(
      tr('dash_sec_sectors_title'),
      Icons.category_outlined,
      Color(0xFF2E7D32),
      SectorsScreen(),
      tr('dash_sec_sectors_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_entrepreneurship_title'),
      Icons.rocket_launch_outlined,
      Color(0xFF388E3C),
      EntrepreneurshipScreen(),
      tr('dash_sec_entrepreneurship_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_businessplan_title'),
      Icons.lightbulb_outline_rounded,
      Color(0xFF43A047),
      BusinessPlanScreen(),
      tr('dash_sec_businessplan_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_pitch_title'),
      Icons.campaign_outlined,
      Color(0xFF2E7D32),
      PitchScreen(),
      tr('dash_sec_pitch_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_barriers_title'),
      Icons.shield_outlined,
      Color(0xFF388E3C),
      EntBarriersScreen(),
      tr('dash_sec_barriers_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_support_title'),
      Icons.handshake_outlined,
      Color(0xFF43A047),
      SupportScreen(),
      tr('dash_sec_support_subtitle'),
    ),
    _DashboardSection(
      tr('dash_sec_commtraining_title'),
      Icons.forum_outlined,
      Color(0xFF2E7D32),
      CommTrainingScreen(),
      tr('dash_sec_commtraining_subtitle'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadUserData().then((_) => _controller.forward());
  }

  bool get _showEmployment =>
      _track == null || _track == Tracks.employment || _track == Tracks.both;
  bool get _showEntrepreneurship =>
      _track == null || _track == Tracks.entrepreneurship || _track == Tracks.both;

  Future<void> _loadPrefsFromStorage() async {
    final g = await Session.gender();
    final t = await Session.track();
    if (!mounted) return;
    setState(() {
      _gender = (g == 'boy' || g == 'girl') ? g : null;
      _track = (t != null && t.isNotEmpty) ? t : null;
    });
  }

  Future<void> _loadUserData() async {
    final role = await _storage.read(key: 'role');
    final userId = await _storage.read(key: 'user_id');

    if (mounted && role == 'admin') {
      setState(() => _isAdmin = true);
    }
    await _loadPrefsFromStorage();
    // Server copy wins (set on another phone, or after reinstall).
    Session.refreshPrefs().then((_) async {
      await _loadPrefsFromStorage();
      // Users from v1.0.0 never picked a track: show the portal once.
      if (mounted && !_isAdmin && _track == null) _changeTrack();
    });

    if (userId != null) {
      try {
        final api = ApiService();
        final response = await api.get('/users/$userId');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          final firstName = (data['first_name'] ?? '').toString().trim();
          final ville = (data['ville'] ?? '').toString().trim();
          if (mounted) {
            setState(() {
              _userName = firstName;
              _userVille = ville;
            });
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade400, size: 24),
              const SizedBox(width: 8),
              Text(
                tr('dash_logout_dialog_title'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(tr('dash_logout_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                tr('dash_logout_cancel'),
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                tr('dash_logout_confirm_btn'),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await Session.clear();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _goToOnboarding() {
    Navigator.pushNamed(context, '/onboarding');
  }

  Future<void> _changeTrack() async {
    final chosen = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => TrackPortalScreen(current: _track)),
    );
    if (chosen != null && mounted) setState(() => _track = chosen);
  }

  void _openAbout() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
  }

  Future<void> _pickMascot() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('onb_choose_mascot'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final g in const ['boy', 'girl'])
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(ctx, g),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _gender == g ? const Color(0xFFC62828) : Colors.grey.shade300,
                              width: _gender == g ? 2.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                g == 'boy'
                                    ? 'assets/images/mascott_garcon.png'
                                    : 'assets/images/mascott_fille.png',
                                height: 110,
                              ),
                              const SizedBox(height: 6),
                              Text(tr(g), style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null) return;
    setState(() => _gender = chosen);
    await Session.setGender(chosen);
  }

  void _openSection(_DashboardSection section) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => section.screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 0.08),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Collapsible App Bar
            SliverAppBar(
              expandedHeight: 230,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFC62828),
              automaticallyImplyLeading: false,
              title: null,
              actions: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: LanguageToggle(),
                ),
                // Back to onboarding
                _buildAppBarButton(
                  icon: Icons.tune_rounded,
                  tooltip: tr('dash_edit_steps_tooltip'),
                  onPressed: _goToOnboarding,
                ),
                // Logout
                _buildAppBarButton(
                  icon: Icons.logout_rounded,
                  tooltip: tr('dash_logout_tooltip'),
                  onPressed: () => _showLogoutDialog(context),
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFC62828),
                        Color(0xFFC62828),
                        Color(0xFFC62828),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Mascot avatar (tap to change)
                              GestureDetector(
                                onTap: _pickMascot,
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(40),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(80),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _gender == null
                                        ? const Icon(Icons.person_add_alt_1_rounded,
                                            color: Colors.white, size: 36)
                                        : Image.asset(
                                            _gender == 'boy'
                                                ? 'assets/images/mascott_garcon.png'
                                                : 'assets/images/mascott_fille.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName.isNotEmpty
                                          ? '${tr('dash_hello')} $_userName!'
                                          : tr('dash_welcome'),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userVille.isNotEmpty
                                          ? '${tr('dash_from_prefix')} $_userVille ${tr('dash_choose_path_suffix')}'
                                          : tr('dash_choose_path_start'),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(200),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Quick actions: switch track (the "portal") + about
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildHeaderAction(
                                  icon: Icons.door_front_door_outlined,
                                  label: tr('dash_change_track'),
                                  onTap: _changeTrack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _buildHeaderAction(
                                  icon: Icons.info_outline_rounded,
                                  label: tr('about_title'),
                                  onTap: _openAbout,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Body Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ══════ EMPLOYMENT PATH ══════
                    if (_showEmployment) ...[
                    _buildPathHeader(
                      icon: Icons.business_center_rounded,
                      title: tr('dash_employment_path_title'),
                      subtitle: tr('dash_employment_path_subtitle'),
                      gradientColors: const [
                        Color(0xFFC62828),
                        Color(0xFFC62828),
                      ],
                      imagePath: 'assets/images/porte_emploi.png',
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _employmentSections.length,
                      itemBuilder: (context, index) =>
                          _buildSectionCard(_employmentSections[index], index),
                    ),
                    ],

                    if (_showEmployment && _showEntrepreneurship)
                      const SizedBox(height: 28),

                    // ══════ ENTREPRENEURSHIP PATH ══════
                    if (_showEntrepreneurship) ...[
                    _buildPathHeader(
                      icon: Icons.rocket_launch_rounded,
                      title: tr('dash_entrepreneurship_path_title'),
                      subtitle: tr('dash_entrepreneurship_path_subtitle'),
                      gradientColors: const [
                        Color(0xFF2E7D32),
                        Color(0xFF43A047),
                      ],
                      imagePath: 'assets/images/porte_entreprenariat.png',
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _entrepreneurshipSections.length,
                      itemBuilder: (context, index) => _buildSectionCard(
                        _entrepreneurshipSections[index],
                        index,
                      ),
                    ),
                    ],

                    // Admin
                    if (_isAdmin) ...[
                      const SizedBox(height: 28),
                      _buildAdminCard(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(60)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white.withAlpha(220), size: 19),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(230),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPathHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withAlpha(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(_DashboardSection section, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSection(section),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: section.color.withAlpha(30)),
              boxShadow: [
                BoxShadow(
                  color: section.color.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        section.color.withAlpha(30),
                        section.color.withAlpha(15),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: section.color.withAlpha(40)),
                  ),
                  child: Icon(section.icon, color: section.color, size: 26),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    section.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: section.color,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    section.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF37474F), Color(0xFF546E7A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37474F).withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('dash_admin_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('dash_admin_subtitle'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  final String subtitle;
  const _DashboardSection(
    this.title,
    this.icon,
    this.color,
    this.screen,
    this.subtitle,
  );
}
