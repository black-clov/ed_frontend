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
    final storage = FlutterSecureStorage();
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
      _loadData(); // Refresh after edit
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل',
              onPressed: _openEdit,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _userDataFuture == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<Map<String, dynamic>>(
                  future: _userDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('حدث خطأ أثناء جلب البيانات', style: TextStyle(color: Colors.red));
                    }
                    final data = snapshot.data ?? {};
                    final firstName = (data['first_name'] ?? '').toString().trim();
                    final lastName = (data['last_name'] ?? '').toString().trim();
                    final age = (data['age'] ?? '').toString().trim();
                    final ville = (data['ville'] ?? '').toString().trim();
                    final niveau = (data['niveau_scolaire'] ?? '').toString().trim();
                    final telephone = (data['telephone'] ?? '').toString().trim();
                    final email = (data['email'] ?? '').toString().trim();
                    if (firstName.isEmpty && lastName.isEmpty && email.isEmpty) {
                      return Text('لا يوجد بيانات لهذا المستخدم\n\nبيانات الخادم: $data', style: const TextStyle(fontSize: 16));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم: $firstName $lastName', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('العمر: $age', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('المدينة: $ville', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('المستوى الدراسي: $niveau', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('رقم الهاتف: $telephone', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('البريد الإلكتروني: $email', style: const TextStyle(fontSize: 18)),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
