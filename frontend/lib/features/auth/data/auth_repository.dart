import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/token_store.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStore tokenStore;

  AuthRepository({required this.apiClient, required this.tokenStore});

  /// Returns null on success, or a Thai error message on failure.
  Future<String?> login({required String username, required String password}) async {
    try {
      final response = await apiClient.dio.post('/login/', data: {'username': username, 'password': password});
      final token = response.data['token'] as String;
      await tokenStore.save(accessToken: token);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
      return 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่';
    }
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      await apiClient.dio.post('/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
      });
      return null;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data.isNotEmpty) {
        final firstKey = data.keys.first.toString();
        final firstError = data[data.keys.first];
        final message = firstError is List ? firstError.first.toString() : firstError.toString();
        return '${_translateField(firstKey)}: $message';
      }
      return 'สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่';
    }
  }

  String _translateField(String field) {
    switch (field) {
      case 'username':
        return 'ชื่อผู้ใช้';
      case 'email':
        return 'อีเมล';
      case 'password':
        return 'รหัสผ่าน';
      case 'password_confirm':
        return 'ยืนยันรหัสผ่าน';
      default:
        return 'ข้อผิดพลาด';
    }
  }
}