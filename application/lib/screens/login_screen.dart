import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'change_password_screen.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;

  const LoginScreen({super.key, this.prefilledEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null &&
        widget.prefilledEmail!.trim().isNotEmpty) {
      _emailController.text = widget.prefilledEmail!.trim();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  void _appendToEmail(String text) {
    final old = _emailController.text;
    final sel = _emailController.selection;
    final start = sel.start >= 0 ? sel.start : old.length;
    final end = sel.end >= 0 ? sel.end : old.length;
    final next = old.replaceRange(start, end, text);
    _emailController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _appendToEmail(text);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    setState(() {
      _errorText = null;
    });

    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Bitte gib eine gueltige Email ein.');
      return;
    }
    if (pass.isEmpty) {
      setState(() => _errorText = 'Bitte Passwort eingeben.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          message = 'Email oder Passwort ist falsch.';
          break;
        case 'user-not-found':
          message = 'Kein Konto mit dieser Email gefunden.';
          break;
        case 'too-many-requests':
          message = 'Zu viele Versuche. Bitte spaeter erneut probieren.';
          break;
        default:
          message = e.message ?? 'Login fehlgeschlagen.';
      }
      if (mounted) setState(() => _errorText = message);
    } catch (_) {
      if (mounted) setState(() => _errorText = 'Login fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _goToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateAccountScreen(prefilledEmail: _emailController.text.trim()),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String hint,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? scheme.surface.withValues(alpha: 0.65)
          : scheme.onSurface.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 34),
              Image.asset('assets/logo.png', height: 92),
              const SizedBox(height: 16),
              Text(
                'GeoQuest',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Melde dich mit Email und Passwort an',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(context: context, hint: 'Email'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _appendToEmail('@'),
                    child: const Text('@'),
                  ),
                  OutlinedButton(
                    onPressed: () => _appendToEmail('gmail.com'),
                    child: const Text('gmail.com'),
                  ),
                  OutlinedButton(
                    onPressed: _pasteFromClipboard,
                    child: const Text('Einfuegen'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : _login(),
                decoration: _fieldDecoration(
                  context: context,
                  hint: 'Passwort',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    color: scheme.onSurface.withValues(alpha: 0.70),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToResetPassword,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurface.withValues(alpha: 0.60),
                ),
                child: const Text(
                  'Passwort vergessen?',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Noch kein Konto?",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: _goToCreateAccount,
                style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
