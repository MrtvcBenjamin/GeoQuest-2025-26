import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'login_screen.dart';

class SignInEmailScreen extends StatefulWidget {
  const SignInEmailScreen({super.key});

  @override
  State<SignInEmailScreen> createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends State<SignInEmailScreen> {
  final _emailC = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  void _continue() {
    final email = _emailC.text.trim();

    setState(() => _error = null);

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Bitte gültige Email eingeben');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen(prefilledEmail: email)),
    );
  }

  Future<void> _google() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Google Login fehlgeschlagen');
    } catch (_) {
      setState(() => _error = 'Google Login fehlgeschlagen');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'GeoQuest',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Create an account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email to sign up for this app',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'email@domain.com',
                      errorText: _error,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canTap ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text('or', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: canTap ? _google : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDEDED),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Android-only aktuell: Apple disabled.
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDEDED),
                        foregroundColor: Colors.black54,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Continue with Apple', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'By clicking continue, you agree to our Terms of Service\nand Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black45, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
