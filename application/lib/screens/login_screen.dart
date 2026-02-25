import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'change_password_screen.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import '../theme/app_settings.dart';

class LoginScreen extends StatefulWidget {
  final String? prefilledUsername;

  const LoginScreen({super.key, this.prefilledUsername});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _errorText;
  bool _wrongPasswordState = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledUsername != null &&
        widget.prefilledUsername!.trim().isNotEmpty) {
      _usernameController.text = widget.prefilledUsername!.trim();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidUsernameOrEmail(String value) {
    final input = value.trim();
    if (input.contains('@')) {
      final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      return emailRe.hasMatch(input);
    }
    final usernameRe = RegExp(r'^[A-Za-z0-9._-]{3,24}$');
    return usernameRe.hasMatch(input);
  }

  Future<String?> _resolveEmailForLogin(String input) async {
    final trimmed = input.trim();
    if (trimmed.contains('@')) return trimmed.toLowerCase();

    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .where('UsernameLower', isEqualTo: trimmed.toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;

    final data = snap.docs.first.data();
    final email = data['Email'] as String?;
    if (email == null || email.isEmpty) return null;
    return email.toLowerCase();
  }

  String _legacyAuthEmailFromUsername(String username) {
    final normalized = username.trim().toLowerCase();
    final safe = normalized.replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
    return '$safe@geoquest.local';
  }

  Future<void> _login() async {
    final usernameOrEmail = _usernameController.text.trim();
    final pass = _passwordController.text;

    setState(() {
      _errorText = null;
      _wrongPasswordState = false;
    });

    if (!_isValidUsernameOrEmail(usernameOrEmail)) {
      setState(() => _errorText = 'Bitte gib Username oder E-Mail ein.');
      return;
    }
    if (pass.isEmpty) {
      setState(() => _errorText = 'Bitte Passwort eingeben.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authEmail = await _resolveEmailForLogin(usernameOrEmail);
      if (authEmail != null) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: authEmail,
          password: pass,
        );
      } else if (!usernameOrEmail.contains('@')) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _legacyAuthEmailFromUsername(usernameOrEmail),
          password: pass,
        );
      } else {
        if (mounted) {
          setState(
            () => _errorText =
                'Kein Konto mit diesem Username oder dieser E-Mail gefunden.',
          );
        }
        return;
      }

      if (!mounted) return;
      await AppSettings.setOnboardingDone(true);
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
          message = 'Username/E-Mail oder Passwort ist falsch.';
          _wrongPasswordState = true;
          break;
        case 'user-not-found':
          message = 'Kein Konto mit diesem Username oder dieser E-Mail gefunden.';
          break;
        case 'too-many-requests':
          message = 'Zu viele Versuche. Bitte später erneut probieren.';
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
        builder: (_) => CreateAccountScreen(
          prefilledUsername: _usernameController.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String hint,
    Widget? suffixIcon,
    bool error = false,
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
        borderSide: BorderSide(
          color: error ? const Color(0xFFE53935) : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error ? const Color(0xFFE53935) : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error ? const Color(0xFFE53935) : scheme.primary,
          width: 1,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 0, 24, keyboardInset + 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                    'Melde dich mit Username oder E-Mail an',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      context: context,
                      hint: 'Username oder E-Mail',
                    ),
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
                      error: _wrongPasswordState,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        color: scheme.onSurface.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
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
                    'Noch kein Konto?',
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
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
