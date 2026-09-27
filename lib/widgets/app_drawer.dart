import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onReset;
  final VoidCallback onProfile;

  const AppDrawer({
    super.key,
    required this.onLogout,
    required this.onReset,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.mosque,
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(l.appName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                  Text(l.appSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Profile
            ListTile(
              leading: Icon(Icons.person_outline, color: scheme.primary),
              title: Text(l.profile),
              onTap: () {
                Navigator.pop(context);
                onProfile();
              },
            ),

            const Divider(),

            // Dark mode
            SwitchListTile(
              value: settings.isDark,
              onChanged: (v) => settings.toggleTheme(v),
              secondary: Icon(
                settings.isDark ? Icons.dark_mode : Icons.light_mode,
                color: scheme.primary),
              title: Text(l.darkMode),
              activeThumbColor: scheme.primary,
            ),

            const Divider(),

            // === الإشعارات ===
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.notifications_active,
                      color: scheme.primary),
                  const SizedBox(width: 16),
                  Text(l.notifications,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            SwitchListTile(
              value: settings.notificationsEnabled,
              onChanged: (v) async {
                if (v) {
                  final granted =
                      await NotificationService.requestPermission();
                  if (!granted) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(l.notificationPermissionDenied),
                        backgroundColor: Colors.red),
                    );
                    return;
                  }
                  await NotificationService.scheduleDaily(
                    time: settings.notificationTime,
                  );
                } else {
                  await NotificationService.cancelAll();
                }
                await settings.setNotificationEnabled(v);
              },
              secondary: Icon(Icons.alarm, color: scheme.primary),
              title: Text(l.dailyReminder),
              subtitle: Text(l.reminderEnabled),
              activeThumbColor: scheme.primary,
            ),

            ListTile(
              leading:
                  Icon(Icons.access_time, color: scheme.primary),
              title: Text(l.reminderTime),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.notificationTimeString,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.notificationTime,
                  helpText: l.chooseReminderTime,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  await settings.setNotificationTime(picked);
                  if (settings.notificationsEnabled) {
                    await NotificationService.scheduleDaily(time: picked);
                  }
                }
              },
            ),

            ListTile(
              leading: Icon(Icons.notification_add,
                  color: scheme.primary),
              title: Text(l.testNotification),
              onTap: () async {
                final granted =
                    await NotificationService.requestPermission();
                if (!granted) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.notificationPermissionDenied),
                      backgroundColor: Colors.red),
                  );
                  return;
                }
                await NotificationService.showTestNotification();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.notificationSent)),
                );
              },
            ),

            const Divider(),

            // Language
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.language, color: scheme.primary),
                  const SizedBox(width: 16),
                  Text(l.language,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            RadioGroup<String>(
              groupValue: settings.locale.languageCode,
              onChanged: (v) {
                if (v != null) settings.setLocale(v);
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'ar',
                    title: Text(l.arabic),
                    activeColor: scheme.primary,
                    dense: true,
                  ),
                  RadioListTile<String>(
                    value: 'en',
                    title: Text(l.english),
                    activeColor: scheme.primary,
                    dense: true,
                  ),
                ],
              ),
            ),

            const Divider(),

            ListTile(
              leading: Icon(Icons.refresh, color: scheme.primary),
              title: Text(l.reset),
              onTap: () {
                Navigator.pop(context);
                onReset();
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.info_outline, color: scheme.primary),
              title: Text(l.about),
              subtitle: Text('${l.version} 3.0.0'),
              onTap: () {
                Navigator.pop(context);
                _showAbout(context, l);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l.logout,
                  style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context, AppLocalizations l) {
    showAboutDialog(
      context: context,
      applicationName: l.appName,
      applicationVersion: '3.0.0',
      applicationIcon: const Icon(Icons.mosque, size: 40),
      children: [Text(l.aboutText)],
    );
  }
}
