import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_text.dart';

class StartHuntScreen extends StatelessWidget {
  const StartHuntScreen({super.key});

  Future<String> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return tr('Spieler', 'Player');

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    return (snapshot.data()?['Username'] as String?) ?? tr('Spieler', 'Player');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loadUsername(),
          builder: (context, snapshot) {
            final username = snapshot.data ?? tr('Spieler', 'Player');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 92,
                            height: 92,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'GeoQuest',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${tr('Hallo', 'Hello')}, $username',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.22)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('Bereit für die Hunt?', 'Ready for the hunt?'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr(
                              'Sobald du auf Start drückst, startet die Zeit. Gehe zu jeder '
                                  'Station, lasse die Lehrperson bewerten und sammle Zusatzpunkte '
                                  'für pünktliche Ankunft.',
                              'As soon as you press start, the timer begins. Go to each '
                                  'station, let the teacher evaluate and collect bonus points '
                                  'for arriving on time.',
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: scheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoBullet(
                            text: tr('Lehrerpasswort zur Freigabe: 123',
                                'Teacher password for approval: 123'),
                            color: scheme.onSurface,
                          ),
                          const SizedBox(height: 8),
                          _InfoBullet(
                            text: tr(
                              'Zeitbonus: +2 Punkte vor Ablauf des Timers',
                              'Time bonus: +2 points before the timer ends',
                            ),
                            color: scheme.onSurface,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed('/start-route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                tr('Hunt starten', 'Start hunt'),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoBullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.90),
            ),
          ),
        ),
      ],
    );
  }
}
