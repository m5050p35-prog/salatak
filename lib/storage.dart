import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class Storage {
  static const _currentUserKey = 'salatak_current_user';

  /// حفظ المستخدم الحالي (يُستدعى بعد نجاح التحقق)
  static Future<bool> setCurrentUser(String id) async {
    try {
      final p = await SharedPreferences.getInstance();
      return await p.setString(_currentUserKey, id);
    } catch (e) {
      return false;
    }
  }

  /// قراءة المستخدم الحالي
  static Future<String?> getCurrentUser() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getString(_currentUserKey);
    if (id == null || id.trim().isEmpty) return null;
    return id;
  }

  /// هل يوجد مستخدم مسجل؟
  static Future<bool> hasCurrentUser() async {
    final id = await getCurrentUser();
    return id != null;
  }

  /// تسجيل الخروج
  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_currentUserKey);
  }

  /// تحميل بيانات مستخدم
  static Future<UserData> loadUser(String id) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('salatak_user_$id');
    if (raw == null) return UserData(identifier: id);
    try {
      return UserData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserData(identifier: id);
    }
  }

  /// حفظ بيانات مستخدم
  static Future<bool> saveUser(UserData user) async {
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

  /// التحقق من صحة المدخل (بريد أو هاتف)
  static String? validateIdentifier(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'empty';
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
    final phoneRegex = RegExp(r'^[0-9+\-\s]{7,15}$');
    if (emailRegex.hasMatch(v) || phoneRegex.hasMatch(v)) return null;
    return 'invalid';
  }
}
