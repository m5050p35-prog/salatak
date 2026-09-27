import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'services/supabase_service.dart';

class Storage {
  static const _currentUserKey = 'salatak_current_user';

  static Future<bool> setCurrentUser(String id) async {
    try {
      final p = await SharedPreferences.getInstance();
      return await p.setString(_currentUserKey, id);
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getCurrentUser() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_currentUserKey);
    if (id == null || id.trim().isEmpty) return null;
    return id;
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_currentUserKey);
  }

  static Future<UserData> loadUser(String id) async {
    try {
      final cloudData = await SupabaseService.loadUser(id);
      if (cloudData != null) {
        await _saveLocal(cloudData);
        return cloudData;
      }
    } catch (_) {}
    return await _loadLocal(id);
  }

  static Future<bool> saveUser(UserData user) async {
    final localOk = await _saveLocal(user);
    try {
      await SupabaseService.saveUser(user);
    } catch (_) {}
    return localOk;
  }

  static Future<UserData> _loadLocal(String id) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('salatak_user_$id');
    if (raw == null) return UserData(identifier: id);
    try {
      return UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserData(identifier: id);
    }
  }

  static Future<bool> _saveLocal(UserData user) async {
    try {
      final p = await SharedPreferences.getInstance();
      return await p.setString(
        'salatak_user_${user.identifier}',
        jsonEncode(user.toJson()),
      );
    } catch (_) {
      return false;
    }
  }

  /// تحقق من Gmail فقط
  static String? validateGmail(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return 'empty';
    if (!v.endsWith('@gmail.com')) return 'not_gmail';
    final regex = RegExp(r'^[a-z0-9](\.?[a-z0-9]){4,}@gmail\.com$');
    if (!regex.hasMatch(v)) return 'invalid';
    return null;
  }

  /// تحقق من الاسم
  static String? validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'empty';
    if (v.length < 2) return 'short';
    return null;
  }

  /// هل الحساب موجود في السحابة؟
  static Future<bool> userExists(String email) async {
    try {
      return await SupabaseService.userExists(email);
    } catch (_) {
      return false;
    }
  }
}
