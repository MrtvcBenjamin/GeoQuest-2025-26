import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { de, en }
enum AppLoginMode { player, admin }

class AppSettings {
  static const _kThemeModeKey = 'theme_mode';
  static const _kNotificationsKey = 'notifications_enabled';
  static const _kOnboardingDoneKey = 'onboarding_done';
  static const _kLanguageKey = 'language_code';
  static const _kLoginModeKey = 'login_mode';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);
  static final ValueNotifier<AppLanguage> language =
      ValueNotifier<AppLanguage>(AppLanguage.de);
  static final ValueNotifier<AppLoginMode?> loginMode =
      ValueNotifier<AppLoginMode?>(null);

  static final ValueNotifier<bool> notificationsEnabled =
      ValueNotifier<bool>(true);
  static final ValueNotifier<bool> onboardingDone = ValueNotifier<bool>(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final mode = prefs.getString(_kThemeModeKey);
    themeMode.value = (mode == 'dark') ? ThemeMode.dark : ThemeMode.light;

    final lang = prefs.getString(_kLanguageKey);
    language.value = (lang == 'en') ? AppLanguage.en : AppLanguage.de;

    final login = prefs.getString(_kLoginModeKey);
    if (login == 'admin') {
      loginMode.value = AppLoginMode.admin;
    } else if (login == 'player') {
      loginMode.value = AppLoginMode.player;
    } else {
      loginMode.value = null;
    }

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

  static Future<void> setLanguage(AppLanguage value) async {
    language.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageKey, value == AppLanguage.en ? 'en' : 'de');
  }

  static Future<void> setLoginMode(AppLoginMode value) async {
    loginMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLoginModeKey,
      value == AppLoginMode.admin ? 'admin' : 'player',
    );
  }

  static Future<void> clearLoginMode() async {
    loginMode.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoginModeKey);
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
