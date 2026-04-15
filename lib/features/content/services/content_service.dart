import '../../../services/api_service.dart';
import '../models/content_model.dart';

class ContentService {
  final _api = ApiService();

  Future<List<ContentModel>> fetchContent({String? type, String? category}) async {
    String path = '/content';
    final params = <String>[];
    if (type != null) params.add('type=$type');
    if (category != null) params.add('category=$category');
    if (params.isNotEmpty) path += '?${params.join('&')}';

    final response = await _api.get(path);
    final List data = response.data is List ? response.data : [];
    return data.map((e) => ContentModel.fromJson(e)).toList();
  }

  Future<ContentModel?> fetchOne(String id) async {
    final response = await _api.get('/content/$id');
    if (response.data != null) {
      return ContentModel.fromJson(response.data);
    }
    return null;
  }
}
