import 'package:flutter/material.dart';

import '../theme/app_settings.dart';
import '../theme/app_text.dart';
import 'role_select_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_OnboardingPage> _pages() => [
        _OnboardingPage(
          title: tr(
            'Willkommen\nbei deiner Schnitzeljagd!',
            'Welcome\nto your scavenger hunt!',
          ),
          body: tr(
            'Erkunde spannende Orte,\nlöse Rätsel und sammle\nPunkte. Jede Station bringt\ndich ein Stück näher ans\nZiel!',
            'Explore exciting places,\nsolve puzzles and collect\npoints. Every station gets\nyou one step closer to your\ngoal!',
          ),
          button: tr('Weiter', 'Continue'),
        ),
        _OnboardingPage(
          title: tr('Deine Route ist einzigartig', 'Your route is unique'),
          body: tr(
            'Du bekommst eine zufällige\nReihenfolge der Stationen.\nSo vermeiden wir\nMassenansammlungen\nund halten das Spiel fair.',
            'You get a randomized\nstation order. This avoids\ncrowds and keeps the game\nfair for everyone.',
          ),
          button: tr('Weiter', 'Continue'),
        ),
        _OnboardingPage(
          title: tr('Löse Aufgaben vor Ort', 'Solve tasks on site'),
          body: tr(
            'Textfragen, Multiple Choice\noder kleine Bilderrätsel\nwarten auf dich.\nRichtig gelöst = Punkte!\nÜberspringen kostet Punkte.',
            'Text questions, multiple choice\nor image puzzles await you.\nSolve them correctly to earn\npoints. Skipping costs points.',
          ),
          button: tr('Weiter', 'Continue'),
        ),
        _OnboardingPage(
          title: tr('Bleib ehrlich und sicher', 'Stay fair and safe'),
          body: tr(
            'Aufgaben funktionieren nur\nin der Nähe der Station.\nBei zu hoher\nGeschwindigkeit wird das\nSpiel kurz gesperrt.',
            'Tasks only work near the\nstation. If your speed is too\nhigh, the game is\ntemporarily blocked.',
          ),
          button: tr('Los gehts!', 'Get started!'),
          last: true,
        ),
      ];

  Future<void> _next() async {
    final pages = _pages();
    if (pages[_index].last) {
      await AppSettings.setOnboardingDone(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pages = _pages();
    final page = pages[_index];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              tr('Spielregeln', 'Game rules'),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.35),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = pages[i];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            p.body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    page.button,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String body;
  final String button;
  final bool last;

  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.button,
    this.last = false,
  });
}

