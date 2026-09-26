import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Storage {
  static const _currentUserKey = 'salatak_current_user';

  static Future<void> setCurrentUser(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_currentUserKey, id);
  }

  static Future<String?> getCurrentUser() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_currentUserKey);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_currentUserKey);
  }

  static Future<UserData> loadUser(String id) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('salatak_user_$id');
    if (raw == null) return UserData(identifier: id);
    return UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveUser(UserData user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'salatak_user_${user.identifier}',
      jsonEncode(user.toJson()),
    );
  }
}
