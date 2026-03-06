import 'package:flutter/material.dart';

import 'app_text.dart';

class AppSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
}

class AppRadius {
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
}

InputDecoration buildAppFieldDecoration({
  required BuildContext context,
  required String hint,
  Widget? suffixIcon,
  String? errorText,
  bool error = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final borderColor =
      error ? const Color(0xFFE53935) : Theme.of(context).dividerColor;

  return InputDecoration(
    hintText: hint,
    errorText: errorText,
    filled: true,
    fillColor: isDark
        ? scheme.surface.withValues(alpha: 0.65)
        : scheme.onSurface.withValues(alpha: 0.06),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: AppRadius.md,
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.md,
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.md,
      borderSide: BorderSide(
        color: error ? const Color(0xFFE53935) : scheme.primary,
        width: 1,
      ),
    ),
    suffixIcon: suffixIcon,
  );
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class AppMessageCard extends StatelessWidget {
  const AppMessageCard({
    super.key,
    required this.title,
    required this.body,
    this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: Text(tr('Erneut versuchen', 'Retry')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
