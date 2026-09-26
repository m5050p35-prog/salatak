import 'package:flutter/material.dart';
import 'storage.dart';
import 'login_screen.dart';
import 'models.dart';
import 'duration_screen.dart';

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف آخر يوم؟'),
        content: const Text('سيتم حذف آخر صف نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
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

  Future<void> _resetDays() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين الجدول؟'),
        content: const Text('سيتم حذف جميع الأيام والبدء من جديد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إعادة تعيين'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول قضاء الصلاة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetDays,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDay,
        icon: const Icon(Icons.add),
        label: const Text('إضافة يوم'),
      ),
      body: Column(
        children: [
          _buildSummary(data),
          Expanded(child: _buildTable(data)),
        ],
      ),
    );
  }

  Widget _buildSummary(UserData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('الأيام', '${data.totalDays}')),
          Expanded(child: _stat('قضيت', '${data.totalCompleted}')),
          Expanded(child: _stat('المتبقي', '${data.totalRemaining}')),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTable(UserData data) {
    if (data.days.isEmpty) {
      return const Center(
        child: Text('لا توجد أيام بعد.\nاضغط "إضافة يوم" للبدء.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 8,
          horizontalMargin: 12,
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.primaryContainer,
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('الفجر')),
            DataColumn(label: Text('الظهر')),
            DataColumn(label: Text('العصر')),
            DataColumn(label: Text('المغرب')),
            DataColumn(label: Text('العشاء')),
          ],
          rows: data.days.map((day) {
            return DataRow(
              color: WidgetStatePropertyAll(
                  day.isComplete ? Colors.green.shade50 : null),
              cells: [
                DataCell(InkWell(
                  onLongPress: _removeLastDay,
                  child: Text('${day.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                )),
                _cell(day, 0),
                _cell(day, 1),
                _cell(day, 2),
                _cell(day, 3),
                _cell(day, 4),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _cell(PrayerDay day, int index) {
    bool value;
    switch (index) {
      case 0: value = day.fajr; break;
      case 1: value = day.dhuhr; break;
      case 2: value = day.asr; break;
      case 3: value = day.maghrib; break;
      default: value = day.isha;
    }
    return DataCell(
      InkWell(
        onTap: () async {
          setState(() {
            switch (index) {
              case 0: day.fajr = !day.fajr; break;
              case 1: day.dhuhr = !day.dhuhr; break;
              case 2: day.asr = !day.asr; break;
              case 3: day.maghrib = !day.maghrib; break;
              case 4: day.isha = !day.isha;
            }
          });
          await _save();
        },
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: value
                ? Colors.green
                : Colors.grey.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: value
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
