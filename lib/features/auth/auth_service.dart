import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final ApiService api = ApiService();

  Future<Response> login(String email, String password) async {
    return await api.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password
      },
    );
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }
      
      // Send token to backend
      final response = await api.post(
        "/auth/google",
        data: {"idToken": idToken},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register({
    required String firstName,
    required String lastName,
    required String age,
    required String ville,
    required String niveauScolaire,
    required String telephone,
    required String email,
    required String password,
  }) async {
    return await api.post(
      "/users",
      data: {
        "first_name": firstName,
        "last_name": lastName,
        "age": age,
        "ville": ville,
        "niveau_scolaire": niveauScolaire,
        "telephone": telephone,
        "email": email,
        "password": password,
      },
    );
  }

  Future<Response> requestPasswordReset(String email) async {
    return await api.post(
      "/auth/request-reset",
      data: {"email": email},
    );
  }

  Future<Response> resetPassword(String token, String newPassword) async {
    return await api.post(
      "/auth/reset-password",
      data: {"token": token, "newPassword": newPassword},
    );
  }

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return await api.post(
      "/auth/change-password",
      data: {"currentPassword": currentPassword, "newPassword": newPassword},
    );
  }
}