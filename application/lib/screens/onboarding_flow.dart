import 'package:flutter/material.dart';

import '../theme/app_settings.dart';
import 'sign_in_email_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Willkommen\nbei deiner Schnitzeljagd!',
      body:
          'Erkunde spannende Orte,\nlöse Rätsel und sammle\nPunkte. Jede Station bringt\ndich ein Stück näher ans\nZiel!',
      button: 'Continue',
    ),
    _OnboardingPage(
      title: 'Deine Route ist einzigartig',
      body:
          'Du bekommst eine zufällige\nReihenfolge der Stationen.\nSo vermeiden wir\nMassenansammlungen\nund halten das Spiel fair.',
      button: 'Continue',
    ),
    _OnboardingPage(
      title: 'Löse Aufgaben vor Ort',
      body:
          'Textfragen, Multiple Choice\noder kleine Bilderrätsel\nwarten auf dich.\nRichtig gelöst = Punkte!\nÜberspringen kostet Punkte.',
      button: 'Continue',
    ),
    _OnboardingPage(
      title: 'Bleib ehrlich und sicher',
      body:
          'Aufgaben funktionieren nur\nin der Nähe der Station.\nBei zu hoher\nGeschwindigkeit wird das\nSpiel kurz gesperrt.',
      button: 'Get started!',
      last: true,
    ),
  ];

  Future<void> _next() async {
    if (_pages[_index].last) {
      await AppSettings.setOnboardingDone(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInEmailScreen()),
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
    final page = _pages[_index];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Spielregeln',
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.35),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
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
                              color: scheme.onSurface.withOpacity(0.85),
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
