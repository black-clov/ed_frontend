import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/i18n/app_i18n.dart';
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
  List<dynamic>? _videos;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

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
        _adminService.getVideos(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _users = results[1] as List<dynamic>;
        _videos = results[2] as List<dynamic>;
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
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('adm_title')),
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: const Icon(Icons.dashboard), text: tr('adm_tab_stats')),
              Tab(icon: const Icon(Icons.people), text: tr('adm_tab_users')),
              Tab(icon: const Icon(Icons.video_library), text: tr('adm_tab_videos')),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${tr('adm_error_prefix')}$_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: Text(tr('adm_retry'))),
                    ],
                  ))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildUsersTab(),
                      _buildVideosTab(),
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
                _buildMetricCard(tr('adm_metric_total_users'), '${_stats!['totalUsers'] ?? 0}', Icons.people, Color(0xFFC62828)),
                const SizedBox(width: 12),
                _buildMetricCard(tr('adm_metric_active_7d'), '${_stats!['activeUsers7d'] ?? 0}', Icons.trending_up, Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // Features usage
            Text(tr('adm_features_usage'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      'questionnaires': tr('adm_feat_questionnaires'),
      'cvs': tr('adm_feat_cvs'),
      'interviews': tr('adm_feat_interviews'),
      'businessPlans': tr('adm_feat_businessPlans'),
      'pitches': tr('adm_feat_pitches'),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(labels[name] ?? name, style: const TextStyle(fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFC62828).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users == null || _users!.isEmpty) {
      return Center(child: Text(tr('adm_no_users')));
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
                backgroundColor: isAdmin ? Color(0xFFC62828) : Color(0xFFC62828),
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
                    tooltip: tr('adm_tooltip_details'),
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
                      PopupMenuItem(value: 'user', child: Text(tr('adm_role_regular_user_full'))),
                      PopupMenuItem(value: 'admin', child: Text(tr('adm_role_admin'))),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: '_delete',
                        child: Text(tr('adm_delete_user_action'), style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin ? Color(0xFFC62828).withAlpha(30) : Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? tr('adm_role_admin') : tr('adm_role_user'),
                        style: TextStyle(
                          color: isAdmin ? Color(0xFFB71C1C) : Colors.grey[700],
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

  Widget _buildVideosTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFC62828).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tr('adm_video_hint'),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: (_videos == null || _videos!.isEmpty)
                ? Center(child: Text(tr('adm_no_videos')))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _videos!.length,
                    itemBuilder: (context, index) {
                      final v = _videos![index] as Map<String, dynamic>;
                      final id = v['id']?.toString() ?? '';
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.play_arrow, color: Colors.white),
                          ),
                          title: Text(v['title']?.toString() ?? ''),
                          subtitle: Text(
                            v['category']?.toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: id.isEmpty
                                ? null
                                : () => _confirmDeleteVideo(id, v['title']?.toString() ?? ''),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteVideo(String id, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(tr('adm_delete_video_title')),
          content: Text('${tr('adm_delete_video_confirm_q')} "$title"؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('adm_cancel'))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(tr('adm_delete'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await _adminService.deleteVideo(id);
      await _loadData();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('adm_delete_video_failed'))),
      );
    }
  }

  Future<void> _showUserDetails(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: const Center(child: CircularProgressIndicator()),
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
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
                      color: Color(0xFFB71C1C),
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
                          _detailRow(tr('adm_detail_role'), user['role'] == 'admin' ? tr('adm_role_admin') : tr('adm_role_user')),
                          if (user['ville'] != null) _detailRow(tr('adm_detail_city'), user['ville']),
                          if (user['age'] != null) _detailRow(tr('adm_detail_age'), '${user['age']}'),
                          if (user['niveau_scolaire'] != null) _detailRow(tr('adm_detail_education'), user['niveau_scolaire']),
                          if (user['telephone'] != null) _detailRow(tr('adm_detail_phone'), user['telephone']),
                          const Divider(height: 24),
                          _sectionHeader(tr('adm_section_questionnaire')),
                          _sectionContent(sections['questionnaire']),
                          _sectionHeader(tr('adm_section_cv')),
                          _sectionContent(sections['cv']),
                          _sectionHeader(tr('adm_section_interviews')),
                          _sectionList(sections['interviews']),
                          _sectionHeader(tr('adm_section_business_plan')),
                          _sectionContent(sections['businessPlan']),
                          _sectionHeader(tr('adm_section_pitch')),
                          _sectionContent(sections['pitch']),
                          _sectionHeader(tr('adm_section_barriers')),
                          _sectionChips(sections['barriers']),
                          _sectionHeader(tr('adm_section_ent_barriers')),
                          _sectionChips(sections['entBarriers']),
                          _sectionHeader(tr('adm_section_needs')),
                          _sectionChips(sections['needs']),
                          _sectionHeader(tr('adm_section_sectors')),
                          _sectionChips(sections['sectors']),
                          _sectionHeader(tr('adm_section_skills')),
                          _sectionChips(sections['skills']),
                          _sectionHeader(tr('adm_section_comm_training')),
                          _sectionContent(sections['commTraining']),
                          _sectionHeader(tr('adm_section_ent_skills')),
                          _sectionContent(sections['entSkills']),
                          _sectionHeader(tr('adm_section_support')),
                          _sectionContent(sections['support']),
                          _sectionHeader(tr('adm_section_recommendation')),
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
                        child: Text(tr('adm_close')),
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
        SnackBar(content: Text('${tr('adm_error_load_details_prefix')}${e.toString()}')),
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
      child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
    );
  }

  Widget _sectionContent(dynamic data) {
    if (data == null) return Text(tr('adm_no_data'), style: const TextStyle(color: Colors.grey, fontSize: 12));
    if (data is Map) {
      final entries = data.entries.where((e) => e.key != 'id' && e.key != 'userId' && e.key != 'user_id').toList();
      if (entries.isEmpty) return Text(tr('adm_no_data'), style: const TextStyle(color: Colors.grey, fontSize: 12));
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
            final display = val is List ? val.join(tr('adm_list_sep')) : val?.toString() ?? '';
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
      return Text(tr('adm_no_data'), style: const TextStyle(color: Colors.grey, fontSize: 12));
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
      return Text(tr('adm_no_data'), style: const TextStyle(color: Colors.grey, fontSize: 12));
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
    final map = {
      'interests': tr('adm_field_interests'),
      'interestCategories': tr('adm_field_interest_categories'),
      'personalityAnswers': tr('adm_field_personality_answers'),
      'softSkillsAnswers': tr('adm_field_soft_skills_answers'),
      'workPreferences': tr('adm_field_work_preferences'),
      'payload': tr('adm_field_payload'),
      'targetRole': tr('adm_field_target_role'),
      'answers': tr('adm_field_answers'),
      'feedback': tr('adm_field_feedback'),
      'score': tr('adm_field_score'),
      'status': tr('adm_field_status'),
      'createdAt': tr('adm_field_created_at'),
      'projectName': tr('adm_field_project_name'),
      'description': tr('adm_field_description'),
      'valueProposition': tr('adm_field_value_proposition'),
      'targetCustomers': tr('adm_field_target_customers'),
      'costs': tr('adm_field_costs'),
      'firstSteps': tr('adm_field_first_steps'),
      'sector': tr('adm_field_sector'),
      'pitchText': tr('adm_field_pitch_text'),
      'barriers': tr('adm_field_barriers'),
      'needs': tr('adm_field_needs'),
      'sectors': tr('adm_field_sectors'),
      'skills': tr('adm_field_skills'),
      'ratings': tr('adm_field_ratings'),
      'completedModules': tr('adm_field_completed_modules'),
      'preferences': tr('adm_field_preferences'),
      'details': tr('adm_field_details'),
      'suggestedTraining': tr('adm_field_suggested_training'),
      'suggestedJobs': tr('adm_field_suggested_jobs'),
      'suggestedInternships': tr('adm_field_suggested_internships'),
      'notes': tr('adm_field_notes'),
      'scheduledAt': tr('adm_field_scheduled_at'),
      'interest_categories': tr('adm_field_interest_categories'),
      'personality_answers': tr('adm_field_personality_answers'),
      'soft_skills_answers': tr('adm_field_soft_skills_answers'),
      'work_preferences': tr('adm_field_work_preferences'),
      'target_role': tr('adm_field_target_role'),
      'project_name': tr('adm_field_project_name'),
      'value_proposition': tr('adm_field_value_proposition'),
      'target_customers': tr('adm_field_target_customers'),
      'first_steps': tr('adm_field_first_steps'),
      'pitch_text': tr('adm_field_pitch_text'),
      'created_at': tr('adm_field_created_at'),
      'scheduled_at': tr('adm_field_scheduled_at'),
      'completed_modules': tr('adm_field_completed_modules'),
      'suggested_training': tr('adm_field_suggested_training'),
      'suggested_jobs': tr('adm_field_suggested_jobs'),
      'suggested_internships': tr('adm_field_suggested_internships'),
    };
    return map[key] ?? key;
  }

  Future<void> _confirmDeleteUser(String userId, String email) async {
    if (userId.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(tr('adm_delete_user_action')),
          content: Text('${tr('adm_delete_user_confirm_prefix')}$email ؟\n${tr('adm_delete_user_confirm_suffix')}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('adm_cancel'))),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('adm_delete'), style: const TextStyle(color: Colors.red)),
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
        SnackBar(content: Text(tr('adm_delete_user_success'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('adm_delete_user_error_prefix')}${e.toString()}')),
      );
    }
  }

  Future<void> _changeRole(String userId, String role) async {
    try {
      await _adminService.updateUserRole(userId, role);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('adm_role_update_success'))),
      );
    } catch (e) {
      // Retry once on failure (handles Render cold starts)
      try {
        await Future.delayed(const Duration(seconds: 2));
        await _adminService.updateUserRole(userId, role);
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('adm_role_update_success'))),
        );
      } catch (e2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('adm_role_update_error_prefix')}${e2.toString()}')),
        );
      }
    }
  }

}

