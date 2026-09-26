class PrayerDay {
  final int id;
  final String date;
  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  PrayerDay({
    required this.id,
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'date': date,
        'fajr': fajr, 'dhuhr': dhuhr, 'asr': asr,
        'maghrib': maghrib, 'isha': isha,
      };

  factory PrayerDay.fromJson(Map<String, dynamic> j) => PrayerDay(
        id: j['id'] as int,
        date: j['date'] as String,
        fajr: j['fajr'] as bool? ?? false,
        dhuhr: j['dhuhr'] as bool? ?? false,
        asr: j['asr'] as bool? ?? false,
        maghrib: j['maghrib'] as bool? ?? false,
        isha: j['isha'] as bool? ?? false,
      );

  int get completedCount =>
      (fajr ? 1 : 0) + (dhuhr ? 1 : 0) + (asr ? 1 : 0) +
      (maghrib ? 1 : 0) + (isha ? 1 : 0);

  bool get isComplete => completedCount == 5;
}

class UserData {
  final String identifier;
  final List<PrayerDay> days;

  UserData({required this.identifier, List<PrayerDay>? days})
      : days = days ?? [];

  int get totalDays => days.length;
  int get totalCompleted => days.fold(0, (s, d) => s + d.completedCount);
  int get totalRemaining => (totalDays * 5) - totalCompleted;

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory UserData.fromJson(Map<String, dynamic> j) => UserData(
        identifier: j['identifier'] as String,
        days: (j['days'] as List)
            .map((e) => PrayerDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
