import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final LoginRole role;

  const ChangePasswordScreen({
    super.key,
    this.role = LoginRole.player,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _userC = TextEditingController();

  bool _loading = false;
  String? _msg;
  String? _err;

  @override
  void dispose() {
    _userC.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final usernameOrEmail = _userC.text.trim();

    setState(() {
      _err = null;
      _msg = null;
    });

    if (usernameOrEmail.isEmpty) {
      setState(() => _err = tr('Bitte Username oder E-Mail eingeben.',
          'Please enter username or email.'));
      return;
    }

    setState(() => _loading = true);
    try {
      String? email;
      if (usernameOrEmail.contains('@')) {
        email = usernameOrEmail.toLowerCase();
      } else {
        final snap = await FirebaseFirestore.instance
            .collection('Users')
            .where('UsernameLower', isEqualTo: usernameOrEmail.toLowerCase())
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          email = snap.docs.first.data()['Email'] as String?;
        }
      }

      if (email == null || email.isEmpty) {
        setState(
          () => _err = tr(
              'Kein Konto mit diesem Username oder dieser E-Mail gefunden.',
              'No account found with this username or email.'),
        );
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(
        () => _msg = tr(
            'Reset-E-Mail gesendet. Bitte Link in der E-Mail öffnen.',
            'Reset email sent. Please open the link in your email.'),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        setState(() => _err = tr(
            'Keine Internetverbindung. Bitte Verbindung prüfen.',
            'No internet connection. Please check your connection.'));
      } else {
        setState(() => _err = e.message ??
            tr('Passwort-Reset fehlgeschlagen.', 'Password reset failed.'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 24),
                Text(
                  tr('Passwort zurücksetzen', 'Change password'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('Username oder E-Mail eingeben',
                      'Enter username or email'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userC,
                  keyboardType: TextInputType.text,
                  decoration: _fieldDecoration(
                    context: context,
                    hint: 'Username or email',
                  ),
                ),
                if (_err != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _err!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_msg != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _msg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  scheme.onPrimary),
                            ),
                          )
                        : Text(
                            tr('Weiter', 'Continue'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(role: widget.role),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            scheme.onSurface.withValues(alpha: 0.70),
                      ),
                      child: Text(
                        tr('Zum Login', 'Back to login'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.role == LoginRole.admin
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateAccountScreen(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor:
                            scheme.onSurface.withValues(alpha: 0.70),
                      ),
                      child: Text(
                        tr('Account erstellen', 'Create account'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
