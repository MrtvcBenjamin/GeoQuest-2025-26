import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'theme/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  await AppSettings.load();

  runApp(const GeoQuestApp());
}

class GeoQuestApp extends StatelessWidget {
  const GeoQuestApp({super.key});

  ThemeData _lightTheme() {
    const bg = Colors.white;
    const onBg = Colors.black;

    final scheme = const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      secondary: Colors.black,
      onSecondary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        foregroundColor: onBg,
      ),
      dividerColor: Colors.black.withValues(alpha: 0.15),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withValues(alpha: 0.35),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.black.withValues(alpha: 0.20);
        }),
      ),
    );
  }

  ThemeData _darkTheme() {
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const onBg = Colors.white;

    final scheme = const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: surface,
      onSurface: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        foregroundColor: onBg,
      ),
      dividerColor: Colors.white.withValues(alpha: 0.15),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.45),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white.withValues(alpha: 0.55);
          }
          return Colors.white.withValues(alpha: 0.20);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<AppLanguage>(
          valueListenable: AppSettings.language,
          builder: (context, language, ___) {
            final locale = language == AppLanguage.en
                ? const Locale('en')
                : const Locale('de');
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: mode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('de'),
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
