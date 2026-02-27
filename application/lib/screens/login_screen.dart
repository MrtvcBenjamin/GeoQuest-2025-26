import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/admin_access.dart';
import '../theme/app_text.dart';
import 'admin_first_time_setup_screen.dart';
import 'admin_map_screen.dart';
import 'change_password_screen.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import 'role_select_screen.dart';
import '../theme/app_settings.dart';

enum LoginRole { player, admin }

class LoginScreen extends StatefulWidget {
  final String? prefilledUsername;
  final LoginRole role;
  final String? infoText;

  const LoginScreen({
    super.key,
    this.prefilledUsername,
    this.role = LoginRole.player,
    this.infoText,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _errorText;
  String? _infoText;
  bool _wrongPasswordState = false;
  bool get _adminMode => widget.role == LoginRole.admin;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledUsername != null &&
        widget.prefilledUsername!.trim().isNotEmpty) {
      _usernameController.text = widget.prefilledUsername!.trim();
    }
    _infoText = widget.infoText;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidUsernameOrEmail(String value) {
    final input = value.trim();
    if (_adminMode) {
      final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      return emailRe.hasMatch(input);
    }
    if (input.contains('@')) {
      final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      return emailRe.hasMatch(input);
    }
    final usernameRe = RegExp(r'^[A-Za-z0-9._-]{3,24}$');
    return usernameRe.hasMatch(input);
  }

  Future<String?> _resolveEmailForLogin(String input) async {
    final trimmed = input.trim();
    if (trimmed.contains('@') || _adminMode) return trimmed.toLowerCase();

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
      _infoText = null;
      _wrongPasswordState = false;
    });

    if (!_isValidUsernameOrEmail(usernameOrEmail)) {
      setState(() => _errorText = _adminMode
          ? tr('Bitte gültige Admin-E-Mail eingeben.',
              'Please enter a valid admin email.')
          : tr('Bitte gib Username oder E-Mail ein.',
              'Please enter username or email.'));
      return;
    }
    if (pass.isEmpty) {
      setState(() => _errorText =
          tr('Bitte Passwort eingeben.', 'Please enter password.'));
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
      } else if (!_adminMode && !usernameOrEmail.contains('@')) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _legacyAuthEmailFromUsername(usernameOrEmail),
          password: pass,
        );
      } else {
        if (mounted) {
          setState(
            () => _errorText = tr(
                'Kein Konto mit diesem Username oder dieser E-Mail gefunden.',
                'No account found with this username or email.'),
          );
        }
        return;
      }

      if (!mounted) return;
      final currentUser = FirebaseAuth.instance.currentUser;
      final signedInEmail = currentUser?.email?.trim().toLowerCase();
      final isLegacyUser =
          signedInEmail != null && signedInEmail.endsWith('@geoquest.local');
      if (currentUser != null && !isLegacyUser && !currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(
            () => _errorText = tr(
              'E-Mail ist noch nicht verifiziert. Wir haben einen neuen Verifizierungslink gesendet.',
              'Email is not verified yet. We sent a new verification link.',
            ),
          );
        }
        return;
      }

      if (_adminMode && !AdminAccess.isAdminEmail(signedInEmail)) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(
            () => _errorText = tr(
              'Diese E-Mail ist nicht als Admin freigeschaltet.',
              'This email is not authorized as admin.',
            ),
          );
        }
        return;
      }

      await AppSettings.setLoginMode(
        _adminMode ? AppLoginMode.admin : AppLoginMode.player,
      );
      await AppSettings.setOnboardingDone(true);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => _adminMode ? const AdminMapScreen() : const HomeScreen(),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          message = tr('Username/E-Mail oder Passwort ist falsch.',
              'Username/email or password is incorrect.');
          _wrongPasswordState = true;
          break;
        case 'user-not-found':
          message = tr(
              'Kein Konto mit diesem Username oder dieser E-Mail gefunden.',
              'No account found with this username or email.');
          break;
        case 'too-many-requests':
          message = tr('Zu viele Versuche. Bitte später erneut probieren.',
              'Too many attempts. Please try again later.');
          break;
        case 'network-request-failed':
          message = tr('Keine Internetverbindung. Bitte Verbindung prüfen.',
              'No internet connection. Please check your connection.');
          break;
        default:
          message = e.message ?? tr('Login fehlgeschlagen.', 'Login failed.');
      }
      if (mounted) {
        setState(() => _errorText = message);
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorText = tr('Login fehlgeschlagen.', 'Login failed.'));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(role: widget.role),
      ),
    );
  }

  void _goToCreateAccount() {
    if (_adminMode) return;
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
          color:
              error ? const Color(0xFFE53935) : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              error ? const Color(0xFFE53935) : Theme.of(context).dividerColor,
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
                    _adminMode
                        ? tr('Admin Login mit E-Mail', 'Admin sign in with email')
                        : tr('Melde dich mit Username oder E-Mail an',
                            'Sign in with username or email'),
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
                      hint: _adminMode
                          ? tr('Admin E-Mail', 'Admin email')
                          : tr('Username oder E-Mail', 'Username or email'),
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
                      hint: 'Password',
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
                  if (_infoText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _infoText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.80),
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
                    child: Text(
                      tr('Passwort vergessen?', 'Forgot password?'),
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    scheme.onPrimary),
                              ),
                            )
                          : Text(
                              tr('Weiter', 'Continue'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!_adminMode) ...[
                    Text(
                      tr('Noch kein Konto?', 'No account yet?'),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface.withValues(alpha: 0.60),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _goToCreateAccount,
                      style:
                          TextButton.styleFrom(foregroundColor: scheme.onSurface),
                      child: Text(
                        tr('Registrieren', 'Sign up'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                  if (_adminMode)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminFirstTimeSetupScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                      child: Text(
                        tr('Erstes Admin-Login?', 'First admin login?'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectScreen(),
                        ),
                        (_) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                    child: Text(
                      tr('Rolle ändern', 'Change role'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
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
