import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'salatak_theme';
  static const _localeKey = 'salatak_locale';
  static const _notifEnabledKey = 'salatak_notif_enabled';
  static const _notifHourKey = 'salatak_notif_hour';
  static const _notifMinuteKey = 'salatak_notif_minute';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('ar');
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;

  String get notificationTimeString {
    final h = _notificationTime.hour.toString().padLeft(2, '0');
    final m = _notificationTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final theme = p.getString(_themeKey) ?? 'light';
    final lang = p.getString(_localeKey) ?? 'ar';
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(lang);
    _notificationsEnabled = p.getBool(_notifEnabledKey) ?? false;
    final h = p.getInt(_notifHourKey) ?? 20;
    final m = p.getInt(_notifMinuteKey) ?? 0;
    _notificationTime = TimeOfDay(hour: h, minute: m);
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

  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifEnabledKey, enabled);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_notifHourKey, time.hour);
    await p.setInt(_notifMinuteKey, time.minute);
  }
}
