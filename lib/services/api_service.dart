import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/env.dart';

/// Global navigator key so the API service can redirect on 401.
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 — clear token and redirect to login
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: 'token');
            await _storage.delete(key: 'user_id');
            final nav = navigatorKey.currentState;
            if (nav != null) {
              nav.pushNamedAndRemoveUntil('/login', (route) => false);
            }
          }
          final normalizedError = _normalizeError(error);
          handler.reject(normalizedError);
        },
      ),
    );
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  DioException _normalizeError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: error.error,
        message: 'Connection timeout. Please check your internet and try again.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: error.error,
        message: 'Cannot reach server. Verify backend is running and URL is correct.',
      );
    }

    return error;
  }

  Future<Map<String, dynamic>> testConnection() async {
    final endpointsToTry = ['/health', '/auth/login'];

    for (final endpoint in endpointsToTry) {
      try {
        final response = await get(endpoint);
        return {
          'ok': true,
          'endpoint': endpoint,
          'statusCode': response.statusCode,
          'data': response.data,
          'baseUrl': dio.options.baseUrl,
        };
      } on DioException catch (e) {
        // Keep probing other endpoints until one answers.
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          return {
            'ok': false,
            'endpoint': endpoint,
            'baseUrl': dio.options.baseUrl,
            'error': 'Could not connect to backend on ${dio.options.baseUrl}',
            'details': e.message,
          };
        }

        if (e.response != null) {
          return {
            'ok': true,
            'endpoint': endpoint,
            'statusCode': e.response?.statusCode,
            'data': e.response?.data,
            'baseUrl': dio.options.baseUrl,
            'note': 'Server responded with an error status but is reachable.',
          };
        }
      }
    }

    return {
      'ok': false,
      'baseUrl': dio.options.baseUrl,
      'error': 'No backend endpoint responded.',
    };
  }

}