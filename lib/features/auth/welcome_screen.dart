import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';
import '../onboarding/gender_welcome_screen.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/i18n/language_toggle.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnack(tr('fill_email_password'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data['access_token'] != null) {
        await _storage.write(key: 'token', value: response.data['access_token']);
        final userId = response.data['userId'];
        if (userId != null) await _storage.write(key: 'user_id', value: userId.toString());
        final role = response.data['role'];
        if (role != null) await _storage.write(key: 'role', value: role.toString());
        if (!mounted) return;
        final onboardingDone = await _storage.read(key: 'onboarding_done');
        if (!mounted) return;
        if (role == 'admin' || onboardingDone == 'true') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        _showSnack(tr('invalid_credentials'));
      }
    } catch (e) {
      _showSnack(tr('login_error'));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _selectGender(String gender) async {
    await _storage.write(key: 'gender', value: gender);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GenderWelcomeScreen(gender: gender)),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final data = await _authService.signInWithGoogle();
      if (data != null && data['access_token'] != null) {
        await _storage.write(key: 'token', value: data['access_token']);
        final userId = data['userId'];
        if (userId != null) await _storage.write(key: 'user_id', value: userId.toString());
        final role = data['role'];
        if (role != null) await _storage.write(key: 'role', value: role.toString());
        if (!mounted) return;
        final onboardingDone = await _storage.read(key: 'onboarding_done');
        if (!mounted) return;
        if (role == 'admin' || onboardingDone == 'true') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        _showSnack(tr('google_failed'));
      }
    } catch (e) {
      _showSnack(tr('google_error'));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Language toggle (top)
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LanguageToggle(),
              ),
              Image.asset('assets/images/logo_eidmaj.png', height: 100),
              const SizedBox(height: 8),
              Text(
                tr('welcome_title'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 20),

              // --- LOGIN SECTION ---
              _sectionDivider(tr('login')),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: tr('email'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: tr('password'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(tr('login_btn'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                  child: Text(tr('forgot_password_q'), style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                ),
              ),
              const SizedBox(height: 12),

              // --- NEW ACCOUNT SECTION ---
              _sectionDivider(tr('new_account')),
              const SizedBox(height: 10),
              Text(
                tr('choose_gender'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _selectGender('boy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(tr('boy'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _selectGender('girl'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(tr('girl'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                tr('enter_info_start'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              // Google button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  label: Text(tr('google_signin'), style: const TextStyle(color: Colors.black87, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFC62828), thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
        ),
        Expanded(child: Divider(color: const Color(0xFFC62828), thickness: 1.5)),
      ],
    );
  }
}
