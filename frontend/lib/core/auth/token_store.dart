import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so tokens survive app restarts, and also
/// holds the temporary PKCE code_verifier/state across the full-page
/// redirect to the OIDC Server and back.
class TokenStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _codeVerifierKey = 'oidc_code_verifier';
  static const _stateKey = 'oidc_state';

  final FlutterSecureStorage _storage;

  TokenStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasSession() async => (await readAccessToken()) != null;

  Future<void> saveOidcState({required String codeVerifier, required String state}) async {
    await _storage.write(key: _codeVerifierKey, value: codeVerifier);
    await _storage.write(key: _stateKey, value: state);
  }

  Future<({String codeVerifier, String state})?> readOidcState() async {
    final codeVerifier = await _storage.read(key: _codeVerifierKey);
    final state = await _storage.read(key: _stateKey);
    if (codeVerifier == null || state == null) return null;
    return (codeVerifier: codeVerifier, state: state);
  }

  Future<void> clearOidcState() async {
    await _storage.delete(key: _codeVerifierKey);
    await _storage.delete(key: _stateKey);
  }
}