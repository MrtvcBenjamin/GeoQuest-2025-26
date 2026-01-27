import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'onboarding_flow.dart';

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user != null ? const HomeScreen() : const OnboardingFlow(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LogoBlock(),
              SizedBox(height: 44),
              _DottedCircleLoader(size: 46),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: 240,
      fit: BoxFit.contain,
    );
  }
}

class _DottedCircleLoader extends StatefulWidget {
  final double size;
  const _DottedCircleLoader({required this.size});

  @override
  State<_DottedCircleLoader> createState() => _DottedCircleLoaderState();
}

class _DottedCircleLoaderState extends State<_DottedCircleLoader>
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
        painter: _DottedCirclePainter(progress: _c.value),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final double progress;
  const _DottedCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    const dotCount = 12;
    final baseDotR = size.width * 0.045;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * math.pi * 2;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      // "laufender" heller Punkt
      final head = (progress * dotCount);
      final dist = (i - head).abs();
      final wrappedDist = math.min(dist, dotCount - dist);

      final t = (1.0 - (wrappedDist / (dotCount / 2))).clamp(0.0, 1.0);
      final opacity = (0.18 + 0.82 * t).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.black.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center + Offset(dx, dy), baseDotR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
