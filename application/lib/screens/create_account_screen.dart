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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: p1);

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

  InputDecoration _deco(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffix,
    );
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
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _deco('Email'),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pw1C,
                    obscureText: _hide1,
                    decoration: _deco(
                      'Password',
                      suffix: IconButton(
                        onPressed: () => setState(() => _hide1 = !_hide1),
                        icon: Icon(_hide1 ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _pw2C,
                    obscureText: _hide2,
                    decoration: _deco(
                      'Password (repeat)',
                      suffix: IconButton(
                        onPressed: () => setState(() => _hide2 = !_hide2),
                        icon: Icon(_hide2 ? Icons.visibility : Icons.visibility_off),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
