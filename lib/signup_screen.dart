import 'package:flutter/material.dart';
import 'storage.dart';
import 'models.dart';
import 'duration_screen.dart';
import 'l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  final String? prefillEmail;
  const SignupScreen({super.key, this.prefillEmail});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillEmail != null) {
      _emailCtrl.text = widget.prefillEmail!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();

    final exists = await Storage.userExists(email);
    if (!mounted) return;
    if (exists) {
      setState(() => _loading = false);
      _showExistsDialog();
      return;
    }

    final data = UserData(identifier: email, name: name);
    await Storage.setCurrentUser(email);
    await Storage.saveUser(data);

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DurationScreen(userId: email)),
    );
  }

  void _showExistsDialog() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.isArabic ? 'حساب موجود' : 'Account exists'),
        content: Text(l.accountExists),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l.goToLogin),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 54,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.signupTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            Text(
                              l.nameLabel,
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
                                if (err == 'empty') return l.nameRequired;
                                if (err == 'short') return l.nameShort;
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: l.nameHint,
                                prefixIcon:
                                    const Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l.emailLabel,
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
                              onFieldSubmitted: (_) => _signup(),
                              validator: (v) {
                                final err = Storage.validateGmail(v ?? '');
                                if (err == 'empty') return l.emailRequired;
                                if (err == 'not_gmail') {
                                  return l.emailGmailOnly;
                                }
                                if (err == 'invalid') {
                                  return l.emailInvalid;
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'example@gmail.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: _loading ? null : _signup,
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        l.signup,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    l.or,
                                    style: TextStyle(
                                        color: Colors.grey.shade500),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.login),
                              label: Text(
                                l.goToLogin,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
    );
  }
}
