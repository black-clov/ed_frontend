import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../../core/i18n/app_i18n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _resetRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnack(tr('auth_email_required'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await _authService.requestPasswordReset(_emailController.text.trim());
      if (resp.data != null && resp.data['ok'] == true) {
        setState(() => _resetRequested = true);
        _showSnack(tr('auth_reset_link_sent'));
      } else {
        _showSnack(tr('auth_reset_request_error'));
      }
    } catch (e) {
      _showSnack(tr('auth_connection_error'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenController.text.trim().isEmpty) {
      _showSnack(tr('auth_token_required'));
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnack(tr('auth_new_password_min_length'));
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack(tr('auth_passwords_mismatch'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await _authService.resetPassword(
        _tokenController.text.trim(),
        _newPasswordController.text,
      );
      if (resp.data != null && resp.data['ok'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('auth_password_changed_success'))),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnack(tr('auth_invalid_or_expired_token'));
      }
    } catch (e) {
      _showSnack(tr('auth_generic_error'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        title: Text(tr('auth_forgot_password_title')),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: _resetRequested ? _buildResetForm() : _buildEmailForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_reset, size: 64, color: const Color(0xFFC62828)),
        const SizedBox(height: 16),
        Text(
          tr('auth_enter_email_instruction'),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: tr('email'),
            prefixIcon: const Icon(Icons.email),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _requestReset,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(tr('auth_send_reset_code'), style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(tr('auth_back_to_login'), style: TextStyle(color: const Color(0xFF2E7D32))),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.vpn_key, size: 64, color: const Color(0xFFC62828)),
        const SizedBox(height: 16),
        Text(
          tr('auth_enter_token_instruction'),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _tokenController,
          decoration: InputDecoration(
            labelText: tr('auth_reset_code_label'),
            prefixIcon: const Icon(Icons.code),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: tr('auth_new_password_label'),
            prefixIcon: const Icon(Icons.lock),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: tr('auth_confirm_password_label'),
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _resetPassword,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(tr('auth_change_password_btn'), style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _resetRequested = false),
          child: Text(tr('auth_back'), style: TextStyle(color: const Color(0xFF2E7D32))),
        ),
      ],
    );
  }
}
