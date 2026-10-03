import 'package:dio/dio.dart';

import '../auth/token_store.dart';

/// Service layer: single Dio instance, shared by every repository.
/// Repositories depend on this — never on `dio` directly.
class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api';

  final Dio dio;
  final TokenStore tokenStore;

  /// Called when the backend rejects our access token (expired/revoked).
  void Function()? onUnauthorized;

  ApiClient({required this.tokenStore})
      : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10))) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && await tokenStore.hasSession()) {
            await tokenStore.clear();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }
}
