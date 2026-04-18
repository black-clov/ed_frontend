import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _adminService = AdminService();
  late TabController _tabController;

  Map<String, dynamic>? _stats;
  List<dynamic>? _users;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _adminService.getStats(),
        _adminService.getUsers(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _users = results[1] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة الإدارة'),
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'الإحصائيات'),
              Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('خطأ: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
                    ],
                  ))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildUsersTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) return const SizedBox();
    final features = _stats!['features'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key metrics row
            Row(
              children: [
                _buildMetricCard('إجمالي المستخدمين', '${_stats!['totalUsers'] ?? 0}', Icons.people, Colors.blue),
                const SizedBox(width: 12),
                _buildMetricCard('نشطون (7 أيام)', '${_stats!['activeUsers7d'] ?? 0}', Icons.trending_up, Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // Features usage
            const Text('استخدام الميزات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...features.entries.map((e) => _buildFeatureRow(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String name, dynamic count) {
    final labels = {
      'questionnaires': 'الاستبيانات',
      'cvs': 'السير الذاتية',
      'interviews': 'المقابلات',
      'businessPlans': 'خطط الأعمال',
      'pitches': 'العروض التقديمية',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(labels[name] ?? name, style: const TextStyle(fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users == null || _users!.isEmpty) {
      return const Center(child: Text('لا يوجد مستخدمين'));
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _users!.length,
        itemBuilder: (context, index) {
          final user = _users![index] as Map<String, dynamic>;
          final isAdmin = user['role'] == 'admin';
          final uid = user['id']?.toString() ?? '';
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? Colors.orange : Colors.indigo,
                child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white, size: 20),
              ),
              title: Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()),
              subtitle: Text(user['email'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View details
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    tooltip: 'تفاصيل',
                    onPressed: uid.isEmpty ? null : () => _showUserDetails(uid),
                  ),
                  // Role badge + menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == '_delete') {
                        _confirmDeleteUser(uid, user['email'] ?? '');
                      } else if (uid.isNotEmpty) {
                        _changeRole(uid, value);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'user', child: Text('مستخدم عادي')),
                      const PopupMenuItem(value: 'admin', child: Text('مدير')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: '_delete',
                        child: Text('حذف المستخدم', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.orange.withAlpha(30) : Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? 'مدير' : 'مستخدم',
                        style: TextStyle(
                          color: isAdmin ? Colors.orange[800] : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showUserDetails(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final details = await _adminService.getUserDetails(userId);
      if (!mounted) return;
      Navigator.pop(context); // close loading

      final user = details['user'] as Map<String, dynamic>? ?? {};
      final sections = details['sections'] as Map<String, dynamic>? ?? {};

      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.8,
                maxWidth: 500,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[800],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(user['email'] ?? '', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13)),
                      ],
                    ),
                  ),
                  // Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow('الدور', user['role'] == 'admin' ? 'مدير' : 'مستخدم'),
                          if (user['ville'] != null) _detailRow('المدينة', user['ville']),
                          if (user['age'] != null) _detailRow('العمر', '${user['age']}'),
                          if (user['niveau_scolaire'] != null) _detailRow('المستوى الدراسي', user['niveau_scolaire']),
                          if (user['telephone'] != null) _detailRow('الهاتف', user['telephone']),
                          const Divider(height: 24),
                          _sectionHeader('الاستبيان'),
                          _sectionContent(sections['questionnaire']),
                          _sectionHeader('السيرة الذاتية'),
                          _sectionContent(sections['cv']),
                          _sectionHeader('المقابلات'),
                          _sectionList(sections['interviews']),
                          _sectionHeader('خطة العمل'),
                          _sectionContent(sections['businessPlan']),
                          _sectionHeader('العرض التقديمي'),
                          _sectionContent(sections['pitch']),
                          _sectionHeader('العوائق'),
                          _sectionChips(sections['barriers']),
                          _sectionHeader('عوائق المقاولة'),
                          _sectionChips(sections['entBarriers']),
                          _sectionHeader('الاحتياجات'),
                          _sectionChips(sections['needs']),
                          _sectionHeader('القطاعات'),
                          _sectionChips(sections['sectors']),
                          _sectionHeader('المهارات'),
                          _sectionChips(sections['skills']),
                          _sectionHeader('التدريب على التواصل'),
                          _sectionContent(sections['commTraining']),
                          _sectionHeader('مهارات المقاولة'),
                          _sectionContent(sections['entSkills']),
                          _sectionHeader('الدعم'),
                          _sectionContent(sections['support']),
                          _sectionHeader('التوصيات'),
                          _sectionContent(sections['recommendation']),
                        ],
                      ),
                    ),
                  ),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إغلاق'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل التفاصيل: ${e.toString()}')),
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo[800])),
    );
  }

  Widget _sectionContent(dynamic data) {
    if (data == null) return const Text('لا توجد بيانات', style: TextStyle(color: Colors.grey, fontSize: 12));
    if (data is Map) {
      final entries = data.entries.where((e) => e.key != 'id' && e.key != 'userId' && e.key != 'user_id').toList();
      if (entries.isEmpty) return const Text('لا توجد بيانات', style: TextStyle(color: Colors.grey, fontSize: 12));
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((e) {
            final val = e.value;
            final display = val is List ? val.join('، ') : val?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${_translateKey(e.key)}: $display', style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
        ),
      );
    }
    return Text(data.toString(), style: const TextStyle(fontSize: 12));
  }

  Widget _sectionList(dynamic data) {
    if (data == null || (data is List && data.isEmpty)) {
      return const Text('لا توجد بيانات', style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    if (data is List) {
      return Column(
        children: data.map<Widget>((item) => _sectionContent(item)).toList(),
      );
    }
    return _sectionContent(data);
  }

  Widget _sectionChips(dynamic data) {
    if (data == null || (data is List && data.isEmpty)) {
      return const Text('لا توجد بيانات', style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    if (data is List) {
      return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: data.map<Widget>((item) => Chip(
          label: Text(item.toString(), style: const TextStyle(fontSize: 11)),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )).toList(),
      );
    }
    return _sectionContent(data);
  }

  String _translateKey(String key) {
    const map = {
      'interests': 'الاهتمامات',
      'interestCategories': 'فئات الاهتمام',
      'personalityAnswers': 'إجابات الشخصية',
      'softSkillsAnswers': 'المهارات الناعمة',
      'workPreferences': 'تفضيلات العمل',
      'payload': 'البيانات',
      'targetRole': 'الدور المستهدف',
      'answers': 'الإجابات',
      'feedback': 'الملاحظات',
      'score': 'النتيجة',
      'status': 'الحالة',
      'createdAt': 'تاريخ الإنشاء',
      'projectName': 'اسم المشروع',
      'description': 'الوصف',
      'valueProposition': 'عرض القيمة',
      'targetCustomers': 'العملاء المستهدفون',
      'costs': 'التكاليف',
      'firstSteps': 'الخطوات الأولى',
      'sector': 'القطاع',
      'pitchText': 'نص العرض',
      'barriers': 'العوائق',
      'needs': 'الاحتياجات',
      'sectors': 'القطاعات',
      'skills': 'المهارات',
      'ratings': 'التقييمات',
      'completedModules': 'الوحدات المكتملة',
      'preferences': 'التفضيلات',
      'details': 'التفاصيل',
      'suggestedTraining': 'التكوين المقترح',
      'suggestedJobs': 'الوظائف المقترحة',
      'suggestedInternships': 'التدريبات المقترحة',
      'notes': 'ملاحظات',
      'scheduledAt': 'الموعد',
      'interest_categories': 'فئات الاهتمام',
      'personality_answers': 'إجابات الشخصية',
      'soft_skills_answers': 'المهارات الناعمة',
      'work_preferences': 'تفضيلات العمل',
      'target_role': 'الدور المستهدف',
      'project_name': 'اسم المشروع',
      'value_proposition': 'عرض القيمة',
      'target_customers': 'العملاء المستهدفون',
      'first_steps': 'الخطوات الأولى',
      'pitch_text': 'نص العرض',
      'created_at': 'تاريخ الإنشاء',
      'scheduled_at': 'الموعد',
      'completed_modules': 'الوحدات المكتملة',
      'suggested_training': 'التكوين المقترح',
      'suggested_jobs': 'الوظائف المقترحة',
      'suggested_internships': 'التدريبات المقترحة',
    };
    return map[key] ?? key;
  }

  Future<void> _confirmDeleteUser(String userId, String email) async {
    if (userId.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف المستخدم'),
          content: Text('هل أنت متأكد من حذف $email ؟\nسيتم حذف جميع بياناته نهائياً.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _adminService.deleteUser(userId);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحذف: ${e.toString()}')),
      );
    }
  }

  Future<void> _changeRole(String userId, String role) async {
    try {
      await _adminService.updateUserRole(userId, role);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الدور بنجاح')),
      );
    } catch (e) {
      // Retry once on failure (handles Render cold starts)
      try {
        await Future.delayed(const Duration(seconds: 2));
        await _adminService.updateUserRole(userId, role);
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الدور بنجاح')),
        );
      } catch (e2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تغيير الدور: ${e2.toString()}')),
        );
      }
    }
  }

}

