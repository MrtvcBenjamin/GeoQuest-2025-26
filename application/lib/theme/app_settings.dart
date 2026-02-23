import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _kThemeModeKey = 'theme_mode';
  static const _kNotificationsKey = 'notifications_enabled';
  static const _kOnboardingDoneKey = 'onboarding_done';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static final ValueNotifier<bool> notificationsEnabled =
      ValueNotifier<bool>(true);
  static final ValueNotifier<bool> onboardingDone = ValueNotifier<bool>(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final mode = prefs.getString(_kThemeModeKey);
    themeMode.value = (mode == 'dark') ? ThemeMode.dark : ThemeMode.light;

    final notif = prefs.getBool(_kNotificationsKey);
    notificationsEnabled.value = notif ?? true;

    final onboarded = prefs.getBool(_kOnboardingDoneKey);
    onboardingDone.value = onboarded ?? false;
  }

  static Future<void> toggleTheme(bool dark) async {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, dark ? 'dark' : 'light');
  }

  static Future<void> toggleNotifications(bool enabled) async {
    notificationsEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, enabled);
  }

  static Future<void> setOnboardingDone(bool done) async {
    onboardingDone.value = done;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, done);
  }
}
