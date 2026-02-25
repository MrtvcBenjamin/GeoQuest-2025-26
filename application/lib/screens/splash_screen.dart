import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_settings.dart';
import 'home_screen.dart';
import 'onboarding_flow.dart';
import 'sign_in_email_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      final showOnboarding = !AppSettings.onboardingDone.value;
      final next = user != null
          ? const HomeScreen()
          : (showOnboarding ? const OnboardingFlow() : const SignInEmailScreen());

      if (user != null) {
        AppSettings.setOnboardingDone(true);
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 4),
              _SplashBrand(color: scheme.onSurface),
              const SizedBox(height: 120),
              _SpinnerRing(size: 58, color: scheme.onSurface),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  final Color color;

  const _SplashBrand({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/logo.png',
          width: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 14),
        Text(
          'GeoQuest',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SpinnerRing extends StatefulWidget {
  final double size;
  final Color color;

  const _SpinnerRing({required this.size, required this.color});

  @override
  State<_SpinnerRing> createState() => _SpinnerRingState();
}

class _SpinnerRingState extends State<_SpinnerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        size: Size.square(widget.size),
        painter: _SpinnerPainter(progress: _c.value, color: widget.color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SpinnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    const dotCount = 12;
    final dotRadius = size.width * 0.06;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * math.pi * 2;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      final head = progress * dotCount;
      final dist = (i - head).abs();
      final wrappedDist = math.min(dist, dotCount - dist);
      final t = (1.0 - (wrappedDist / (dotCount / 2))).clamp(0.0, 1.0);
      final opacity = (0.10 + 0.90 * t).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center + Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
