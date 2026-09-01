import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/i18n/app_i18n.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedLocale();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          locale: locale,
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      },
    );
  }
}

/// Splash: pick language on first launch, otherwise route by auth state.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final storage = const FlutterSecureStorage();
    // French is the default language; users switch via the toggle on screens
    // (no forced language-selection page).
    final token = await storage.read(key: 'token');
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
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
            const CircularProgressIndicator(color: Color(0xFFC62828)),
          ],
        ),
      ),
    );
  }
}
