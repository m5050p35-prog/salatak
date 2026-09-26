import 'package:flutter/material.dart';
import 'storage.dart';
import 'login_screen.dart';
import 'tracker_screen.dart';

void main() => runApp(const SalatakApp());

class SalatakApp extends StatelessWidget {
  const SalatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صلاتك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0E7C66),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
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
