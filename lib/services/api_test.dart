import 'package:flutter/foundation.dart';
import 'api_service.dart';

void testApi() async {
  final api = ApiService();

  final result = await api.testConnection();

  debugPrint(result.toString());
}