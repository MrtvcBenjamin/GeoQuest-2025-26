import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_validators.dart';
import '../services/telemetry_service.dart';
import '../services/user_repository.dart';
import '../theme/app_text.dart';
import '../theme/app_ui.dart';
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
  final UserRepository _users = UserRepository();

  bool _loading = false;
  String? _msg;
  String? _err;
  bool _showRetry = false;

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
      _showRetry = false;
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
        if (!AuthValidators.isValidEmail(usernameOrEmail)) {
          setState(() => _err = tr(
              'Bitte gültige E-Mail eingeben.', 'Please enter a valid email.'));
          return;
        }
        email = usernameOrEmail.toLowerCase();
      } else {
        email = await _users.emailForUsername(usernameOrEmail.toLowerCase());
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
      await TelemetryService.logEvent('password_reset_email_sent');
      setState(
        () => _msg = tr(
            'Reset-E-Mail gesendet. Bitte Link in der E-Mail öffnen und auch den Spam-Ordner prüfen. Bei Schul-E-Mails (z. B. @o365.htl-leoben.at) kann die Zustellung einige Minuten dauern.',
            'Reset email sent. Please open the link in your email and also check your spam folder. For school emails (e.g. @o365.htl-leoben.at), delivery can take a few minutes.'),
      );
    } on FirebaseAuthException catch (e) {
      await TelemetryService.logEvent(
        'password_reset_failed',
        params: {'code': e.code},
      );
      if (e.code == 'network-request-failed') {
        setState(() {
          _err = tr('Keine Internetverbindung. Bitte Verbindung prüfen.',
              'No internet connection. Please check your connection.');
          _showRetry = true;
        });
      } else {
        setState(() {
          _err = e.message ??
              tr('Passwort-Reset fehlgeschlagen.', 'Password reset failed.');
          _showRetry = true;
        });
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
    return buildAppFieldDecoration(
      context: context,
      hint: hint,
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
                  if (_showRetry) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _loading ? null : _continue,
                      child: Text(tr('Erneut versuchen', 'Try again')),
                    ),
                  ],
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




