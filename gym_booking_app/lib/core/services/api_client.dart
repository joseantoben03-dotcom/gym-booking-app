import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../constants.dart';

class ApiClient extends GetxService {
  late final Dio _dio;
  final _storage = GetStorage();

  ApiClient() {
    if (kDebugMode) {
      print('ApiClient: baseUrl = ${AppConstants.baseUrl}');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read<String>(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('→ ${options.method} ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('← ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('✗ ${e.response?.statusCode} ${e.requestOptions.path}: ${e.message}');
            print('  response body: ${e.response?.data}');
          }
          // Auto-logout on 401 only for non-auth routes
          final path = e.requestOptions.path;
          final isAuthRoute =
              path.contains('/auth/login') || path.contains('/auth/register');
          if (e.response?.statusCode == 401 && !isAuthRoute) {
            _storage.remove(AppConstants.tokenKey);
            _storage.remove(AppConstants.userKey);
            Get.offAllNamed('/login');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
