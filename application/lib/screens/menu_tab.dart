import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_settings.dart';
import '../theme/app_text.dart';
import 'role_select_screen.dart';

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
    final title = tr('Abmelden?', 'Sign out?');
    final body = tr('Möchtest du dich wirklich abmelden?',
        'Do you really want to sign out?');
    final cancelLabel = tr('Abbrechen', 'Cancel');
    final confirmLabel = tr('Abmelden', 'Sign out');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 0,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final menuTitle = tr('Menü', 'Menu');
    final settingsLabel = tr('Einstellungen', 'Settings');
    final privacyLabel = tr('Datenschutz', 'Privacy');
    final imprintLabel = tr('Impressum', 'Imprint');
    final signOutLabel = tr('Abmelden', 'Sign out');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                menuTitle,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 26),
              _MenuItem(
                title: settingsLabel,
                onTap: () => Navigator.of(context).pushNamed('/menu/settings'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: privacyLabel,
                onTap: () => Navigator.of(context).pushNamed('/menu/privacy'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: imprintLabel,
                onTap: () => Navigator.of(context).pushNamed('/menu/imprint'),
              ),
              _DividerLine(color: divider),
              _MenuItem(
                title: signOutLabel,
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

  WidgetStateProperty<Color?> _thumbColor(
      Color on, Color off, Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return WidgetStateProperty.all(on);
    }
    return WidgetStateProperty.all(off);
  }

  WidgetStateProperty<Color?> _trackColor(
      Color on, Color off, Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return WidgetStateProperty.all(on);
    }
    return WidgetStateProperty.all(off);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final darkModeLabel = tr('Dunkel', 'Dark');
    final lightModeLabel = tr('Hell', 'Light');

    Color activeTrack() => scheme.primary;
    Color inactiveTrack() => onSurface.withValues(alpha: 0.18);

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
                tr('Einstellungen', 'Settings'),
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
                        tr('Erscheinungsbild', 'Appearance'),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: onSurface),
                      ),
                      const Spacer(),
                      Text(
                        isDark ? darkModeLabel : lightModeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: isDark,
                        onChanged: (v) async {
                          await AppSettings.toggleTheme(v);
                          if (!context.mounted) return;
                          _showSnack(
                              context,
                              v
                                  ? tr('Dark Mode aktiviert',
                                      'Dark mode enabled')
                                  : tr('Light Mode aktiviert',
                                      'Light mode enabled'));
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
              const SizedBox(height: 18),
              ValueListenableBuilder<AppLanguage>(
                valueListenable: AppSettings.language,
                builder: (context, language, _) => Row(
                  children: [
                    Text(
                      tr('Sprache', 'Language'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<AppLanguage>(
                      segments: const [
                        ButtonSegment(value: AppLanguage.de, label: Text('DE')),
                        ButtonSegment(value: AppLanguage.en, label: Text('EN')),
                      ],
                      selected: {language},
                      onSelectionChanged: (selection) async {
                        final value = selection.first;
                        await AppSettings.setLanguage(value);
                        if (!context.mounted) return;
                        _showSnack(
                          context,
                          value == AppLanguage.de
                              ? 'Sprache auf Deutsch gesetzt'
                              : 'Language set to English',
                        );
                      },
                    ),
                  ],
                ),
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
              title: tr('Datenschutz', 'Privacy'),
              subtitle: tr(
                'Transparenz zu Daten und Rechten',
                'Transparency about data and rights',
              ),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                children: [
                  _LegalCard(
                    icon: Icons.business_outlined,
                    title: tr('Verantwortliche Stelle', 'Responsible party'),
                    child: Text(
                      '${tr('Tobias Zeismann, Benjamin Muratovic und Christian Kovacs', 'Tobias Zeismann, Benjamin Muratovic and Christian Kovacs')}\n'
                      '${tr('Max-Tendlerstraße 3', 'Max-Tendler Street 3')}',
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
                    title: tr('Verarbeitete Daten', 'Processed data'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalBullet(tr(
                          'Standortdaten zur Positionsprüfung',
                          'Location data for position checks',
                        )),
                        _LegalBullet(tr(
                          'Nickname, Punktestand und Fortschritt',
                          'Nickname, score and progress',
                        )),
                        _LegalBullet(tr(
                          'Technische Nutzungsdaten für Stabilität',
                          'Technical usage data for stability',
                        )),
                      ],
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.rule_outlined,
                    title:
                        tr('Zweck der Verarbeitung', 'Purpose of processing'),
                    child: Text(
                      tr(
                        'Die Daten werden ausschließlich für die Spiellogik, '
                            'Fortschrittsanzeige und die faire Durchführung der Hunt '
                            'verwendet.',
                        'Data is only used for game logic, progress display and '
                            'fair execution of the hunt.',
                      ),
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
                    title: tr('Speicherdauer', 'Retention period'),
                    child: Text(
                      tr(
                        'Standortdaten werden nur während des aktiven Spiels verarbeitet. '
                            'Spielbezogene Profildaten bleiben bis zur Zurücksetzung '
                            'oder Löschung gespeichert.',
                        'Location data is only processed during an active game. '
                            'Game-related profile data remains stored until reset '
                            'or deletion.',
                      ),
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
                    title: tr('Deine Rechte', 'Your rights'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalBullet(tr(
                          'Auskunft über gespeicherte Daten',
                          'Access to stored data',
                        )),
                        _LegalBullet(tr(
                          'Berichtigung und Löschung',
                          'Rectification and deletion',
                        )),
                        _LegalBullet(tr(
                          'Einschränkung der Verarbeitung',
                          'Restriction of processing',
                        )),
                        _LegalBullet(tr(
                          'Widerruf erteilter Einwilligungen',
                          'Withdrawal of given consents',
                        )),
                      ],
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.mail_outline,
                    title: tr('Kontakt Datenschutz', 'Privacy contact'),
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
              title: tr('Impressum', 'Imprint'),
              subtitle: tr('Anbieterkennzeichnung', 'Provider information'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                children: [
                  _LegalCard(
                    icon: Icons.apartment_outlined,
                    title: tr('Anbieter', 'Provider'),
                    child: Text(
                      '${tr('Tobias Zeismann, Benjamin Muratovic und Christian Kovacs', 'Tobias Zeismann, Benjamin Muratovic and Christian Kovacs')}\n'
                      '${tr('Max-Tendlerstraße 3', 'Max-Tendler Street 3')}',
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
                    title: tr(
                        'Inhaltlich verantwortlich', 'Responsible for content'),
                    child: Text(
                      tr('Tobias Zeismann, Benjamin Muratovic und Christian Kovacs',
                          'Tobias Zeismann, Benjamin Muratovic and Christian Kovacs'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  _LegalCard(
                    icon: Icons.email_outlined,
                    title: tr('Kontakt', 'Contact'),
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
                    title: tr('Hinweis', 'Note'),
                    child: Text(
                      tr(
                        'Diese App wurde im Rahmen eines Schulprojekts entwickelt. '
                            'Alle Inhalte wurden mit Sorgfalt erstellt.',
                        'This app was developed as part of a school project. '
                            'All content was created with care.',
                      ),
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
                    title: tr('Stand', 'Updated'),
                    child: Text(
                      tr('25.02.2026', '2026-02-25'),
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
              Icon(icon,
                  size: 18, color: scheme.onSurface.withValues(alpha: 0.80)),
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
            Icon(Icons.chevron_right, color: onSurface.withValues(alpha: 0.55)),
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
