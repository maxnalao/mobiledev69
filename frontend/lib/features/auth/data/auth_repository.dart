import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/oidc_service.dart';
import '../../../core/auth/token_store.dart';
import '../../../core/utils/result.dart';

/// Repository for everything auth-related. The ViewModel talks only to this
/// class; it hides OidcService/TokenStore/ApiClient and never throws.
class AuthRepository {
  final OidcService oidcService;
  final TokenStore tokenStore;
  final ApiClient apiClient;

  AuthRepository({required this.oidcService, required this.tokenStore, required this.apiClient});

  Future<Result<void>> startLogin() async {
    try {
      await oidcService.login();
      return const Ok(null);
    } catch (_) {
      return const Err('เชื่อมต่อ OIDC Server ไม่ได้ กรุณาตรวจสอบว่า backend ทำงานอยู่');
    }
  }

  Future<Result<void>> completeLoginIfRedirected() async {
    try {
      await oidcService.completeLoginIfRedirected();
      return const Ok(null);
    } on OidcException catch (e) {
      return Err('เข้าสู่ระบบไม่สำเร็จ: ${e.message}');
    } catch (_) {
      return const Err('เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
    }
  }

  Future<bool> hasSession() => tokenStore.hasSession();

  Future<String?> displayName() => tokenStore.readDisplayName();

  Future<void> logout() async {
    try {
      await oidcService.logout();
    } catch (_) {
      // Local tokens are already cleared; nothing else to do offline.
    }
  }

  Future<Result<void>> register({
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
      return const Ok(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data.isNotEmpty) {
        final firstKey = data.keys.first.toString();
        final firstError = data[data.keys.first];
        final message = firstError is List ? firstError.first.toString() : firstError.toString();
        return Err('${_translateField(firstKey)}: $message');
      }
      if (e.response == null) return const Err('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาตรวจสอบอินเทอร์เน็ต');
      return const Err('สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่');
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
