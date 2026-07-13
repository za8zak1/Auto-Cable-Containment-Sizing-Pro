import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'isDarkMode';

  bool _isDark;
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider({bool restorePreference = true, bool initialIsDark = false})
      : _isDark = initialIsDark {
    if (restorePreference) {
      _restore();
    }
  }

  /// Deterministic constructor for widget tests and previews.
  ThemeProvider.test({bool isDark = false})
      : _isDark = isDark;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, _isDark);
  }
}
