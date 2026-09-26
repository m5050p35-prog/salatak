import 'package:flutter/material.dart';
import 'storage.dart';
import 'tracker_screen.dart';
import 'models.dart';
import 'l10n/app_localizations.dart';

class DurationScreen extends StatefulWidget {
  final String userId;
  const DurationScreen({super.key, required this.userId});
  @override
  State<DurationScreen> createState() => _DurationScreenState();
}

class _DurationScreenState extends State<DurationScreen> {
  int? _selectedDays;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final options = <_Opt>[
      _Opt(l.oneDay, 1, Icons.today),
      _Opt(l.oneWeek, 7, Icons.view_week),
      _Opt(l.oneMonth, 30, Icons.calendar_month),
      _Opt(l.oneYear, 365, Icons.event),
      _Opt(l.custom, -1, Icons.tune),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.chooseDuration)),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primary,
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${l.welcome} ${widget.userId}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(l.chooseDurationSubtitle,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final o = options[i];
                      final selected = _selectedDays == o.days;
                      return _OptionCard(
                        label: o.label,
                        days: o.days,
                        icon: o.icon,
                        selected: selected,
                        l: l,
                        onTap: () async {
                          if (o.days == -1) {
                            final custom = await _askCustomDays(l);
                            if (custom != null && custom > 0) {
                              setState(() => _selectedDays = custom);
                            }
                          } else {
                            setState(() => _selectedDays = o.days);
                          }
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed:
                        (_selectedDays == null || _saving) ? null : _start,
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            l.start,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _askCustomDays(AppLocalizations l) async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.customDays),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: l.example15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(context, v);
            },
            child: Text(l.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _start() async {
    setState(() => _saving = true);
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

class _Opt {
  final String label;
  final int days;
  final IconData icon;
  _Opt(this.label, this.days, this.icon);
}

class _OptionCard extends StatelessWidget {
  final String label;
  final int days;
  final IconData icon;
  final bool selected;
  final AppLocalizations l;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.days,
    required this.icon,
    required this.selected,
    required this.l,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.primary : Colors.grey.withValues(alpha: 0.15),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : scheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: selected ? scheme.primary : null,
                ),
              ),
            ),
            if (days > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$days ${l.daysCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: scheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}
