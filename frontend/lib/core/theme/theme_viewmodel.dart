import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Extra feature: Dark Mode toggle that remembers the user's preference.
class ThemeViewModel extends ChangeNotifier {
  static const _storageKey = 'theme_mode';
  final FlutterSecureStorage _storage;

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  ThemeViewModel({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _restore();
  }

  Future<void> _restore() async {
    final saved = await _storage.read(key: _storageKey);
    if (saved == 'dark') {
      _mode = ThemeMode.dark;
    } else if (saved == 'light') {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    _mode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(key: _storageKey, value: enabled ? 'dark' : 'light');
    notifyListeners();
  }
}
