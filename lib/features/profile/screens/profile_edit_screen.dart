import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/profile_service.dart';
import '../../auth/auth_service.dart';
import '../../../core/i18n/app_i18n.dart';

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
        SnackBar(content: Text('${tr('emp1_edit_load_error')}: ${e.toString()}')),
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
        SnackBar(content: Text(tr('emp1_edit_update_success'))),
      );
      Navigator.pop(context, true); // Return true to signal updated
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('emp1_edit_save_error')}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('emp1_edit_password_min_length'))),
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
          SnackBar(content: Text(tr('emp1_edit_password_change_success'))),
        );
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        setState(() => _showPasswordSection = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('emp1_edit_password_change_failed'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('emp1_edit_generic_error_prefix')}: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('emp1_profile_edit_tooltip')),
        backgroundColor: const Color(0xFFB71C1C),
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
                    _buildField(_firstNameCtrl, tr('emp1_field_first_name'), Icons.person),
                    _buildField(_lastNameCtrl, tr('emp1_field_last_name'), Icons.person_outline),
                    _buildField(_ageCtrl, tr('emp1_profile_age'), Icons.cake, keyboard: TextInputType.number),
                    _buildField(_villeCtrl, tr('emp1_profile_city'), Icons.location_city),
                    _buildField(_niveauCtrl, tr('emp1_profile_education_level'), Icons.school),
                    _buildField(_telephoneCtrl, tr('emp1_profile_phone'), Icons.phone, keyboard: TextInputType.phone),
                    _buildField(_emailCtrl, tr('emp1_profile_email'), Icons.email, keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: _isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(tr('emp1_edit_save_changes_btn'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text(tr('emp1_edit_change_password_title')),
                      trailing: Icon(_showPasswordSection ? Icons.expand_less : Icons.expand_more),
                      onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                    ),
                    if (_showPasswordSection) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _currentPasswordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: tr('emp1_edit_current_password'),
                          prefixIcon: const Icon(Icons.lock_open),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: tr('emp1_edit_new_password'),
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSaving ? null : _changePassword,
                          child: Text(tr('emp1_edit_change_password_title'), style: const TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
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
        validator: (v) => (v == null || v.trim().isEmpty) ? tr('emp1_field_required') : null,
      ),
    );
  }
}
