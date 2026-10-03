import 'package:flutter/material.dart';

import '../../../core/auth/oidc_service.dart';
import '../../../core/auth/token_store.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final OidcService oidcService;
  final TokenStore tokenStore;

  AuthStatus status = AuthStatus.unknown;

  AuthViewModel({required this.oidcService, required this.tokenStore}) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      await oidcService.checkRedirect();
    } catch (_) {
      // token exchange failed (e.g. server misconfigured) — fall through
      // and treat as unauthenticated instead of leaving status unresolved.
    }
    final hasSession = await tokenStore.hasSession();
    status = hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> completeManualLogin() async {
    final hasSession = await tokenStore.hasSession();
    status = hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> loginWithOidc() async {
    await oidcService.login();
  }

  Future<void> logout() async {
    await oidcService.logout();
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}