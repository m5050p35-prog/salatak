import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'salatak_theme';
  static const _localeKey = 'salatak_locale';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('ar');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final theme = p.getString(_themeKey) ?? 'light';
    final lang = p.getString(_localeKey) ?? 'ar';
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(lang);
    notifyListeners();
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_themeKey, dark ? 'dark' : 'light');
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_localeKey, code);
  }
}
