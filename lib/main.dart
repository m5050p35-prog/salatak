import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'storage.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/supabase_service.dart';
import 'login_screen.dart';
import 'tracker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // إذا فشل الاتصال، التطبيق يعمل offline
    // ignore: avoid_print
    print('Supabase init failed (offline mode): $e');
  }

  // تحميل الإعدادات
  final settings = SettingsProvider();
  await settings.load();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const SalatakApp(),
    ),
  );
}

class SalatakApp extends StatelessWidget {
  const SalatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Salatak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: settings.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});
  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  String? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = await Storage.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) return const LoginScreen();
    return TrackerScreen(userId: _user!);
  }
}
