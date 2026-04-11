import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';

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
  String _gender = 'boy';
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGender();
  }

  Future<void> _loadGender() async {
    final g = await storage.read(key: 'gender');
    if (g != null && mounted) setState(() => _gender = g);
  }

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
      _showErrorPopup('فشل تسجيل الدخول بـ Google. حاول مرة أخرى.');
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE65100)),
            SizedBox(width: 8),
            Text('خطأ', style: TextStyle(color: Color(0xFFE65100))),
          ],
        ),
        content: Text(msg, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنا', style: TextStyle(color: Color(0xFFE65100))),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showErrorPopup('يرجى ملء جميع الحقول');
      return;
    }
    try {
      final response = await authService.login(
        emailController.text,
        passwordController.text
      );
      print('Login response: \\${response.statusCode} \\${response.data}');
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
        _showErrorPopup('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorPopup('حدث خطأ في الاتصال. حاول مرة أخرى.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_eidmaj.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بياناتك للمتابعة',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  Image.asset(
                    _gender == 'boy' ? 'assets/images/mascott_garcon.png' : 'assets/images/mascott_fille.png',
                    height: 160,
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
                              labelText: "البريد الإلكتروني",
                              prefixIcon: Icon(Icons.email, color: const Color(0xFFE65100)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "كلمة المرور",
                              prefixIcon: Icon(Icons.lock, color: const Color(0xFFE65100)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE65100),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: login,
                              child: const Text("تسجيل الدخول", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFDB4437), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _googleLoading ? null : _handleGoogleSignIn,
                              icon: _googleLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDB4437)))
                                  : const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 28),
                              label: Text(
                                "تسجيل الدخول بـ Google",
                                style: TextStyle(fontSize: 16, color: _googleLoading ? Colors.grey : const Color(0xFFDB4437)),
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
                                "نسيت كلمة المرور؟",
                                style: TextStyle(
                                  color: const Color(0xFF2E7D32),
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
                      const Text("ليس لديك حساب؟ ", style: TextStyle(fontSize: 15)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          "إنشاء حساب",
                          style: TextStyle(
                            color: const Color(0xFF2E7D32),
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
      ),
    );

  }

}