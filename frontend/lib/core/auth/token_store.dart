import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so tokens survive app restarts, and also
/// holds the temporary PKCE code_verifier/state across the full-page
/// redirect to the OIDC Server and back.
class TokenStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';
  static const _displayNameKey = 'display_name';
  static const _codeVerifierKey = 'oidc_code_verifier';
  static const _stateKey = 'oidc_state';

  final FlutterSecureStorage _storage;

  TokenStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    String? displayName,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _idTokenKey, value: idToken);
    await _storage.write(key: _displayNameKey, value: displayName);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readIdToken() => _storage.read(key: _idTokenKey);

  Future<String?> readDisplayName() => _storage.read(key: _displayNameKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _idTokenKey);
    await _storage.delete(key: _displayNameKey);
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
