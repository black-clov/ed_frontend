import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';
import '../models/recommendation_model.dart';

class RecommendationsService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<RecommendationModel>> getRecommendations() async {
    try {
      final uid = await _storage.read(key: 'user_id') ?? 'anonymous';
      final resp = await _apiService.get('/recommendations/$uid');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => RecommendationModel(
                  title: (e['title'] ?? '').toString(),
                  description: (e['description'] ?? '').toString(),
                  actionLabel: (e['actionLabel'] ?? '').toString(),
                ))
            .toList();
      }
    } catch (_) {
      // No static fallback: recommendations come only from the backend
      // (derived from admin-managed offers).
    }
    return const [];
  }
}
