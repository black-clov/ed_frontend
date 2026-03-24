import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const _SplashGate(),
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/register': (_) => RegisterScreen(),
        '/login': (_) => LoginScreen(),
        '/onboarding': (_) => const OnboardingFlow(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
      },
    );

  }

}

/// Checks for existing token and auto-navigates to dashboard or register.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      // Admin users skip onboarding; regular users must complete it
      final role = await storage.read(key: 'role');
      final onboardingDone = await storage.read(key: 'onboarding_done');
      if (!mounted) return;
      if (role == 'admin' || onboardingDone == 'true') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_et_slogan.png', height: 120),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFFE65100)),
          ],
        ),
      ),
    );
  }
}