import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'change_password_screen.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final String? prefilledUsername;
  final String? prefilledEmail;

  const CreateAccountScreen({
    super.key,
    this.prefilledUsername,
    this.prefilledEmail,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final TextEditingController _usernameC;
  late final TextEditingController _emailC;
  final _pwC = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameC = TextEditingController(text: widget.prefilledUsername ?? '');
    _emailC = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _emailC.dispose();
    _pwC.dispose();
    super.dispose();
  }

  bool _isValidUsername(String value) {
    final username = value.trim();
    final re = RegExp(r'^[A-Za-z0-9._-]{3,24}$');
    return re.hasMatch(username);
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  Future<void> _create() async {
    final username = _usernameC.text.trim();
    final email = _emailC.text.trim().toLowerCase();
    final password = _pwC.text;

    setState(() => _error = null);

    if (!_isValidUsername(username)) {
      setState(() => _error = 'Username muss 3-24 Zeichen haben (A-Z, 0-9, . _ -).');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = 'Bitte gültige E-Mail eingeben.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Passwort muss mindestens 6 Zeichen haben.');
      return;
    }

    setState(() => _loading = true);

    try {
      final usernameLower = username.toLowerCase();
      final usernameTaken = await FirebaseFirestore.instance
          .collection('Users')
          .where('UsernameLower', isEqualTo: usernameLower)
          .limit(1)
          .get();
      if (usernameTaken.docs.isNotEmpty) {
        setState(() => _error = 'Username existiert bereits.');
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'Username': username,
          'UsernameLower': usernameLower,
          'Email': email,
        }, SetOptions(merge: true));
      }

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(prefilledUsername: username),
        ),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Registrierung fehlgeschlagen.');
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Username, E-Mail und Passwort eingeben',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameC,
                  keyboardType: TextInputType.text,
                  decoration: _fieldDecoration(
                    context: context,
                    hint: 'Username',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(
                    context: context,
                    hint: 'E-Mail',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pwC,
                  obscureText: _hidePassword,
                  decoration: _fieldDecoration(
                    context: context,
                    hint: 'Passwort',
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      color: scheme.onSurface.withValues(alpha: 0.70),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _create,
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
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                  child: const Text(
                    'Bereits ein Konto? Sign in',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
