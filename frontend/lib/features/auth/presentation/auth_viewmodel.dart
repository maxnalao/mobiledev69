import 'package:flutter/material.dart';

import '../../../core/utils/result.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthStatus status = AuthStatus.unknown;
  String? displayName;
  String? errorMessage;
  bool isBusy = false;

  AuthViewModel({required this.repository}) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final result = await repository.completeLoginIfRedirected();
    if (result is Err<void>) errorMessage = result.message;

    if (await repository.hasSession()) {
      displayName = await repository.displayName();
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login() async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    // On success the browser leaves the app for the OIDC login page.
    final result = await repository.startLogin();
    isBusy = false;
    if (result is Err<void>) errorMessage = result.message;
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    final result = await repository.register(
      username: username,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    isBusy = false;
    if (result is Err<void>) errorMessage = result.message;
    notifyListeners();
    return result is Ok<void>;
  }

  Future<void> logout() async {
    await repository.logout();
    status = AuthStatus.unauthenticated;
    displayName = null;
    notifyListeners();
  }

  /// Called by ApiClient when the backend answers 401 (token expired).
  void handleSessionExpired() {
    if (status != AuthStatus.authenticated) return;
    status = AuthStatus.unauthenticated;
    displayName = null;
    errorMessage = 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่อีกครั้ง';
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
