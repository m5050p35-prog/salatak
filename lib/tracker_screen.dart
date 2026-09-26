import 'package:flutter/material.dart';
import 'storage.dart';
import 'login_screen.dart';
import 'models.dart';
import 'duration_screen.dart';
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
  }

  Future<void> _save() async {
    if (_data == null) return;
    await Storage.saveUser(_data!);
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

  Future<void> _removeLastDay() async {
    if (_data == null || _data!.days.isEmpty) return;
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteLastDay),
        content: Text(l.deleteLastDayNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _data!.days.removeLast());
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
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Storage.saveUser(UserData(identifier: widget.userId));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => DurationScreen(userId: widget.userId)),
      );
    }
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
          IconButton(
            tooltip: l.reset,
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      drawer: AppDrawer(onLogout: _logout, onReset: _reset),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDay,
        icon: const Icon(Icons.add),
        label: Text(l.addDay),
      ),
      body: Column(
        children: [
          _SummaryCard(data: data, l: l),
          Expanded(child: _Table(data: data, l: l, onLongPress: _removeLastDay, onToggle: (day, idx) async {
            setState(() {
              switch (idx) {
                case 0: day.fajr = !day.fajr; break;
                case 1: day.dhuhr = !day.dhuhr; break;
                case 2: day.asr = !day.asr; break;
                case 3: day.maghrib = !day.maghrib; break;
                case 4: day.isha = !day.isha;
              }
            });
            await _save();
          })),
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
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
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
          Row(
            children: [
              Expanded(child: _stat(l.totalDays, '${data.totalDays}')),
              Container(
                  width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(child: _stat(l.completed, '${data.totalCompleted}')),
              Container(
                  width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(child: _stat(l.remaining, '${data.totalRemaining}')),
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
          Text(
            '${l.progress}: ${(progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final UserData data;
  final AppLocalizations l;
  final VoidCallback onLongPress;
  final Future<void> Function(PrayerDay, int) onToggle;

  const _Table({
    required this.data,
    required this.l,
    required this.onLongPress,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (data.days.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              l.noDaysYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 90, left: 8, right: 8),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 6,
          horizontalMargin: 10,
          headingRowHeight: 46,
          dataRowMinHeight: 46,
          dataRowMaxHeight: 50,
          headingRowColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.12),
          ),
          columns: [
            DataColumn(
                label: Text('#',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
            DataColumn(
                label: Text(l.fajr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
            DataColumn(
                label: Text(l.dhuhr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
            DataColumn(
                label: Text(l.asr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
            DataColumn(
                label: Text(l.maghrib,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
            DataColumn(
                label: Text(l.isha,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary))),
          ],
          rows: data.days.map((day) {
            return DataRow(
              color: WidgetStatePropertyAll(
                day.isComplete
                    ? Colors.green.withValues(alpha: 0.08)
                    : null,
              ),
              cells: [
                DataCell(
                  InkWell(
                    onLongPress: onLongPress,
                    child: Text('${day.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                _cell(day, 0, context),
                _cell(day, 1, context),
                _cell(day, 2, context),
                _cell(day, 3, context),
                _cell(day, 4, context),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _cell(PrayerDay day, int index, BuildContext context) {
    bool value;
    switch (index) {
      case 0: value = day.fajr; break;
      case 1: value = day.dhuhr; break;
      case 2: value = day.asr; break;
      case 3: value = day.maghrib; break;
      default: value = day.isha;
    }
    final scheme = Theme.of(context).colorScheme;

    return DataCell(
      InkWell(
        onTap: () => onToggle(day, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
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
          ),
          child: value
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
