import '../../../services/api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getStats() async {
    final resp = await _api.get('/admin/stats');
    if (resp.data is Map<String, dynamic>) return resp.data;
    return {};
  }

  Future<List<dynamic>> getUsers() async {
    final resp = await _api.get('/admin/users');
    if (resp.data is List) return resp.data;
    return [];
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _api.patch('/admin/users/$userId/role', data: {'role': role});
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final resp = await _api.get('/admin/users/$userId/details');
    if (resp.data is Map<String, dynamic>) return resp.data;
    return {};
  }

  Future<void> deleteUser(String userId) async {
    await _api.delete('/admin/users/$userId');
  }

  Future<List<dynamic>> getAnalytics({int limit = 100}) async {
    final resp = await _api.get('/admin/analytics', queryParameters: {'limit': limit});
    if (resp.data is List) return resp.data;
    return [];
  }
}
