import 'package:flutter/material.dart';
import 'storage.dart';
import 'login_screen.dart';
import 'models.dart';
import 'duration_screen.dart';
import 'profile_screen.dart';
import 'l10n/app_localizations.dart';
import 'widgets/app_drawer.dart';

class TrackerScreen extends StatefulWidget {
  final String userId;
  const TrackerScreen({super.key, required this.userId});
  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  UserData? _data;
  bool _loading = true;
  bool _syncing = false;
  bool _scrolledOnce = false;
  final Map<int, GlobalKey> _dayKeys = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await Storage.loadUser(widget.userId);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLastCompleted();
    });
  }

  /// التمرير التلقائي لآخر يوم مكتمل
  void _scrollToLastCompleted({bool force = false}) {
    if (!force && _scrolledOnce) return;
    if (_data == null || _data!.days.isEmpty) return;
    _scrolledOnce = true;

    int lastIdx = -1;
    for (int i = _data!.days.length - 1; i >= 0; i--) {
      if (_data!.days[i].isComplete) {
        lastIdx = i;
        break;
      }
    }
    if (lastIdx < 0) return;

    final dayId = _data!.days[lastIdx].id;
    final key = _dayKeys[dayId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    }
  }

  /// تأخير التمرير قليلاً بعد اكتمال اليوم لضمان اكتمال إعادة البناء
  void _scrollAfterComplete() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _scrollToLastCompleted(force: true);
        }
      });
    });
  }

  Future<void> _save() async {
    if (_data == null) return;
    setState(() => _syncing = true);
    await Storage.saveUser(_data!);
    if (!mounted) return;
    setState(() => _syncing = false);
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final d = await Storage.loadUser(widget.userId);
    if (!mounted) return;
    setState(() {
      _data = d;
      _syncing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تمت المزامنة')),
    );
  }

  Future<void> _addDay() async {
    if (_data == null) return;
    final lastDate = _data!.days.isEmpty
        ? DateTime.now()
        : DateTime.parse(_data!.days.last.date);
    final newDate = lastDate.add(const Duration(days: 1));
    setState(() {
      _data!.days.add(PrayerDay(
        id: _data!.days.length + 1,
        date:
            '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}',
      ));
    });
    await _save();
  }

  Future<void> _removeDay(int index) async {
    if (_data == null) return;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteDay),
        content: Text(l.deleteDayNote),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.delete)),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _data!.days.removeAt(index);
        for (int i = 0; i < _data!.days.length; i++) {
          final d = _data!.days[i];
          _data!.days[i] = PrayerDay(
            id: i + 1,
            date: d.date,
            fajr: d.fajr,
            dhuhr: d.dhuhr,
            asr: d.asr,
            maghrib: d.maghrib,
            isha: d.isha,
          );
        }
      });
      await _save();
    }
  }

  Future<void> _logout() async {
    await Storage.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.resetTable),
        content: Text(l.resetTableNote),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.reset)),
        ],
      ),
    );
    if (ok == true) {
      final existing = _data;
      await Storage.saveUser(UserData(
        identifier: widget.userId,
        name: existing?.name ?? '',
      ));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => DurationScreen(userId: widget.userId)),
      );
    }
  }

  void _openProfile() {
    if (_data == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(data: _data!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final data = _data!;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.prayerTable),
        actions: [
          if (_syncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_sync),
              onPressed: _syncNow,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      drawer: AppDrawer(
        onLogout: _logout,
        onReset: _reset,
        onProfile: _openProfile,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDay,
        icon: const Icon(Icons.add),
        label: Text(l.addDay),
      ),
      body: Column(
        children: [
          _SummaryCard(data: data, l: l),
          Expanded(
            child: data.days.isEmpty
                ? _EmptyState(l: l)
                : ListView.builder(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, bottom: 100, top: 4),
                    itemCount: data.days.length,
                    itemBuilder: (_, i) {
                      final day = data.days[i];
                      _dayKeys.putIfAbsent(day.id, () => GlobalKey());
                      return _DayCard(
                        key: _dayKeys[day.id],
                        day: day,
                        l: l,
                        onTap: (idx) async {
                          setState(() {
                            final d = data.days[i];
                            switch (idx) {
                              case 0:
                                d.fajr = !d.fajr;
                                break;
                              case 1:
                                d.dhuhr = !d.dhuhr;
                                break;
                              case 2:
                                d.asr = !d.asr;
                                break;
                              case 3:
                                d.maghrib = !d.maghrib;
                                break;
                              case 4:
                                d.isha = !d.isha;
                            }
                          });
                          await _save();
                          // إذا أصبح اليوم مكتملاً → مرر إليه
                          if (data.days[i].isComplete) {
                            _scrollAfterComplete();
                          }
                        },
                        onToggleComplete: () async {
                          setState(() {
                            final d = data.days[i];
                            final newVal = !d.isComplete;
                            d.fajr = newVal;
                            d.dhuhr = newVal;
                            d.asr = newVal;
                            d.maghrib = newVal;
                            d.isha = newVal;
                          });
                          await _save();
                          // بعد الاكتمال → مرر لآخر يوم مكتمل
                          if (data.days[i].isComplete) {
                            _scrollAfterComplete();
                          }
                        },
                        onDelete: () => _removeDay(i),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(l.noDaysYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final PrayerDay day;
  final AppLocalizations l;
  final Future<void> Function(int) onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const _DayCard({
    super.key,
    required this.day,
    required this.l,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isComplete = day.isComplete;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prayers = [
      _P(l.fajr, day.fajr, Icons.dark_mode_outlined),
      _P(l.dhuhr, day.dhuhr, Icons.wb_sunny_outlined),
      _P(l.asr, day.asr, Icons.wb_twilight),
      _P(l.maghrib, day.maghrib, Icons.wb_twilight),
      _P(l.isha, day.isha, Icons.nights_stay_outlined),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? (isComplete
                ? Colors.green.withValues(alpha: 0.15)
                : const Color(0xFF1A2332))
            : (isComplete
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete
              ? Colors.green
              : scheme.primary.withValues(alpha: 0.15),
          width: isComplete ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${l.isArabic ? "اليوم" : "Day"} ${day.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleComplete,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? Colors.green
                            : scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isComplete
                              ? Colors.green
                              : scheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isComplete
                                ? Icons.verified
                                : Icons.check_circle_outline,
                            size: 16,
                            color: isComplete
                                ? Colors.white
                                : scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isComplete ? l.dayComplete : l.completeDay,
                            style: TextStyle(
                              color: isComplete
                                  ? Colors.white
                                  : scheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.close,
                      size: 18, color: Colors.grey.shade500),
                  visualDensity: VisualDensity.compact,
                  tooltip: l.delete,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                return _PrayerCircle(
                  label: prayers[i].label,
                  value: prayers[i].value,
                  icon: prayers[i].icon,
                  onTap: () => onTap(i),
                );
              }),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: day.completedCount / 5,
                minHeight: 6,
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.completedCount}/5 ${l.isArabic ? "مكتمل" : "completed"}',
              style: TextStyle(
                fontSize: 11,
                color: isComplete ? Colors.green : Colors.grey,
                fontWeight:
                    isComplete ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _P {
  final String label;
  final bool value;
  final IconData icon;
  _P(this.label, this.value, this.icon);
}

class _PrayerCircle extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final VoidCallback onTap;

  const _PrayerCircle({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: value
                  ? Colors.green
                  : scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: value
                    ? Colors.green
                    : scheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 26)
                : Icon(icon,
                    color: scheme.primary.withValues(alpha: 0.5),
                    size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                color: value ? Colors.green : Colors.grey.shade700,
              )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final UserData data;
  final AppLocalizations l;
  const _SummaryCard({required this.data, required this.l});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = data.totalDays == 0
        ? 0.0
        : data.totalCompleted / (data.totalDays * 5);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (data.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(child: _stat(l.totalDays, '${data.totalDays}')),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                  child: _stat(l.completed, '${data.totalCompleted}')),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                  child: _stat(l.remaining, '${data.totalRemaining}')),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text('${l.progress}: ${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            )),
      ],
    );
  }
}
