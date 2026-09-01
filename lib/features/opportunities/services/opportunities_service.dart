import '../../../services/api_service.dart';
import '../models/opportunity_model.dart';

class OpportunitiesService {
  final ApiService _apiService = ApiService();

  Future<List<OpportunityModel>> getOpportunities() async {
    try {
      final resp = await _apiService.get('/opportunities');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => OpportunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<List<OpportunityModel>> getMatchedOpportunities(String? userId) async {
    try {
      final uid = userId ?? 'anonymous';
      final resp = await _apiService.get('/opportunities/matched/$uid');
      final data = resp.data;
      if (data is List) {
        return data
            .map((e) => OpportunityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }
}
