import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../services/api_service.dart';
import '../models/cv_model.dart';
import 'package:dio/dio.dart';

class CvService {
  final ApiService _apiService = ApiService();

  Future<CvModel> buildLocalPreview() async {
    return const CvModel(
      fullName: 'مستخدم إدماج',
      skills: ['مهارات التواصل', 'المهارات الرقمية', 'العمل الجماعي'],
      interests: ['التكنولوجيا', 'العمل مع الناس'],
      personalityHighlights: ['صبور', 'مستقل'],
    );
  }

  Future<CvModel?> fetchCvFromBackend({String? userId, String? headline}) async {
    try {
      final response = await _apiService.post('/cv/generate', data: {
        if (userId != null) 'userId': userId,
        if (headline != null) 'headline': headline,
      });
      final data = response.data;
      final profile = data['profile'];
      final sections = data['sections'];
      return CvModel(
        fullName: profile != null
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
            : 'مستخدم إدماج',
        skills: List<String>.from(sections?['skills'] ?? []),
        interests: List<String>.from(sections?['interests'] ?? []),
        personalityHighlights: List<String>.from(sections?['workPreferences'] ?? []),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> downloadPdf({String? userId, String? headline}) async {
    try {
      final response = await _apiService.post(
        '/cv/pdf',
        data: {
          if (userId != null) 'userId': userId,
          if (headline != null) 'headline': headline,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data as List<int>;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cv_edmaj.pdf');
      await file.writeAsBytes(Uint8List.fromList(bytes));
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
