import 'package:flutter/material.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Willkommen\nbei deiner Schnitzeljagd!',
      text:
      'Erkunde spannende Orte,\n'
          'löse Rätsel und sammle Punkte.\n'
          'Jede Station bringt dich\n'
          'ein Stück näher ans Ziel.',
    ),
    _OnboardingPageData(
      title: 'Deine Route ist einzigartig',
      text:
      'Du bekommst eine zufällige\n'
          'Reihenfolge der Stationen.\n'
          'So vermeiden wir\n'
          'Massensammlungen und\n'
          'halten das Spiel fair.',
    ),
    _OnboardingPageData(
      title: 'Löse Aufgaben vor Ort',
      text:
      'Texfragen, Multiple Choice\n'
          'oder kleine Bilderrätsel warten auf dich.\n'
          'Richtig gelöst = Punkte.\n'
          'Überspringen kostet Punkte.',
    ),
    _OnboardingPageData(
      title: 'Bleib ehrlich und sicher',
      text:
      'Aufgaben funktionieren nur\n'
          'in der Nähe der Station.\n'
          'Bei zu hoher Geschwindigkeit\n'
          'wird das Spiel kurz gesperrt.',
    ),
  ];

  void _next() {
    if (_pageIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Nach dem letzten Onboarding-Screen -> Berechtigungen
      Navigator.of(context).pushReplacementNamed('/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Spielregeln',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // kleine Punkte unten
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _pageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 10 : 8,
                  height: selected ? 10 : 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _pageIndex == _pages.length - 1
                        ? 'Get started!'
                        : 'Continue',
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

class _OnboardingPageData {
  final String title;
  final String text;

  const _OnboardingPageData({
    required this.title,
    required this.text,
  });
}
