import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final String? prefilledEmail;
  const CreateAccountScreen({super.key, this.prefilledEmail});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final TextEditingController _emailC;
  final _pw1C = TextEditingController();
  final _pw2C = TextEditingController();

  bool _hide1 = true;
  bool _hide2 = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailC = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _emailC.dispose();
    _pw1C.dispose();
    _pw2C.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final email = _emailC.text.trim();
    final p1 = _pw1C.text;
    final p2 = _pw2C.text;

    setState(() => _error = null);

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Bitte gültige Email eingeben');
      return;
    }
    if (p1.length < 6) {
      setState(() => _error = 'Passwort muss mindestens 6 Zeichen haben');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'Passwörter stimmen nicht überein');
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: p1);

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();

        await _saveUserInDatabase(userCredential.user!.uid, email);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Registrierung fehlgeschlagen');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveUserInDatabase(String uid, String email) async {
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'Username': null,
      'email': email,
      'totalPoints': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  InputDecoration _deco(BuildContext context, String hint, {Widget? suffix}) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? scheme.surface.withOpacity(0.65) : scheme.onSurface.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canTap = !_loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset('assets/logo.png', width: 120),
                  const SizedBox(height: 12),
                  Text(
                    'GeoQuest',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _deco(context, 'Email'),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pw1C,
                    obscureText: _hide1,
                    decoration: _deco(
                      context,
                      'Password',
                      suffix: IconButton(
                        onPressed: () => setState(() => _hide1 = !_hide1),
                        icon: Icon(_hide1 ? Icons.visibility : Icons.visibility_off),
                        color: scheme.onSurface.withOpacity(0.70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pw2C,
                    obscureText: _hide2,
                    decoration: _deco(
                      context,
                      'Password (repeat)',
                      suffix: IconButton(
                        onPressed: () => setState(() => _hide2 = !_hide2),
                        icon: Icon(_hide2 ? Icons.visibility : Icons.visibility_off),
                        color: scheme.onSurface.withOpacity(0.70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  if (_error != null)
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canTap ? _create : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                        ),
                      )
                          : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
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
