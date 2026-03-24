import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';
import '../onboarding/gender_welcome_screen.dart';

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
      _showSnack('يرجى إدخال البريد الإلكتروني وكلمة المرور');
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
        _showSnack('بيانات الدخول غير صحيحة');
      }
    } catch (e) {
      _showSnack('خطأ في تسجيل الدخول');
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6F0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset('assets/images/logo_eidmaj.png', height: 100),
                const SizedBox(height: 8),
                const Text(
                  'مرحبا بكم',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),

                // --- LOGIN SECTION ---
                _sectionDivider('تسجيل الدخول'),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني',
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
                    hintText: 'كلمة المرور',
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
                      backgroundColor: const Color(0xFFE65100),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('دخول', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 12),

                // --- NEW ACCOUNT SECTION ---
                _sectionDivider('حساب جديد'),
                const SizedBox(height: 10),
                const Text(
                  'ختار نوع الجنس ديالك',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
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
                          child: const Text('ولد', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
                          child: const Text('بنت', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'دخل المعلومات ديالك باش تبدا',
                  style: TextStyle(
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
                    onPressed: () => _showSnack('قريبًا'),
                    icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                    label: const Text('se connecter avec google', style: TextStyle(color: Colors.black87, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Facebook button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSnack('قريبًا'),
                    icon: const Icon(Icons.facebook, color: Colors.white),
                    label: const Text('se connecter avec facebook', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFE65100), thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
        ),
        Expanded(child: Divider(color: const Color(0xFFE65100), thickness: 1.5)),
      ],
    );
  }
}
