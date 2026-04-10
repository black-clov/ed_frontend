import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/api_service.dart';
import '../models/cv_model.dart';
import 'package:dio/dio.dart';

class CvService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<CvModel> buildLocalPreview() async {
    return const CvModel(
      fullName: 'مستخدم إدماج',
      skills: ['مهارات التواصل', 'المهارات الرقمية', 'العمل الجماعي'],
      interests: ['التكنولوجيا', 'العمل مع الناس'],
      personalityHighlights: ['صبور', 'مستقل'],
    );
  }

  Future<CvModel?> fetchCvFromBackend({String? userId}) async {
    try {
      final uid = userId ?? await _storage.read(key: 'user_id');
      if (uid == null) return null;

      // Fetch CV data (profile + skills + questionnaire)
      final cvResp = await _apiService.post('/cv/generate', data: {'userId': uid});
      final data = cvResp.data;
      final profile = data['profile'] as Map<String, dynamic>?;
      final sections = data['sections'] as Map<String, dynamic>?;

      // Fetch user needs separately
      List<String> needs = [];
      try {
        final needsResp = await _apiService.get('/needs/$uid');
        if (needsResp.data is List) {
          needs = (needsResp.data as List).cast<String>();
        }
      } catch (_) {}

      final firstName = (profile?['first_name'] ?? '').toString().trim();
      final lastName = (profile?['last_name'] ?? '').toString().trim();
      final fullName = '$firstName $lastName'.trim();

      return CvModel(
        fullName: fullName.isNotEmpty ? fullName : 'مستخدم إدماج',
        email: (profile?['email'] ?? '').toString().trim(),
        phone: (profile?['telephone'] ?? '').toString().trim(),
        city: (profile?['ville'] ?? '').toString().trim(),
        education: (profile?['niveau_scolaire'] ?? '').toString().trim(),
        age: (profile?['age'] ?? '').toString().trim(),
        skills: List<String>.from(sections?['skills'] ?? []),
        interests: List<String>.from(sections?['interests'] ?? []),
        personalityHighlights: List<String>.from(sections?['workPreferences'] ?? []),
        needs: needs,
        workPreferences: List<String>.from(sections?['workPreferences'] ?? []),
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