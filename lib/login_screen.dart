import 'package:flutter/material.dart';
import 'storage.dart';
import 'duration_screen.dart';
import 'tracker_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  Future<void> _login() async {
    final value = _ctrl.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'الرجاء إدخال البريد أو رقم الهاتف');
      return;
    }
    setState(() => _error = null);
    await Storage.setCurrentUser(value);
    final data = await Storage.loadUser(value);
    if (!mounted) return;
    if (data.days.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DurationScreen(userId: value)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TrackerScreen(userId: value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mosque, size: 70,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text('صلاتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text('تطبيق متابعة قضاء الصلاة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 60),
              const Text('أدخل بريدك الإلكتروني أو رقم هاتفك',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  hintText: 'example@mail.com أو 07XXXXXXXXX',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('دخول',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'لا حاجة لكلمة مرور، يتم حفظ تقدمك تلقائياً على جهازك.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
