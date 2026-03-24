import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isAdmin = false;
  String _gender = 'boy';

  // Employment-path sections (orange theme)
  final List<_DashboardSection> _employmentSections = [
    _DashboardSection('الملف الشخصي', Icons.person, const Color(0xFFE65100), const ProfileScreen()),
    _DashboardSection('المهارات', Icons.star, const Color(0xFFE65100), const SkillsScreen()),
    _DashboardSection('الفرص المطابقة', Icons.auto_awesome, const Color(0xFFE65100), const OpportunitiesScreen()),
    _DashboardSection('السيرة الذاتية', Icons.description, const Color(0xFFE65100), const CvPreviewScreen()),
    _DashboardSection('المقابلات', Icons.record_voice_over, const Color(0xFFE65100), const InterviewPrepScreen()),
    _DashboardSection('الفيديوهات', Icons.play_circle, const Color(0xFFE65100), const VideosScreen()),
    _DashboardSection('التوصيات', Icons.recommend, const Color(0xFFE65100), const RecommendationsScreen()),
    _DashboardSection('الاحتياجات', Icons.assignment, const Color(0xFFE65100), const NeedsScreen()),
    _DashboardSection('الإرشاد', Icons.school, const Color(0xFFE65100), const MentorshipScreen()),
  ];

  // Entrepreneurship-path sections (green theme)
  final List<_DashboardSection> _entrepreneurshipSections = [
    _DashboardSection('القطاعات', Icons.category, const Color(0xFF2E7D32), const SectorsScreen()),
    _DashboardSection('ريادة الأعمال', Icons.rocket_launch, const Color(0xFF2E7D32), const EntrepreneurshipScreen()),
    _DashboardSection('خطة العمل', Icons.lightbulb, const Color(0xFF2E7D32), const BusinessPlanScreen()),
    _DashboardSection('تحضير Pitch', Icons.mic, const Color(0xFF2E7D32), const PitchScreen()),
    _DashboardSection('عوائق ريادة الأعمال', Icons.block, const Color(0xFF2E7D32), const EntBarriersScreen()),
    _DashboardSection('تفضيلات الدعم', Icons.support_agent, const Color(0xFF2E7D32), const SupportScreen()),
    _DashboardSection('تدريب التواصل', Icons.forum, const Color(0xFF2E7D32), const CommTrainingScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkAdmin().then((_) => _controller.forward());
    _loadGender();
  }

  Future<void> _loadGender() async {
    final storage = const FlutterSecureStorage();
    final g = await storage.read(key: 'gender');
    if (g != null && mounted) setState(() => _gender = g);
  }

  Future<void> _checkAdmin() async {
    final storage = const FlutterSecureStorage();
    final role = await storage.read(key: 'role');
    debugPrint('Dashboard _checkAdmin: role=$role');
    if (!mounted) return;
    if (role == 'admin' && !_isAdmin) {
      setState(() { _isAdmin = true; });
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
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _openSection(_DashboardSection section) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => section.screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE65100),
          title: Image.asset('assets/images/logo_eidmaj.png', height: 36),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'تسجيل الخروج',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome header with mascot
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'مرحباً بك في إدماج!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'اختر مسارك المهني',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(_gender == 'boy' ? 'assets/images/mascott_garcon.png' : 'assets/images/mascott_fille.png', height: 70),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Employment path (باب الخدمة)
                  _buildPathHeader(
                    'assets/images/porte_emploi.png',
                    'باب الخدمة',
                    const Color(0xFFE65100),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: _employmentSections.map((s) => _buildSectionCard(s)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Entrepreneurship path (باب المقاولة)
                  _buildPathHeader(
                    'assets/images/porte_entreprenariat.png',
                    'باب المقاولة',
                    const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: _entrepreneurshipSections.map((s) => _buildSectionCard(s)).toList(),
                  ),

                  // Admin section
                  if (_isAdmin) ...[
                    const SizedBox(height: 24),
                    _buildSectionCard(const _DashboardSection('إدارة', Icons.admin_panel_settings, Color(0xFF37474F), AdminDashboardScreen())),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildPathHeader(String imagePath, String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, height: 60),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(_DashboardSection section) {
    return InkWell(
      onTap: () => _openSection(section),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: section.color.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: section.color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(section.icon, color: section.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              section.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: section.color,
              ),
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
  const _DashboardSection(this.title, this.icon, this.color, this.screen);
}