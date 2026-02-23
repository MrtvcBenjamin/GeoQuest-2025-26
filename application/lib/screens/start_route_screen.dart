import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_nav.dart';
import '../models/game_state.dart'; // <-- import your GameState file

class StartRouteScreen extends StatefulWidget {
  final String huntId; // pass in, or hardcode if you want

  const StartRouteScreen({
    super.key,
    required this.huntId,
  });

  @override
  State<StartRouteScreen> createState() => _StartRouteScreenState();
}

class _StartRouteScreenState extends State<StartRouteScreen> {
  late final Future<String> _usernameFuture;

  Future<String> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Player";

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

// Your DB shows field is "Username" (capital U)
    return snapshot.data()?['Username'] ?? "Player";
  }

  @override
  void initState() {
    super.initState();

    _usernameFuture = _loadUsername();

// ✅ start listening to backend for this hunt
    GameState.initWithHuntId(widget.huntId);
  }

  String _fmtTime(Duration d) {
    final totalSeconds = d.inSeconds.clamp(0, 999999);
    final m = (totalSeconds ~/ 60).toString();
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _usernameFuture,
          builder: (context, snapshot) {
            final username = snapshot.data ?? "Player";

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
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
                  const SizedBox(height: 26),
                  Text(
                    'Hello, $username',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: scheme.onSurface.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Station:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),

// ✅ next station name from GameState
                        ValueListenableBuilder<String>(
                          valueListenable: GameState.nextStationName,
                          builder: (_, name, __) {
                            return Text(
                              name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                color: scheme.onSurface,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
// ✅ distance from GameState
                            ValueListenableBuilder<int>(
                              valueListenable:
                                  GameState.nextStationDistanceMeters,
                              builder: (_, meters, __) {
                                return Text(
                                  'Distance: ${meters}m',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: scheme.onSurface.withOpacity(0.85),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),

// ✅ points from GameState
                            ValueListenableBuilder<int>(
                              valueListenable: GameState.nextStationPoints,
                              builder: (_, pts, __) {
                                return Text(
                                  'Points: $pts p',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: scheme.onSurface.withOpacity(0.85),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.circle,
                                  size: 10, color: Color(0xFFFFC107)),
                              const SizedBox(width: 8),

// ✅ remaining time from GameState
                              ValueListenableBuilder<Duration>(
                                valueListenable: GameState.remainingTime,
                                builder: (_, t, __) {
                                  return Text(
                                    'remaining Time: ${_fmtTime(t)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onSurface.withOpacity(0.85),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () async {
// ✅ start hunt in backend (sets startedAt/huntStarted)
                              await GameState.startHunt();

// switch to map tab
                              AppNav.selectedIndex.value = 1;
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
                              'Start',
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
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
