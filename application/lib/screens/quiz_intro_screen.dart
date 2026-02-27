import 'package:flutter/material.dart';

import '../theme/app_text.dart';

import 'quiz_screen.dart';

class QuizIntroScreen extends StatefulWidget {
  const QuizIntroScreen({
    super.key,
    required this.stationName,
    required this.teacherName,
  });

  final String stationName;
  final String teacherName;

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  final TextEditingController _passwordC = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _error = null);
    if (_passwordC.text.trim() != '123') {
      setState(() =>
          _error = tr('Falsches Lehrer-Passwort.', 'Wrong teacher password.'));
      return;
    }

    final points = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          teacherName: widget.teacherName,
          stationName: widget.stationName,
        ),
      ),
    );

    if (!mounted || points == null) return;
    Navigator.of(context).pop(points);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                Text(
                  tr('Aufgabe freigeben', 'Unlock task'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.teacherName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.stationName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _passwordC,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: tr('Lehrer Passwort (Test: 123)',
                        'Teacher password (test: 123)'),
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w800),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _continue,
                    child: Text(
                      tr('Weiter zur Punktevergabe', 'Continue to scoring'),
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

