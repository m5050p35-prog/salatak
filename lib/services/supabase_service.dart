import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';

class SupabaseService {
  // ⚠️ مفتاح عام (آمن للنشر في الكود)
  static const String _url = 'https://alxajjpidlyyhikpxkcj.supabase.co';
  static const String _anonKey =
      'sb_publishable_GUWkSwv_8xhGTipaX6pwiQ__F01ka97';

  static SupabaseClient get _client => Supabase.instance.client;

  /// تهيئة Supabase (تُستدعى من main)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  /// حفظ/تحديث بيانات المستخدم كاملة في Supabase
  static Future<bool> saveUser(UserData user) async {
    try {
      // 1) ابحث عن المستخدم أو أنشئه
      final existing = await _client
          .from('users')
          .select('id')
          .eq('identifier', user.identifier)
          .maybeSingle();

      String userId;
      if (existing == null) {
        final created = await _client
            .from('users')
            .insert({'identifier': user.identifier})
            .select('id')
            .single();
        userId = created['id'] as String;
      } else {
        userId = existing['id'] as String;
        // تحديث updated_at
        await _client.from('users').update({
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }

      // 2) احذف كل الأيام القديمة ثم أضف الجديدة (أسرع من التحديث المفرد)
      await _client.from('prayer_days').delete().eq('user_id', userId);

      if (user.days.isNotEmpty) {
        final rows = user.days
            .map((d) => {
                  'user_id': userId,
                  'day_number': d.id,
                  'date': d.date,
                  'fajr': d.fajr,
                  'dhuhr': d.dhuhr,
                  'asr': d.asr,
                  'maghrib': d.maghrib,
                  'isha': d.isha,
                })
            .toList();

        // إدراج على دفعات (لتجنب حدود الحجم)
        const batchSize = 500;
        for (int i = 0; i < rows.length; i += batchSize) {
          final end = (i + batchSize < rows.length)
              ? i + batchSize
              : rows.length;
          await _client
              .from('prayer_days')
              .insert(rows.sublist(i, end));
        }
      }

      return true;
    } catch (e) {
      // print للتشخيص فقط
      // ignore: avoid_print
      print('Supabase saveUser error: $e');
      return false;
    }
  }

  /// تحميل بيانات المستخدم من Supabase
  static Future<UserData?> loadUser(String identifier) async {
    try {
      final userRow = await _client
          .from('users')
          .select('id')
          .eq('identifier', identifier)
          .maybeSingle();

      if (userRow == null) return null;

      final userId = userRow['id'] as String;
      final daysRows = await _client
          .from('prayer_days')
          .select()
          .eq('user_id', userId)
          .order('day_number', ascending: true);

      final days = (daysRows as List)
          .map((r) => PrayerDay(
                id: r['day_number'] as int,
                date: r['date'] as String,
                fajr: r['fajr'] as bool? ?? false,
                dhuhr: r['dhuhr'] as bool? ?? false,
                asr: r['asr'] as bool? ?? false,
                maghrib: r['maghrib'] as bool? ?? false,
                isha: r['isha'] as bool? ?? false,
              ))
          .toList();

      return UserData(identifier: identifier, days: days);
    } catch (e) {
      // ignore: avoid_print
      print('Supabase loadUser error: $e');
      return null;
    }
  }

  /// هل المستخدم موجود في Supabase؟
  static Future<bool> userExists(String identifier) async {
    try {
      final row = await _client
          .from('users')
          .select('id')
          .eq('identifier', identifier)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }
}
