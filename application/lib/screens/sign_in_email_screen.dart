import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SignInEmailScreen extends StatefulWidget {
  const SignInEmailScreen({super.key});

  @override
  State<SignInEmailScreen> createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends State<SignInEmailScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(email);
  }

  bool get _appleLoginAvailable {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  void _appendToEmail(String text) {
    final old = _emailController.text;
    final sel = _emailController.selection;
    final start = sel.start >= 0 ? sel.start : old.length;
    final end = sel.end >= 0 ? sel.end : old.length;
    final next = old.replaceRange(start, end, text);
    _emailController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _appendToEmail(text);
  }

  void _continue() {
    final email = _emailController.text.trim();
    setState(() => _errorText = null);

    if (!_isValidEmail(email)) {
      setState(() => _errorText = 'Bitte gib eine gueltige Email ein.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(prefilledEmail: email),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
            () => _errorText = e.message ?? 'Google Login fehlgeschlagen.');
      }
    } on PlatformException catch (e) {
      // ApiException: 10 => SHA-1/SHA-256 mismatch or OAuth client misconfiguration.
      final msg = (e.message ?? '').toLowerCase();
      final code = e.code.toLowerCase();
      final isApi10 = msg.contains('apiexception: 10') ||
          msg.contains('10:') ||
          code.contains('sign_in_failed');

      if (mounted) {
        setState(
          () => _errorText = isApi10
              ? 'Google Login ist noch nicht korrekt konfiguriert (SHA/OAuth). Bitte vorerst Email+Passwort nutzen.'
              : 'Google Login fehlgeschlagen.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'Google Login fehlgeschlagen.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (!_appleLoginAvailable) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256OfString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw PlatformException(
          code: 'apple_sign_in_no_token',
          message: 'Kein Identity Token von Apple erhalten.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorText = e.message ?? 'Apple Login fehlgeschlagen.');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (mounted) {
        if (e.code == AuthorizationErrorCode.canceled) {
          setState(() => _errorText = null);
        } else {
          setState(() => _errorText = 'Apple Login fehlgeschlagen.');
        }
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorText =
              'Apple Login fehlt noch in Apple/Firebase-Konfiguration.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _emailDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: 'Email',
      errorText: _errorText,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/logo.png', height: 90),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
                decoration: _emailDecoration(context),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _appendToEmail('@'),
                    child: const Text('@'),
                  ),
                  OutlinedButton(
                    onPressed: () => _appendToEmail('gmail.com'),
                    child: const Text('gmail.com'),
                  ),
                  OutlinedButton(
                    onPressed: _pasteFromClipboard,
                    child: const Text('Einfuegen'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _isLoading || !_appleLoginAvailable
                      ? null
                      : _signInWithApple,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _appleLoginAvailable
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.35),
                    side: BorderSide(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.9),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _appleLoginAvailable
                        ? 'Continue with Apple'
                        : 'Continue with Apple (iOS only)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
