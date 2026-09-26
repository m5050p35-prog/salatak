import 'package:flutter/material.dart';
import 'storage.dart';
import 'tracker_screen.dart';
import 'models.dart';

class DurationScreen extends StatefulWidget {
  final String userId;
  const DurationScreen({super.key, required this.userId});
  @override
  State<DurationScreen> createState() => _DurationScreenState();
}

class _DurationScreenState extends State<DurationScreen> {
  int? _selectedDays;
  final _options = {
    'يوم واحد': 1,
    'أسبوع': 7,
    'شهر': 30,
    'سنة': 365,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار المدة'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text('مرحباً ${widget.userId}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('اختر المدة التي تريد بها قضاء الصلاة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 30),
            ..._options.entries.map((e) => _buildOption(e.key, e.value)),
            _buildOption('مخصص', -1),
            const Spacer(),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _selectedDays == null ? null : _start,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ابدأ',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, int days) {
    final selected = _selectedDays == days;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () async {
          if (days == -1) {
            final custom = await _askCustomDays();
            if (custom != null && custom > 0) {
              setState(() => _selectedDays = custom);
            }
          } else {
            setState(() => _selectedDays = days);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              if (days > 0)
                Text('$days يوم',
                    style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _askCustomDays() async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('عدد الأيام المخصص'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'مثال: 15'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    final days = _selectedDays!;
    final data = UserData(identifier: widget.userId);
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final d = now.add(Duration(days: i));
      data.days.add(PrayerDay(
        id: i + 1,
        date:
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      ));
    }
    await Storage.saveUser(data);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TrackerScreen(userId: widget.userId)),
    );
  }
}
