import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/profile_service.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final storage = const FlutterSecureStorage();
    storage.read(key: 'user_id').then((id) {
      if (id == null) return;
      setState(() {
        _userDataFuture = ProfileService().fetchUserData(id);
      });
    });
  }

  void _openEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
    if (updated == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: _userDataFuture == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, dynamic>>(
                future: _userDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('حدث خطأ أثناء جلب البيانات', style: TextStyle(color: Colors.red, fontSize: 16)),
                    );
                  }
                  final data = snapshot.data ?? {};
                  return _buildProfile(data);
                },
              ),
      ),
    );
  }

  Widget _buildProfile(Map<String, dynamic> data) {
    final firstName = (data['first_name'] ?? '').toString().trim();
    final lastName = (data['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();
    final email = (data['email'] ?? '').toString().trim();
    final phone = (data['telephone'] ?? '').toString().trim();
    final city = (data['ville'] ?? '').toString().trim();
    final education = (data['niveau_scolaire'] ?? '').toString().trim();
    final age = (data['age'] ?? '').toString().trim();
    final initials = firstName.isNotEmpty ? firstName[0] : (email.isNotEmpty ? email[0].toUpperCase() : '?');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFFEF6C00),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل الملف الشخصي',
              onPressed: _openEdit,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Color(0xFFEF6C00),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName.isNotEmpty ? fullName : 'مستخدم إدماج',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Personal info card
                _buildCard(
                  title: 'المعلومات الشخصية',
                  icon: Icons.person,
                  color: const Color(0xFFEF6C00),
                  children: [
                    if (fullName.isNotEmpty) _infoTile(Icons.badge, 'الاسم الكامل', fullName),
                    if (age.isNotEmpty) _infoTile(Icons.cake, 'العمر', '$age سنة'),
                    if (city.isNotEmpty) _infoTile(Icons.location_city, 'المدينة', city),
                    if (education.isNotEmpty) _infoTile(Icons.school, 'المستوى الدراسي', education),
                  ],
                ),
                const SizedBox(height: 12),

                // Contact card
                _buildCard(
                  title: 'معلومات الاتصال',
                  icon: Icons.contact_phone,
                  color: const Color(0xFF1565C0),
                  children: [
                    if (email.isNotEmpty) _infoTile(Icons.email, 'البريد الإلكتروني', email),
                    if (phone.isNotEmpty) _infoTile(Icons.phone, 'رقم الهاتف', phone),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick stats
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF6C00).withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'نصيحة',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFE65100)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أكمل ملفك الشخصي لتحصل على توصيات أفضل وسيرة ذاتية غنية بالمعلومات!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('تعديل الملف الشخصي'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE65100),
                            side: const BorderSide(color: Color(0xFFEF6C00)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
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
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}