import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'change_password_screen.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import 'sign_in_email_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;
  const LoginScreen({super.key, this.prefilledEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailC;
  final _pwC = TextEditingController();

  bool _hide = true;
  bool _loading = false;

  bool _wrongPw = false;
  bool _userNotFound = false;
  String? _topError;

  @override
  void initState() {
    super.initState();
    _emailC = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _emailC.dispose();
    _pwC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailC.text.trim();
    final pw = _pwC.text;

    setState(() {
      _loading = true;
      _wrongPw = false;
      _userNotFound = false;
      _topError = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pw);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _wrongPw = true;
          _topError = 'Wrong Password\nTry again!';
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          _userNotFound = true;
          _topError = 'Account not found.\nCreate one?';
        });
      } else {
        setState(() => _topError = e.message ?? 'Login fehlgeschlagen');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDeco({
    required String hint,
    bool error = false,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: error ? Colors.red : Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: error ? Colors.red : Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: error ? Colors.red : Colors.black54),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !_loading;
    final email = _emailC.text.trim();

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
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 34),

                  const Text(
                    'Enter your Username and Password',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  if (_topError != null) ...[
                    Text(
                      _topError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (_wrongPw || _userNotFound) ? Colors.red : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDeco(hint: 'Username'),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pwC,
                    obscureText: _hide,
                    decoration: _fieldDeco(
                      hint: 'Password',
                      error: _wrongPw,
                      suffix: IconButton(
                        onPressed: () => setState(() => _hide = !_hide),
                        icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: canTap
                        ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    )
                        : null,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canTap ? _login : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),

                  if (_userNotFound) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: canTap
                            ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CreateAccountScreen(prefilledEmail: email)),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEDEDED),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Create account', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Text(
                    "Don't have an Account yet?",
                    style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: canTap
                        ? () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignInEmailScreen()),
                      );
                    }
                        : null,
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
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
