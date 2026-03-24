import 'package:dio/dio.dart';
import '../../services/api_service.dart';

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