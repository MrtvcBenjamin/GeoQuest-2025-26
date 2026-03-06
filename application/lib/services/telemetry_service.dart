import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  static FirebaseAnalytics? _analytics;
  static bool _enabled = false;

  static Future<void> init() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  static Future<void> setUserId(String? uid) async {
    if (!_enabled || _analytics == null) return;
    try {
      await _analytics!.setUserId(id: uid);
    } catch (_) {}
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object?> params = const {},
  }) async {
    if (!_enabled || _analytics == null) return;
    try {
      final filtered = <String, Object>{};
      params.forEach((key, value) {
        if (value == null) return;
        filtered[key] = value;
      });
      await _analytics!.logEvent(name: name, parameters: filtered);
    } catch (_) {}
  }

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    String reason = 'unhandled_error',
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('Telemetry error [$reason]: $error');
      debugPrintStack(stackTrace: stack);
    }
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }
}
