import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/admin_access.dart';
import '../theme/app_text.dart';
import 'login_screen.dart';

class AdminFirstTimeSetupScreen extends StatefulWidget {
  const AdminFirstTimeSetupScreen({super.key});

  @override
  State<AdminFirstTimeSetupScreen> createState() =>
      _AdminFirstTimeSetupScreenState();
}

class _AdminFirstTimeSetupScreenState extends State<AdminFirstTimeSetupScreen> {
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();
  final _pwConfirmC = TextEditingController();

  bool _hidePw = true;
  bool _hidePwConfirm = true;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailC.dispose();
    _pwC.dispose();
    _pwConfirmC.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  Future<void> _setupAdmin() async {
    final email = _emailC.text.trim().toLowerCase();
    final pw = _pwC.text;
    final pw2 = _pwConfirmC.text;

    setState(() {
      _error = null;
      _info = null;
    });

    if (!_isValidEmail(email)) {
      setState(() => _error = tr(
            'Bitte gültige E-Mail eingeben.',
            'Please enter a valid email.',
          ));
      return;
    }
    if (!AdminAccess.isAdminEmail(email)) {
      setState(() => _error = tr(
            'Diese E-Mail ist nicht als Admin freigeschaltet.',
            'This email is not authorized as admin.',
          ));
      return;
    }
    if (pw.length < 6) {
      setState(() => _error = tr(
            'Passwort muss mindestens 6 Zeichen haben.',
            'Password must have at least 6 characters.',
          ));
      return;
    }
    if (pw != pw2) {
      setState(() => _error = tr(
            'Passwörter stimmen nicht überein.',
            'Passwords do not match.',
          ));
      return;
    }

    setState(() => _loading = true);
    try {
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pw,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;

        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pw,
        );
      }

      final user = cred.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            role: LoginRole.admin,
            prefilledUsername: email,
            infoText: tr(
              'Verifizierungs-E-Mail gesendet. Bitte zuerst bestätigen und danach als Admin anmelden.',
              'Verification email sent. Please verify first, then sign in as admin.',
            ),
          ),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = tr(
            'Für diese Admin-E-Mail existiert bereits ein Konto mit anderem Passwort.',
            'An account for this admin email already exists with a different password.',
          );
          break;
        case 'network-request-failed':
          message = tr(
            'Keine Internetverbindung. Bitte Verbindung prüfen.',
            'No internet connection. Please check your connection.',
          );
          break;
        default:
          message = e.message ??
              tr(
                'Admin-Setup fehlgeschlagen.',
                'Admin setup failed.',
              );
      }
      if (mounted) setState(() => _error = message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = tr(
            'Admin-Setup fehlgeschlagen.',
            'Admin setup failed.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec({
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
                const SizedBox(height: 28),
                Image.asset('assets/logo.png', height: 92),
                const SizedBox(height: 16),
                Text(
                  tr('Admin-Ersteinrichtung', 'Admin first-time setup'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'Admin-E-Mail verifizieren und Passwort festlegen.',
                    'Verify admin email and set your password.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec(
                    context: context,
                    hint: tr('Admin E-Mail', 'Admin email'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pwC,
                  obscureText: _hidePw,
                  decoration: _dec(
                    context: context,
                    hint: tr('Passwort', 'Password'),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _hidePw = !_hidePw),
                      icon: Icon(
                        _hidePw ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pwConfirmC,
                  obscureText: _hidePwConfirm,
                  decoration: _dec(
                    context: context,
                    hint: tr('Passwort wiederholen', 'Repeat password'),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePwConfirm = !_hidePwConfirm),
                      icon: Icon(
                        _hidePwConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_info != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _info!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.80),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _setupAdmin,
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
                                scheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            tr('Verifizieren und speichern',
                                'Verify and save'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(tr('Zurück', 'Back')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
