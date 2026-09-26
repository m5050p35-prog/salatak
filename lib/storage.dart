import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'services/supabase_service.dart';

class Storage {
  static const _currentUserKey = 'salatak_current_user';

  /// ==========================================
  /// إدارة المستخدم الحالي (محلي فقط - سريع)
  /// ==========================================
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

  static Future<bool> hasCurrentUser() async {
    return (await getCurrentUser()) != null;
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_currentUserKey);
  }

  /// ==========================================
  /// البيانات: Supabase أولاً، ثم Cache محلي
  /// ==========================================

  /// تحميل بيانات المستخدم — يجرب Supabase، وإن فشل يستخدم Cache
  static Future<UserData> loadUser(String id) async {
    // 1) حاول من Supabase
    try {
      final cloudData = await SupabaseService.loadUser(id);
      if (cloudData != null) {
        // حدّث الـ cache المحلي
        await _saveLocal(cloudData);
        return cloudData;
      }
    } catch (_) {
      // تجاهل واستخدم الـ cache
    }

    // 2) fallback: اقرأ من Cache المحلي
    return await _loadLocal(id);
  }

  /// حفظ بيانات المستخدم — Supabase + Cache محلي
  static Future<bool> saveUser(UserData user) async {
    // احفظ محلياً أولاً (سرعة + offline)
    final localOk = await _saveLocal(user);

    // ثم حاول الرفع للسحابة
    try {
      await SupabaseService.saveUser(user);
    } catch (_) {
      // offline mode: البيانات محفوظة محلياً على الأقل
    }

    return localOk;
  }

  /// ==========================================
  /// Local Cache (SharedPreferences)
  /// ==========================================
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

  /// ==========================================
  /// تحقق من صحة البريد أو الهاتف
  /// ==========================================
  static String? validateIdentifier(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'empty';
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
    final phoneRegex = RegExp(r'^[0-9+\-\s]{7,15}$');
    if (emailRegex.hasMatch(v) || phoneRegex.hasMatch(v)) return null;
    return 'invalid';
  }
}
