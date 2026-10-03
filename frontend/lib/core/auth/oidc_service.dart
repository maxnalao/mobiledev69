import 'dart:math';

import 'package:openid_client/openid_client.dart';
import 'package:web/web.dart' as web;

import 'oidc_config.dart';
import 'token_store.dart';

/// Service layer: Authorization Code + PKCE flow for Flutter Web.
/// (openid_client's browser wrapper only supports the less-secure
/// Implicit flow, so we build the code+PKCE flow ourselves using the
/// platform-agnostic Flow API and a full-page redirect.)
class OidcService {
  final TokenStore tokenStore;

  OidcService({required this.tokenStore});

  String _randomString(int length) {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<Flow> _buildFlow({required String codeVerifier, required String state}) async {
    final issuer = await Issuer.discover(Uri.parse(OidcConfig.issuer));
    final client = Client(issuer, OidcConfig.clientId);
    return Flow.authorizationCodeWithPKCE(client, codeVerifier: codeVerifier, state: state)
      ..scopes.addAll(OidcConfig.scopes)
      ..redirectUri = Uri.parse(OidcConfig.redirectUri);
  }

  /// Steps 1-3: send the browser to the OIDC Server's login/consent page.
  Future<void> login() async {
    final codeVerifier = _randomString(64);
    final state = _randomString(24);
    final flow = await _buildFlow(codeVerifier: codeVerifier, state: state);
    await tokenStore.saveOidcState(codeVerifier: codeVerifier, state: state);
    web.window.location.href = flow.authenticationUri.toString();
  }

  /// Steps 4-6: call once on app startup. If the browser was just redirected
  /// back from the OIDC Server with `?code=...`, exchanges the code for tokens
  /// and fetches the user's name from the userinfo endpoint.
  Future<bool> completeLoginIfRedirected() async {
    final uri = Uri.parse(web.window.location.href);
    final params = uri.queryParameters;
    if (!params.containsKey('code') && !params.containsKey('error')) return false;

    // Drop ?code=... from the address bar so a refresh doesn't replay it.
    web.window.history.replaceState(null, '', '/');

    final saved = await tokenStore.readOidcState();
    await tokenStore.clearOidcState();
    if (params.containsKey('error')) {
      throw OidcException(params['error_description'] ?? params['error']!);
    }
    if (saved == null) return false;

    final flow = await _buildFlow(codeVerifier: saved.codeVerifier, state: saved.state);
    final credential = await flow.callback(params);
    final tokenResponse = await credential.getTokenResponse();
    final userInfo = await credential.getUserInfo();

    await tokenStore.save(
      accessToken: tokenResponse.accessToken!,
      refreshToken: tokenResponse.refreshToken,
      idToken: credential.idToken.toCompactSerialization(),
      displayName: userInfo.name ?? userInfo.preferredUsername ?? userInfo.subject,
    );
    return true;
  }

  /// Clears local tokens, then ends the session on the OIDC Server too, so
  /// the next login really asks for the password again.
  Future<void> logout() async {
    final idToken = await tokenStore.readIdToken();
    await tokenStore.clear();

    final endSessionUri = Uri.parse('${OidcConfig.issuer}/end-session').replace(queryParameters: {
      if (idToken != null) 'id_token_hint': idToken,
      'post_logout_redirect_uri': OidcConfig.postLogoutRedirectUri,
    });
    web.window.location.href = endSessionUri.toString();
  }
}

class OidcException implements Exception {
  final String message;
  OidcException(this.message);

  @override
  String toString() => message;
}
