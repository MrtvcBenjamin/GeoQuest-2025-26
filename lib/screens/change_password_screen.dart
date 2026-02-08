import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _emailC = TextEditingController();
  bool _loading = false;
  String? _msg;
  String? _err;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailC.text.trim();

    setState(() {
      _loading = true;
      _msg = null;
      _err = null;
    });

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _loading = false;
        _err = 'Bitte gültige Email eingeben';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _msg = 'Reset-Link wurde gesendet.');
    } on FirebaseAuthException catch (e) {
      setState(() => _err = e.message ?? 'Fehler beim Senden');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _deco(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: 'Email',
      filled: true,
      fillColor: isDark ? scheme.surface.withOpacity(0.65) : scheme.onSurface.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  const SizedBox(height: 34),

                  Text(
                    'Change Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive a reset link',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withOpacity(0.60),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _deco(context),
                  ),

                  const SizedBox(height: 10),
                  if (_err != null)
                    Text(
                      _err!,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  if (_msg != null)
                    Text(
                      _msg!,
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: canTap ? _sendReset : null,
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
