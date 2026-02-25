import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text(
            'Abmelden?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Möchtest du dich wirklich abmelden?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 0,
              ),
              child: const Text('Abmelden'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    final navigator = Navigator.of(context, rootNavigator: true);

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _LegalHeader(
              title: 'Datenschutz',
              subtitle: 'Transparenz zu Daten und Rechten',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                children: [
                  _LegalCard(
                    icon: Icons.business_outlined,
                    title: 'Verantwortliche Stelle',
                    child: Text(
                      'Tobias Zeismann, Benjamin Muratovic und Christian Kovacs\n'
                      'Max-Tendlerstraße 3',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.storage_outlined,
                    title: 'Verarbeitete Daten',
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalBullet('Standortdaten zur Positionsprüfung'),
                        _LegalBullet('Nickname, Punktestand und Fortschritt'),
                        _LegalBullet('Technische Nutzungsdaten für Stabilität'),
                      ],
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.rule_outlined,
                    title: 'Zweck der Verarbeitung',
                    child: Text(
                      'Die Daten werden ausschließlich für die Spiellogik, '
                      'Fortschrittsanzeige und die faire Durchführung der Hunt '
                      'verwendet.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.schedule_outlined,
                    title: 'Speicherdauer',
                    child: Text(
                      'Standortdaten werden nur während des aktiven Spiels verarbeitet. '
                      'Spielbezogene Profildaten bleiben bis zur Zurücksetzung '
                      'oder Löschung gespeichert.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.gavel_outlined,
                    title: 'Deine Rechte',
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalBullet('Auskunft über gespeicherte Daten'),
                        _LegalBullet('Berichtigung und Löschung'),
                        _LegalBullet('Einschränkung der Verarbeitung'),
                        _LegalBullet('Widerruf erteilter Einwilligungen'),
                      ],
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.mail_outline,
                    title: 'Kontakt Datenschutz',
                    child: Text(
                      '211wita26@o365.htl-leoben',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImprintScreen extends StatelessWidget {
  const _ImprintScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _LegalHeader(
              title: 'Impressum',
              subtitle: 'Anbieterkennzeichnung',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                children: [
                  _LegalCard(
                    icon: Icons.apartment_outlined,
                    title: 'Anbieter',
                    child: Text(
                      'Tobias Zeismann, Benjamin Muratovic und Christian Kovacs\n'
                      'Max-Tendlerstraße 3',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.person_outline,
                    title: 'Inhaltlich verantwortlich',
                    child: Text(
                      'Tobias Zeismann, Benjamin Muratovic und Christian Kovacs',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.email_outlined,
                    title: 'Kontakt',
                    child: Text(
                      '211wita26@o365.htl-leoben',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.info_outline,
                    title: 'Hinweis',
                    child: Text(
                      'Diese App wurde im Rahmen eines Schulprojekts entwickelt. '
                      'Alle Inhalte wurden mit Sorgfalt erstellt.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.update_outlined,
                    title: 'Stand',
                    child: Text(
                      '25.02.2026',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _LegalHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.0,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _LegalCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surface.withValues(alpha: 0.85)
            : scheme.surface.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.onSurface.withValues(alpha: 0.80)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  final String text;
  const _LegalBullet(this.text);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: onSurface,
              ),
            ),
          ),
        ],
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

