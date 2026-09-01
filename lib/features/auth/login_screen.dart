import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/i18n/language_toggle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();
  final storage = const FlutterSecureStorage();
  bool _googleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final result = await authService.signInWithGoogle();
      if (result == null) {
        setState(() => _googleLoading = false);
        return; // User cancelled
      }
      
      final token = result['access_token'];
      if (token != null) {
        await storage.write(key: 'token', value: token);
        final userId = result['userId'];
        if (userId != null) {
          await storage.write(key: 'user_id', value: userId.toString());
        }
        final role = result['role'];
        if (role != null) {
          await storage.write(key: 'role', value: role.toString());
        }
        if (!mounted) return;
        final onboardingDone = await storage.read(key: 'onboarding_done');
        if (!mounted) return;
        if (role == 'admin' || onboardingDone == 'true') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorPopup(tr('google_login_failed'));
    }
    if (mounted) setState(() => _googleLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorPopup(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFC62828)),
              const SizedBox(width: 8),
              Text(tr('error'), style: const TextStyle(color: Color(0xFFC62828))),
            ],
          ),
          content: Text(msg, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('ok'), style: const TextStyle(color: Color(0xFFC62828))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showErrorPopup(tr('fill_all_fields'));
      return;
    }
    try {
      final response = await authService.login(
        emailController.text,
        passwordController.text
      );
      debugPrint('Login response: ${response.statusCode} ${response.data}');
      // Check for HTTP 200 and access_token in response
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null && response.data["access_token"] != null) {
        final token = response.data["access_token"];
        await storage.write(
          key: "token",
          value: token
        );
        // Store userId and role from login response
        final userId = response.data["userId"];
        if (userId != null) {
          await storage.write(key: "user_id", value: userId.toString());
        }
        final role = response.data["role"];
        if (role != null) {
          await storage.write(key: "role", value: role.toString());
        }
        if (!mounted) return;
        // Admin users skip onboarding; regular users must complete it
        final onboardingDone = await storage.read(key: 'onboarding_done');
        if (!mounted) return;
        if (role == 'admin' || onboardingDone == 'true') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardScreen()
            )
          );
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        if (!mounted) return;
        _showErrorPopup(tr('invalid_credentials'));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 401) {
        _showErrorPopup(tr('invalid_credentials'));
      } else {
        _showErrorPopup(tr('server_unreachable'));
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorPopup(tr('unexpected_error'));
    }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LanguageToggle(),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/logo_eidmaj.png',
                  height: 80,
                ),
                  const SizedBox(height: 16),
                  Text(
                    tr('login'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('login_subtitle'),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: tr('email'),
                              prefixIcon: Icon(Icons.email, color: const Color(0xFFC62828)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: tr('password'),
                              prefixIcon: Icon(Icons.lock, color: const Color(0xFFC62828)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: login,
                              child: Text(tr('login_btn'), style: const TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFC62828), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _googleLoading ? null : _handleGoogleSignIn,
                              icon: _googleLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)))
                                  : const Icon(Icons.g_mobiledata, color: Color(0xFFC62828), size: 28),
                              label: Text(
                                tr('google_login'),
                                style: TextStyle(fontSize: 16, color: _googleLoading ? Colors.grey : const Color(0xFFC62828)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Text(
                                tr('forgot_password_q'),
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tr('no_account'), style: const TextStyle(fontSize: 15)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          tr('create_account'),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  }

}