import 'login_screen.dart';
import 'auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dashboard/dashboard_screen.dart';

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
	String _gender = 'boy';

	@override
	void initState() {
		super.initState();
		_loadGender();
	}

	Future<void> _loadGender() async {
		final g = await const FlutterSecureStorage().read(key: 'gender');
		if (g != null && mounted) setState(() => _gender = g);
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
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text("فشل التسجيل بـ Google: ${e.toString()}")),
			);
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
					const SnackBar(content: Text('تم التسجيل بنجاح!')),
				);
				// Go to onboarding flow
				Navigator.pushReplacementNamed(context, '/onboarding');
			} else {
				final msg = response.data?.toString() ?? 'لا يوجد رد من الخادم.';
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('فشل التسجيل: $msg')),
				);
			}
		} on DioError catch (e) {
			setState(() => _loading = false);
			final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('خطأ في التسجيل: $msg')),
			);
		} catch (e) {
			setState(() => _loading = false);
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('خطأ في التسجيل: ${e.toString()}')),
			);
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
										height: 70,
									),
									const SizedBox(height: 12),
									Text(
										'إنشاء حساب',
										style: TextStyle(
											fontSize: 28,
											fontWeight: FontWeight.bold,
											color: const Color(0xFFE65100),
										),
									),
									const SizedBox(height: 8),
									Text(
										'سجّل بياناتك للانضمام إلى منصة إدماج',
										style: TextStyle(fontSize: 16, color: Colors.grey[700]),
									),
									const SizedBox(height: 16),
									Image.asset(
										_gender == 'boy' ? 'assets/images/mascott_garcon.png' : 'assets/images/mascott_fille.png',
										height: 120,
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
																labelText: 'الاسم الأول',
																prefixIcon: Icon(Icons.person, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الاسم الأول' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _lastNameController,
															decoration: InputDecoration(
																labelText: 'اسم العائلة',
																prefixIcon: Icon(Icons.person_outline, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال اسم العائلة' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _ageController,
															decoration: InputDecoration(
																labelText: 'العمر',
																prefixIcon: Icon(Icons.cake, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															keyboardType: TextInputType.number,
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال العمر' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _villeController,
															decoration: InputDecoration(
																labelText: 'المدينة',
																prefixIcon: Icon(Icons.location_city, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال المدينة' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _niveauScolaireController,
															decoration: InputDecoration(
																labelText: 'المستوى الدراسي',
																prefixIcon: Icon(Icons.school, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال المستوى الدراسي' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _telephoneController,
															decoration: InputDecoration(
																labelText: 'رقم الهاتف',
																prefixIcon: Icon(Icons.phone, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															keyboardType: TextInputType.phone,
															validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _emailController,
															decoration: InputDecoration(
																labelText: 'البريد الإلكتروني',
																prefixIcon: Icon(Icons.email, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															keyboardType: TextInputType.emailAddress,
															validator: (v) => v == null || !v.contains('@') ? 'يرجى إدخال بريد إلكتروني صحيح' : null,
														),
														const SizedBox(height: 16),
														TextFormField(
															controller: _passwordController,
															decoration: InputDecoration(
																labelText: 'كلمة المرور',
																prefixIcon: Icon(Icons.lock, color: const Color(0xFFE65100)),
																border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
																focusedBorder: OutlineInputBorder(
																	borderRadius: BorderRadius.circular(12),
																	borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
																),
															),
															obscureText: true,
															validator: (v) => v == null || v.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
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
																onPressed: _loading ? null : _register,
																child: _loading
																		? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
																		: const Text('تسجيل', style: TextStyle(fontSize: 18, color:Colors.white)),
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
																	"التسجيل بـ Google",
																	style: TextStyle(fontSize: 16, color: _googleLoading ? Colors.grey : const Color(0xFFDB4437)),
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
											const Text("لديك حساب بالفعل؟ ", style: TextStyle(fontSize: 15)),
											GestureDetector(
												onTap: () {
													Navigator.pushReplacement(
														context,
														MaterialPageRoute(builder: (_) => const LoginScreen()),
													);
												},
												child: Text(
													"تسجيل الدخول",
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
