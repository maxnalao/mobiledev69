import 'dart:html' as html;
import 'dart:math';

import 'package:openid_client/openid_client.dart';

import 'oidc_config.dart';
import 'token_store.dart';

/// Manual Authorization Code + PKCE flow for Flutter Web.
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

  Future<void> login() async {
    final issuer = await Issuer.discover(Uri.parse(OidcConfig.issuer));
    final client = Client(issuer, OidcConfig.clientId);

    final codeVerifier = _randomString(64);
    final state = _randomString(24);
    await tokenStore.saveOidcState(codeVerifier: codeVerifier, state: state);

    final flow = Flow.authorizationCodeWithPKCE(client, codeVerifier: codeVerifier, state: state)
      ..scopes.addAll(OidcConfig.scopes)
      ..redirectUri = Uri.parse(OidcConfig.redirectUri);

    html.window.location.href = flow.authenticationUri.toString();
  }

  /// Call once on app startup. If the browser was just redirected back
  /// from the OIDC Server with `?code=...`, completes the token exchange.
  Future<bool> checkRedirect() async {
    final uri = Uri.parse(html.window.location.href);
    if (!uri.queryParameters.containsKey('code')) return false;

    final saved = await tokenStore.readOidcState();
    if (saved == null) return false;

    final issuer = await Issuer.discover(Uri.parse(OidcConfig.issuer));
    final client = Client(issuer, OidcConfig.clientId);

    final flow = Flow.authorizationCodeWithPKCE(client, codeVerifier: saved.codeVerifier, state: saved.state)
      ..scopes.addAll(OidcConfig.scopes)
      ..redirectUri = Uri.parse(OidcConfig.redirectUri);

    final credential = await flow.callback(uri.queryParameters);
    final tokenResponse = await credential.getTokenResponse();

    await tokenStore.save(accessToken: tokenResponse.accessToken ?? '', refreshToken: tokenResponse.refreshToken);
    await tokenStore.clearOidcState();

    html.window.history.replaceState(null, '', OidcConfig.redirectUri);
    return true;
  }

  Future<void> logout() async {
    await tokenStore.clear();
  }
}