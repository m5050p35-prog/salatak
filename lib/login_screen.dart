import 'package:flutter/material.dart';
import 'storage.dart';
import 'models.dart';
import 'duration_screen.dart';
import 'tracker_screen.dart';
import 'l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();

    await Storage.setCurrentUser(email);
    final data = await Storage.loadUser(email);

    if (data.name != name) {
      final updated = UserData(
        identifier: email,
        name: name,
        days: data.days,
      );
      await Storage.saveUser(updated);
      if (!mounted) return;
      setState(() => _loading = false);
      _navigate(updated);
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);
    _navigate(data);
  }

  void _navigate(UserData data) {
    if (data.days.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DurationScreen(userId: data.identifier)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrackerScreen(userId: data.identifier)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isAr = l.isArabic;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary,
              scheme.primary.withValues(alpha: 0.85),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.4, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mosque,
                          size: 66,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l.appName,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.appSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ===== الاسم =====
                                Text(
                                  isAr ? 'الاسم' : 'Name',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameCtrl,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    final err = Storage.validateName(v ?? '');
                                    if (err == 'empty') {
                                      return isAr
                                          ? 'الرجاء إدخال الاسم'
                                          : 'Please enter your name';
                                    }
                                    if (err == 'short') {
                                      return isAr
                                          ? 'الاسم قصير جداً'
                                          : 'Name too short';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        isAr ? 'مثال: أحمد' : 'e.g. Ahmed',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ===== البريد =====
                                Text(
                                  isAr ? 'البريد الإلكتروني' : 'Email',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  validator: (v) {
                                    final err = Storage.validateEmail(v ?? '');
                                    if (err == 'empty') {
                                      return isAr
                                          ? 'الرجاء إدخال البريد'
                                          : 'Please enter email';
                                    }
                                    if (err == 'invalid') {
                                      return isAr
                                          ? 'صيغة البريد غير صحيحة'
                                          : 'Invalid email format';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'example@mail.com',
                                    prefixIcon:
                                        Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // ===== زر الدخول =====
                                SizedBox(
                                  height: 54,
                                  child: FilledButton(
                                    onPressed: _loading ? null : _login,
                                    child: _loading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            l.login,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.noPasswordNote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
