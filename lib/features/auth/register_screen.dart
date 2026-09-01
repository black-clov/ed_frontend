import 'login_screen.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/config/env.dart';
import '../../core/i18n/app_i18n.dart';

class RegisterScreen extends StatefulWidget {
	const RegisterScreen({super.key});

	@override
	State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
	final _formKey = GlobalKey<FormState>();
	final _firstNameController = TextEditingController();
	final _lastNameController = TextEditingController();
	final _ageController = TextEditingController();
	final _villeController = TextEditingController();
	final _niveauScolaireController = TextEditingController();
	final _telephoneController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final AuthService _authService = AuthService();
	bool _loading = false;
	bool _googleLoading = false;

	Future<void> _openPrivacyPolicy() async {
		final uri = Uri.parse(Env.privacyPolicyUrl);
		if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text(tr('auth_privacy_open_error'))),
			);
		}
	}

	Future<void> _handleGoogleSignIn() async {
		setState(() => _googleLoading = true);
		try {
			final result = await _authService.signInWithGoogle();
			if (result == null) {
				setState(() => _googleLoading = false);
				return;
			}
			final storage = const FlutterSecureStorage();
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
			_showErrorPopup(tr('auth_google_register_failed'));
		}
		if (mounted) setState(() => _googleLoading = false);
	}

	@override
	void dispose() {
		_firstNameController.dispose();
		_lastNameController.dispose();
		_ageController.dispose();
		_villeController.dispose();
		_niveauScolaireController.dispose();
		_telephoneController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	void _showErrorPopup(String msg) {
		if (!mounted) return;
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
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
						onPressed: () => Navigator.pop(context),
						child: Text(tr('ok'), style: const TextStyle(color: Color(0xFFC62828))),
					),
				],
			),
		);
	}

	void _register() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _loading = true);
		try {
			final response = await _authService.register(
				firstName: _firstNameController.text.trim(),
				lastName: _lastNameController.text.trim(),
				age: _ageController.text.trim(),
				ville: _villeController.text.trim(),
				niveauScolaire: _niveauScolaireController.text.trim(),
				telephone: _telephoneController.text.trim(),
				email: _emailController.text.trim(),
				password: _passwordController.text.trim(),
			);
			setState(() => _loading = false);
			if (response.statusCode == 201 || response.statusCode == 200) {
				final storage = const FlutterSecureStorage();
				// Clear any stale data from previous sessions
				await storage.deleteAll();
				final userId = response.data['id']?.toString();
				if (userId != null && userId.isNotEmpty) {
					await storage.write(key: 'user_id', value: userId);
				}
				// Auto-login after registration to get JWT token
				try {
					final loginResp = await _authService.login(
						_emailController.text.trim(),
						_passwordController.text.trim(),
					);
					if (loginResp.data != null && loginResp.data['access_token'] != null) {
						await storage.write(key: 'token', value: loginResp.data['access_token']);
						final loginUserId = loginResp.data['userId'];
						if (loginUserId != null) {
							await storage.write(key: 'user_id', value: loginUserId.toString());
						}
						final role = loginResp.data['role'];
						if (role != null) {
							await storage.write(key: 'role', value: role.toString());
						}
					}
				} catch (_) {
					// If auto-login fails, user can login manually later
				}
				if (!mounted) return;
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text(tr('register_success'))),
				);
				// Go to onboarding flow
				Navigator.pushReplacementNamed(context, '/onboarding');
			} else {
				_showErrorPopup(tr('register_error'));
			}
		} on DioException catch (_) {
			setState(() => _loading = false);
			_showErrorPopup(tr('register_error'));
		} catch (_) {
			setState(() => _loading = false);
			_showErrorPopup(tr('register_error'));
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
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
									height: 70,
								),
								const SizedBox(height: 12),
								Text(
									tr('register_title'),
									style: TextStyle(
										fontSize: 28,
										fontWeight: FontWeight.bold,
										color: const Color(0xFFC62828),
									),
								),
								const SizedBox(height: 8),
								Text(
									tr('auth_register_subtitle'),
									style: TextStyle(fontSize: 16, color: Colors.grey[700]),
								),
								const SizedBox(height: 16),
								Card(
									elevation: 8,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
									child: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
										child: Form(
											key: _formKey,
											child: Column(
												children: [
													TextFormField(
														controller: _firstNameController,
														decoration: InputDecoration(
															labelText: tr('first_name'),
															prefixIcon: Icon(Icons.person, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _lastNameController,
														decoration: InputDecoration(
															labelText: tr('last_name'),
															prefixIcon: Icon(Icons.person_outline, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _ageController,
														decoration: InputDecoration(
															labelText: tr('age'),
															prefixIcon: Icon(Icons.cake, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														keyboardType: TextInputType.number,
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _villeController,
														decoration: InputDecoration(
															labelText: tr('city'),
															prefixIcon: Icon(Icons.location_city, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _niveauScolaireController,
														decoration: InputDecoration(
															labelText: tr('education_level'),
															prefixIcon: Icon(Icons.school, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _telephoneController,
														decoration: InputDecoration(
															labelText: tr('phone'),
															prefixIcon: Icon(Icons.phone, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														keyboardType: TextInputType.phone,
														validator: (v) => v == null || v.isEmpty ? tr('field_required') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _emailController,
														decoration: InputDecoration(
															labelText: tr('email'),
															prefixIcon: Icon(Icons.email, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														keyboardType: TextInputType.emailAddress,
														validator: (v) => v == null || !v.contains('@') ? tr('auth_invalid_email') : null,
													),
													const SizedBox(height: 16),
													TextFormField(
														controller: _passwordController,
														decoration: InputDecoration(
															labelText: tr('password'),
															prefixIcon: Icon(Icons.lock, color: const Color(0xFFC62828)),
															border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
															focusedBorder: OutlineInputBorder(
																borderRadius: BorderRadius.circular(12),
																borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
															),
														),
														obscureText: true,
														validator: (v) => v == null || v.length < 6 ? tr('auth_password_min_length') : null,
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
															onPressed: _loading ? null : _register,
															child: _loading
																	? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
																	: Text(tr('register_btn'), style: const TextStyle(fontSize: 18, color:Colors.white)),
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
												],
											),
										),
									),
								),
								const SizedBox(height: 18),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text(tr('have_account'), style: const TextStyle(fontSize: 15)),
										GestureDetector(
											onTap: () {
												Navigator.pushReplacement(
													context,
													MaterialPageRoute(builder: (_) => const LoginScreen()),
												);
											},
											child: Text(
												tr('login'),
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
								const SizedBox(height: 16),
								GestureDetector(
									onTap: _openPrivacyPolicy,
									child: Text(
										tr('privacy_consent'),
										textAlign: TextAlign.center,
										style: TextStyle(
											color: Colors.grey.shade600,
											fontSize: 12.5,
											decoration: TextDecoration.underline,
										),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}
