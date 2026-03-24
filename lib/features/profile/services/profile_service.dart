import '../models/profile_model.dart';
import '../../../services/api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<ProfileModel> fetchProfile() async {
    final response = await _apiService.get('/profile/me');
    final data = response.data;
    return ProfileModel(
      fullName: data['fullName'] ?? '',
      city: data['city'] ?? '',
      goal: data['goal'] ?? '',
    );
  }

  Future<String> fetchUserName(String userId) async {
    final response = await _apiService.get('/users/$userId');
    print('API response for /users/$userId: \\${response.data}');
    final data = response.data;
    return data['full_name'] ?? data['fullName'] ?? '';
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final response = await _apiService.get('/users/$userId');
    print('API response for /users/$userId: \\${response.data}');
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data is String) {
      return {};
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _apiService.put('/users/$userId', data: data);
    if (response.data is Map<String, dynamic>) {
      return response.data;
    }
    return {};
  }

  ProfileModel getInitialProfile() {
    return const ProfileModel(
      fullName: 'مستخدم جديد',
      city: 'الدار البيضاء',
      goal: 'إيجاد أول فرصة عمل',
    );
  }
}
