import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/api_service.dart';
import '../cv/screens/cv_preview_screen.dart';
import '../interview/screens/interview_prep_screen.dart';
import '../mentorship/screens/mentorship_screen.dart';
import '../needs/screens/needs_screen.dart';
import '../opportunities/screens/opportunities_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../recommendations/screens/recommendations_screen.dart';
import '../skills/screens/skills_screen.dart';
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
  String _gender = 'boy';
  String _userName = '';
  String _userVille = '';

  final _storage = const FlutterSecureStorage();

  final List<_DashboardSection> _employmentSections = [
    _DashboardSection('الملف الشخصي', Icons.person_outline_rounded,
        Color(0xFFE65100), ProfileScreen(), 'معلوماتك الشخصية'),
    _DashboardSection('المهارات', Icons.psychology_rounded,
        Color(0xFFEF6C00), SkillsScreen(), 'اكتشف مهاراتك'),
    _DashboardSection('الفرص المطابقة', Icons.work_outline_rounded,
        Color(0xFFF57C00), OpportunitiesScreen(), 'فرص تناسبك'),
    _DashboardSection('السيرة الذاتية', Icons.article_outlined,
        Color(0xFFFF8F00), CvPreviewScreen(), 'صايب CV ديالك'),
    _DashboardSection('تحضير المقابلات', Icons.record_voice_over_rounded,
        Color(0xFFE65100), InterviewPrepScreen(), 'جهز راسك'),
    _DashboardSection('كبسولات فيديو', Icons.play_circle_outline_rounded,
        Color(0xFFEF6C00), VideosScreen(), 'تعلم بالفيديو'),
    _DashboardSection('التوصيات', Icons.thumb_up_alt_outlined,
        Color(0xFFF57C00), RecommendationsScreen(), 'نصائح مخصصة'),
    _DashboardSection('الاحتياجات', Icons.checklist_rounded,
        Color(0xFFFF8F00), NeedsScreen(), 'شنو خاصك'),
    _DashboardSection('الإرشاد والمواكبة', Icons.groups_outlined,
        Color(0xFFE65100), MentorshipScreen(), 'كاين معامن'),
    _DashboardSection('المحتوى والمقالات', Icons.library_books_outlined,
        Color(0xFF1565C0), ContentScreen(), 'مقالات ودلائل'),
  ];

  final List<_DashboardSection> _entrepreneurshipSections = [
    _DashboardSection('القطاعات', Icons.category_outlined,
        Color(0xFF2E7D32), SectorsScreen(), 'اختر القطاع ديالك'),
    _DashboardSection('ريادة الأعمال', Icons.rocket_launch_outlined,
        Color(0xFF388E3C), EntrepreneurshipScreen(), 'روح المقاولة'),
    _DashboardSection('خطة العمل', Icons.lightbulb_outline_rounded,
        Color(0xFF43A047), BusinessPlanScreen(), 'بني المشروع'),
    _DashboardSection('تحضير Pitch', Icons.campaign_outlined,
        Color(0xFF2E7D32), PitchScreen(), 'قدم مشروعك'),
    _DashboardSection('العوائق', Icons.shield_outlined,
        Color(0xFF388E3C), EntBarriersScreen(), 'تغلب على العقبات'),
    _DashboardSection('الدعم', Icons.handshake_outlined,
        Color(0xFF43A047), SupportScreen(), 'شكون يعاونك'),
    _DashboardSection('تدريب التواصل', Icons.forum_outlined,
        Color(0xFF2E7D32), CommTrainingScreen(), 'طور التواصل'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _loadUserData().then((_) => _controller.forward());
  }

  Future<void> _loadUserData() async {
    final role = await _storage.read(key: 'role');
    final g = await _storage.read(key: 'gender');
    final userId = await _storage.read(key: 'user_id');

    if (mounted && role == 'admin') {
      setState(() => _isAdmin = true);
    }
    if (mounted && g != null) {
      setState(() => _gender = g);
    }

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
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade400, size: 24),
              const SizedBox(width: 8),
              const Text('تسجيل الخروج',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('واش بصح باغي تخرج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('لا، بقى',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('أيه، خرج',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await _storage.deleteAll();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _goToOnboarding() {
    Navigator.pushNamed(context, '/onboarding');
  }

  void _openSection(_DashboardSection section) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            section.screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 3;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                backgroundColor: const Color(0xFFE65100),
                automaticallyImplyLeading: false,
                title: null,
                actions: [
                  // Back to onboarding
                  _buildAppBarButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'تعديل خطوات الإعداد',
                    onPressed: _goToOnboarding,
                  ),
                  // Logout
                  _buildAppBarButton(
                    icon: Icons.logout_rounded,
                    tooltip: 'تسجيل الخروج',
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
                          Color(0xFFE65100),
                          Color(0xFFF4511E),
                          Color(0xFFFF6E40)
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
                                // Mascot avatar
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(40),
                                    border: Border.all(
                                        color: Colors.white.withAlpha(80),
                                        width: 2),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _gender == 'boy'
                                          ? 'assets/images/mascott_garcon.png'
                                          : 'assets/images/mascott_fille.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userName.isNotEmpty
                                            ? 'مرحبا $_userName!'
                                            : 'مرحبا بك!',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _userVille.isNotEmpty
                                            ? 'من $_userVille - اختر مسارك المهني'
                                            : 'اختر مسارك المهني وابدأ الرحلة',
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
                            // Quick action: edit onboarding
                            InkWell(
                              onTap: _goToOnboarding,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withAlpha(60)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_note_rounded,
                                        color: Colors.white.withAlpha(220),
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'عدّل خطوات الإعداد',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(220),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                      _buildPathHeader(
                        icon: Icons.business_center_rounded,
                        title: 'باب الخدمة',
                        subtitle: 'مسار التوظيف والتكوين المهني',
                        gradientColors: const [
                          Color(0xFFE65100),
                          Color(0xFFF57C00)
                        ],
                        imagePath: 'assets/images/porte_emploi.png',
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _employmentSections.length,
                        itemBuilder: (context, index) => _buildSectionCard(
                            _employmentSections[index], index),
                      ),

                      const SizedBox(height: 28),

                      // ══════ ENTREPRENEURSHIP PATH ══════
                      _buildPathHeader(
                        icon: Icons.rocket_launch_rounded,
                        title: 'باب المقاولة',
                        subtitle: 'مسار ريادة الأعمال والمشاريع',
                        gradientColors: const [
                          Color(0xFF2E7D32),
                          Color(0xFF43A047)
                        ],
                        imagePath:
                            'assets/images/porte_entreprenariat.png',
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entrepreneurshipSections.length,
                        itemBuilder: (context, index) =>
                            _buildSectionCard(
                                _entrepreneurshipSections[index], index),
                      ),

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
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
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
                    border:
                        Border.all(color: section.color.withAlpha(40)),
                  ),
                  child:
                      Icon(section.icon, color: section.color, size: 26),
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
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                    ),
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
          MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen()),
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
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة الإدارة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'إدارة المستخدمين والمحتوى',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 18),
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
      this.title, this.icon, this.color, this.screen, this.subtitle);
}
