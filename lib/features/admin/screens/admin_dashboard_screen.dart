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
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? Colors.orange : Colors.indigo,
                child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white, size: 20),
              ),
              title: Text('${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()),
              subtitle: Text(user['email'] ?? ''),
              trailing: PopupMenuButton<String>(
                onSelected: (role) {
                  final uid = user['id'];
                  if (uid == null || uid.toString().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('خطأ: معرّف المستخدم غير متوفر')),
                    );
                    return;
                  }
                  _changeRole(uid.toString(), role);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'user', child: Text('مستخدم عادي')),
                  const PopupMenuItem(value: 'admin', child: Text('مدير')),
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
            ),
          );
        },
      ),
    );
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

