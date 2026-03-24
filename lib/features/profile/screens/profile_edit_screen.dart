import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/profile_service.dart';
import '../../auth/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final _profileService = ProfileService();
  final _authService = AuthService();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _niveauCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Change password
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showPasswordSection = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _villeCtrl.dispose();
    _niveauCtrl.dispose();
    _telephoneCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final id = await _storage.read(key: 'user_id');
    if (id == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    _userId = id;
    try {
      final data = await _profileService.fetchUserData(id);
      _firstNameCtrl.text = (data['first_name'] ?? '').toString();
      _lastNameCtrl.text = (data['last_name'] ?? '').toString();
      _ageCtrl.text = (data['age'] ?? '').toString();
      _villeCtrl.text = (data['ville'] ?? '').toString();
      _niveauCtrl.text = (data['niveau_scolaire'] ?? '').toString();
      _telephoneCtrl.text = (data['telephone'] ?? '').toString();
      _emailCtrl.text = (data['email'] ?? '').toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: ${e.toString()}')),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _profileService.updateProfile(_userId!, {
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'age': _ageCtrl.text.trim(),
        'ville': _villeCtrl.text.trim(),
        'niveau_scolaire': _niveauCtrl.text.trim(),
        'telephone': _telephoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
      );
      Navigator.pop(context, true); // Return true to signal updated
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحفظ: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final resp = await _authService.changePassword(
        _currentPasswordCtrl.text,
        _newPasswordCtrl.text,
      );
      if (!mounted) return;
      if (resp.data != null && resp.data['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        setState(() => _showPasswordSection = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تغيير كلمة المرور')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تعديل الملف الشخصي'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(_firstNameCtrl, 'الاسم الأول', Icons.person),
                      _buildField(_lastNameCtrl, 'اسم العائلة', Icons.person_outline),
                      _buildField(_ageCtrl, 'العمر', Icons.cake, keyboard: TextInputType.number),
                      _buildField(_villeCtrl, 'المدينة', Icons.location_city),
                      _buildField(_niveauCtrl, 'المستوى الدراسي', Icons.school),
                      _buildField(_telephoneCtrl, 'رقم الهاتف', Icons.phone, keyboard: TextInputType.phone),
                      _buildField(_emailCtrl, 'البريد الإلكتروني', Icons.email, keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: _isSaving
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('تغيير كلمة المرور'),
                        trailing: Icon(_showPasswordSection ? Icons.expand_less : Icons.expand_more),
                        onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                      ),
                      if (_showPasswordSection) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _currentPasswordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور الحالية',
                            prefixIcon: Icon(Icons.lock_open),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور الجديدة',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isSaving ? null : _changePassword,
                            child: const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
      ),
    );
  }
}
