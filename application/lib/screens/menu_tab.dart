import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_settings.dart';
import 'sign_in_email_screen.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/menu',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/menu/settings':
            return MaterialPageRoute(
                builder: (_) => const _SettingsScreen(), settings: settings);
          case '/menu/privacy':
            return MaterialPageRoute(
                builder: (_) => const _PrivacyScreen(), settings: settings);
          case '/menu/imprint':
            return MaterialPageRoute(
                builder: (_) => const _ImprintScreen(), settings: settings);
          case '/menu':
          default:
            return MaterialPageRoute(
                builder: (_) => const _MenuRootScreen(), settings: settings);
        }
      },
    );
  }
}

class _MenuRootScreen extends StatelessWidget {
  const _MenuRootScreen();

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);

    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // ignore if user is not signed in with Google
    }

    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInEmailScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                'Menu',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 26),
              _MenuItem(
                title: 'Einstellungen',
                onTap: () => Navigator.of(context).pushNamed('/menu/settings'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: 'Datenschutz',
                onTap: () => Navigator.of(context).pushNamed('/menu/privacy'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: 'Impressum',
                onTap: () => Navigator.of(context).pushNamed('/menu/imprint'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: 'Abmelden',
                onTap: () => _signOut(context),
              ),
              _DividerLine(color: divider),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(text), duration: const Duration(milliseconds: 900)),
    );
  }

  MaterialStateProperty<Color?> _thumbColor(
      Color on, Color off, Set<MaterialState> states) {
    if (states.contains(MaterialState.selected))
      return MaterialStateProperty.all(on);
    return MaterialStateProperty.all(off);
  }

  MaterialStateProperty<Color?> _trackColor(
      Color on, Color off, Set<MaterialState> states) {
    if (states.contains(MaterialState.selected))
      return MaterialStateProperty.all(on);
    return MaterialStateProperty.all(off);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;

    Color activeTrack() => scheme.primary;
    Color inactiveTrack() => onSurface.withOpacity(0.18);

    Color activeThumb() => scheme.onPrimary;
    Color inactiveThumb() => scheme.surface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:
                    Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Einstellungen',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: onSurface),
              ),
              const SizedBox(height: 30),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppSettings.themeMode,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark;

                  return Row(
                    children: [
                      Text(
                        'Erscheinungsbild',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: onSurface),
                      ),
                      const Spacer(),
                      Text(
                        isDark ? 'Dunkel' : 'Hell',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withOpacity(0.60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: isDark,
                        onChanged: (v) async {
                          await AppSettings.toggleTheme(v);
                          _showSnack(
                              context,
                              v
                                  ? 'Dark Mode aktiviert'
                                  : 'Light Mode aktiviert');
                        },
                        thumbColor: _thumbColor(
                            activeThumb(), inactiveThumb(), const {}),
                        trackColor: _trackColor(
                            activeTrack(), inactiveTrack(), const {}),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              ValueListenableBuilder<bool>(
                valueListenable: AppSettings.notificationsEnabled,
                builder: (context, enabled, _) {
                  return Row(
                    children: [
                      Text(
                        'Benachrichtigungen',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: onSurface),
                      ),
                      const Spacer(),
                      Text(
                        enabled ? 'On' : 'Off',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withOpacity(0.60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: enabled,
                        onChanged: (v) async {
                          await AppSettings.toggleNotifications(v);
                          _showSnack(
                              context,
                              v
                                  ? 'Benachrichtigungen an'
                                  : 'Benachrichtigungen aus');
                        },
                        thumbColor: _thumbColor(
                            activeThumb(), inactiveThumb(), const {}),
                        trackColor: _trackColor(
                            activeTrack(), inactiveTrack(), const {}),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyScreen extends StatelessWidget {
  const _PrivacyScreen();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:
                    Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Datenschutz',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: onSurface),
              ),
              const SizedBox(height: 18),
              Text(
                'Verantwortlich\nGeoquest-Team',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'Welche Daten werden erhoben?\n'
                '• Standort zur Positionsprüfung\n'
                '• Nickname, Punktestand, Fortschritt\n\n'
                'Wofür werden die Daten verwendet?\n'
                'Zur Spiellogik, Fortschrittsanzeige und\n'
                'Benachrichtigungen über neue\n'
                'Aufgaben.\n\n'
                'Wie lange werden Daten gespeichert?\n'
                'Standortdaten nur während des Spiels.\n'
                'Fortschritt bleibt bis zum Zurücksetzen\n\n'
                'Deine Rechte\n'
                '• Auskunft\n'
                '• Löschung\n'
                '• Datenübertragbarkeit\n'
                '• Widerruf der Einwilligung',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: onSurface),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImprintScreen extends StatelessWidget {
  const _ImprintScreen();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:
                    Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Impressum',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: onSurface),
              ),
              const SizedBox(height: 18),
              Text(
                'Verantwortlich\nGeoquest-Team\n\n'
                'Kontakt:\n'
                '21ihw1t7@365.htl-leoben.at\n\n'
                'Zuletzt geändert:\n'
                '11.1.2025',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: onSurface),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: onSurface)),
            const Spacer(),
            Icon(Icons.chevron_right, color: onSurface.withOpacity(0.55)),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  final Color color;
  const _DividerLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color);
  }
}
