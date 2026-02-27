import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_nav.dart';
import '../models/game_state.dart';
import '../theme/app_text.dart';

class StartRouteScreen extends StatefulWidget {
  final String huntId;

  const StartRouteScreen({
    super.key,
    required this.huntId,
  });

  @override
  State<StartRouteScreen> createState() => _StartRouteScreenState();
}

class _StartRouteScreenState extends State<StartRouteScreen> {
  late final Future<String> _usernameFuture;
  late final Future<int> _totalStationsFuture;
  String? _uid;

  Future<String> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return tr('Spieler', 'Player');

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    return (snapshot.data()?['Username'] as String?) ?? tr('Spieler', 'Player');
  }

  Future<int> _loadTotalStations() async {
    final snap = await FirebaseFirestore.instance
        .collection('Hunts')
        .doc(widget.huntId)
        .collection('Stadions')
        .get();
    return snap.docs.length;
  }

  int _readSolvedCount(Map<String, dynamic> data) {
    final solvedField = (data['SolvedCount'] as num?)?.toInt();
    if (solvedField != null && solvedField >= 0) return solvedField;

    final completedRaw = (data['CompletedStadions'] as List?) ?? const [];
    return completedRaw
        .map((e) {
          if (e is num) return e.toInt();
          return int.tryParse(e.toString());
        })
        .whereType<int>()
        .toSet()
        .length;
  }

  bool _isFinished(Map<String, dynamic> data, int totalStations) {
    final finishedByHunt =
        ((data['FinishedHunts'] as Map?)?[widget.huntId] as bool?) ?? false;
    if (finishedByHunt) return true;
    return totalStations > 0 && _readSolvedCount(data) >= totalStations;
  }

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _usernameFuture = _loadUsername();
    _totalStationsFuture = _loadTotalStations();
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
          builder: (context, userSnap) {
            final username = userSnap.data ?? tr('Spieler', 'Player');
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return FutureBuilder<int>(
              future: _totalStationsFuture,
              builder: (context, totalSnap) {
                final totalStations = totalSnap.data ?? 0;

                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _uid == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('Users')
                          .doc(_uid)
                          .snapshots(),
                  builder: (context, progressSnap) {
                    final data =
                        progressSnap.data?.data() ?? const <String, dynamic>{};
                    final solvedCount = _readSolvedCount(data);
                    final finished = _isFinished(data, totalStations);

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
                            '${tr('Hallo', 'Hello')}, $username',
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
                                color: scheme.onSurface.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: finished
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr('Alle Rätsel gelöst',
                                            'All puzzles solved'),
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        tr(
                                          'Du bist fertig: $solvedCount / $totalStations Stationen abgeschlossen.',
                                          'You are done: $solvedCount / $totalStations stations completed.',
                                        ),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: scheme.primary,
                                            foregroundColor: scheme.onPrimary,
                                          ),
                                          child: Text(
                                            tr('Fertig', 'Done'),
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr('Nächste Station:', 'Next station:'),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: AppNav.stationActive,
                                        builder: (_, stationActive, __) =>
                                            ValueListenableBuilder<String>(
                                          valueListenable:
                                              GameState.nextStationName,
                                          builder: (_, name, ___) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (stationActive)
                                                Text(
                                                  tr(
                                                    'Gehe zu $name.',
                                                    'Go to $name.',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: scheme.onSurface
                                                        .withValues(
                                                            alpha: 0.85),
                                                  ),
                                                ),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1.0,
                                                  color: scheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ValueListenableBuilder<int>(
                                            valueListenable: GameState
                                                .nextStationDistanceMeters,
                                            builder: (_, meters, __) => Text(
                                              '${tr('Distanz', 'Distance')}: ${meters}m',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ValueListenableBuilder<int>(
                                            valueListenable:
                                                GameState.nextStationPoints,
                                            builder: (_, pts, __) => Text(
                                              '${tr('Punkte', 'Points')}: $pts p',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: GameState.huntStarted,
                                        builder: (_, started, __) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (started) ...[
                                              Text(
                                                tr(
                                                  'Bewege dich jetzt zur markierten Station und öffne die Karte für die Navigation.',
                                                  'Move to the highlighted station now and open the map for navigation.',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.85),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                            Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.circle,
                                                      size: 10,
                                                      color: Color(0xFFFFC107)),
                                                  const SizedBox(width: 8),
                                                  ValueListenableBuilder<
                                                      Duration>(
                                                    valueListenable:
                                                        GameState.remainingTime,
                                                    builder: (_, t, ___) => Text(
                                                      '${tr('Verbleibende Zeit', 'Remaining time')}: ${_fmtTime(t)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: scheme.onSurface
                                                            .withValues(
                                                                alpha: 0.85),
                                                      ),
                                                    ),
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
                                                  if (!started) {
                                                    await GameState.startHunt();
                                                  }
                                                  AppNav.stationActive.value =
                                                      true;
                                                  AppNav.selectedIndex.value =
                                                      1;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      scheme.primary,
                                                  foregroundColor:
                                                      scheme.onPrimary,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  started
                                                      ? tr('Zur Map', 'To map')
                                                      : tr(
                                                          'Aufgabe starten',
                                                          'Start task',
                                                        ),
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}

