import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.teacherName,
    required this.stationName,
  });

  final String teacherName;
  final String stationName;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _pointsC = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pointsC.dispose();
    super.dispose();
  }

  void _submitPoints() {
    final raw = _pointsC.text.trim().replaceAll(',', '.');
    final points = double.tryParse(raw);
    setState(() => _error = null);

    if (points == null) {
      setState(() => _error =
          tr('Bitte gültige Punkte eingeben.', 'Please enter valid points.'));
      return;
    }
    if (points < 0 || points > 10) {
      setState(() => _error = tr('Nur Werte von 0.0 bis 10.0 sind erlaubt.',
          'Only values from 0.0 to 10.0 are allowed.'));
      return;
    }

    Navigator.of(context).pop(double.parse(points.toStringAsFixed(1)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  tr('Punkte vergeben', 'Rate points'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.teacherName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.stationName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tr('Punkte (0.0 bis 10.0, max. 1 Nachkommastelle)',
                      'Points (0.0 to 10.0, max. 1 decimal place)'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _pointsC,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,2}([.,]\d?)?$')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: tr('z.B. 8.5', 'e.g. 8.5'),
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
                      color: Colors.red,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitPoints,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr('Punkte speichern', 'Save points'),
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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

