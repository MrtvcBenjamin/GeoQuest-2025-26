import 'package:flutter/material.dart';
import 'start_route_screen.dart';

class StartHuntScreen extends StatelessWidget {
  const StartHuntScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final maxCardWidth = c.maxWidth > 430 ? 340.0 : 320.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 22),

                  Column(
                    children: [
                      Image.asset('assets/logo.png', height: 78),
                      const SizedBox(height: 10),
                      Text(
                        'GeoQuest',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hello, “Name”',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Nachdem du “Start Hunt”\nclickst startet das Spiel\nund somit auch die Zeit!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.8,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StartRouteScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Start Hunt',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
