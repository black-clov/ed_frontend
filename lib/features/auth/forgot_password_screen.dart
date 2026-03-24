import 'package:flutter/material.dart';
import 'auth_service.dart';

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
  String? _resetToken; // For dev/testing — stored from response

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
      _showSnack('يرجى إدخال البريد الإلكتروني');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await _authService.requestPasswordReset(_emailController.text.trim());
      if (resp.data != null && resp.data['ok'] == true) {
        setState(() {
          _resetRequested = true;
          _resetToken = resp.data['resetToken'];
          if (_resetToken != null) {
            _tokenController.text = _resetToken!;
          }
        });
        _showSnack('تم إرسال رمز إعادة التعيين');
      } else {
        _showSnack('حدث خطأ، حاول مرة أخرى');
      }
    } catch (e) {
      _showSnack('حدث خطأ: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenController.text.trim().isEmpty) {
      _showSnack('يرجى إدخال رمز إعادة التعيين');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnack('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('كلمات المرور غير متطابقة');
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
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnack('رمز إعادة التعيين غير صالح أو منتهي الصلاحية');
      }
    } catch (e) {
      _showSnack('حدث خطأ: ${e.toString()}');
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        appBar: AppBar(
          title: const Text('استعادة كلمة المرور'),
          backgroundColor: const Color(0xFFE65100),
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
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_reset, size: 64, color: const Color(0xFFE65100)),
        const SizedBox(height: 16),
        const Text(
          'أدخل بريدك الإلكتروني لاستعادة كلمة المرور',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _requestReset,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('إرسال رمز إعادة التعيين', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text('العودة لتسجيل الدخول', style: TextStyle(color: const Color(0xFF2E7D32))),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.vpn_key, size: 64, color: const Color(0xFFE65100)),
        const SizedBox(height: 16),
        const Text(
          'أدخل رمز إعادة التعيين وكلمة المرور الجديدة',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _tokenController,
          decoration: const InputDecoration(
            labelText: 'رمز إعادة التعيين',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'كلمة المرور الجديدة',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'تأكيد كلمة المرور',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isLoading ? null : _resetPassword,
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _resetRequested = false),
          child: Text('العودة', style: TextStyle(color: const Color(0xFF2E7D32))),
        ),
      ],
    );
  }
}
