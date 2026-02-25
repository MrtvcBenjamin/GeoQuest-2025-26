import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Backend-connected GameState using YOUR Firestore schema (from your screenshots).
///
/// Your fields (as shown):
/// - Hunts/{huntId}:
///     durationMinutes (int)
/// - Hunts/{huntId}/Stadions/{stadionId}:
///     title (string), points (int), stadionIndex (int), stadionLocation (GeoPoint)
/// - Teams/{teamId}:
///     hunt (string huntId)
/// - PlayerLocation/{uid}:
///     huntId (string), stadionIndex (int), location (GeoPoint), timestamp (Timestamp)
///
/// Optional (recommended) extra fields we add to PlayerLocation for time sync:
///     huntStarted (bool), startedAt (Timestamp)
class GameState {
  // =========================
  // Public reactive values (UI listens to these)
  // =========================
  static final ValueNotifier<bool> huntStarted = ValueNotifier<bool>(false);

  static final ValueNotifier<String> nextStationName = ValueNotifier<String>('—');
  static final ValueNotifier<int> nextStationDistanceMeters = ValueNotifier<int>(0);
  static final ValueNotifier<int> nextStationPoints = ValueNotifier<int>(0);
  static final ValueNotifier<Duration> remainingTime =
  ValueNotifier<Duration>(const Duration(minutes: 15));

  // =========================
  // Internals
  // =========================
  static String? _uid;
  static String? _huntId;

  static int _currentStadionIndex = 0;
  static int _durationMinutes = 15;

  static GeoPoint? _playerGeo; // from PlayerLocation.location
  static GeoPoint? _targetGeo; // from Stadions.stadionLocation

  static DateTime? _startedAt; // from PlayerLocation.startedAt
  static Timer? _timer;

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _playerLocSub;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _huntSub;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _stadionsSub;

  static List<Map<String, dynamic>> _stadionsCache = [];

  /// Call this if you already know the huntId (simple).
  /// Example: await GameState.initWithHuntId("xISAk6mXjjEpDUHYyxZi");
  static Future<void> initWithHuntId(String huntId) async {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) {
      _reset();
      return;
    }

    _huntId = huntId;

    _bindHunt(huntId);
    _bindStadions(huntId);
    _bindPlayerLocation(_uid!);
  }

  /// Call this if you want to resolve huntId via team document.
  /// You must pass the teamId (because your screenshot doesn't show Users.teamId).
  ///
  /// Example: await GameState.initWithTeamId(teamId);
  static Future<void> initWithTeamId(String teamId) async {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) {
      _reset();
      return;
    }

    final teamSnap =
    await FirebaseFirestore.instance.collection('Teams').doc(teamId).get();

    final huntId = teamSnap.data()?['hunt'] as String?;
    if (huntId == null || huntId.isEmpty) {
      _reset();
      return;
    }

    await initWithHuntId(huntId);
  }

  /// Start hunt (backend truth):
  /// writes a startedAt timestamp + huntStarted=true into PlayerLocation/{uid}.
  /// (You can keep using your existing PlayerLocation doc; we just add fields.)
  static Future<void> startHunt() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final huntId = _huntId;
    if (uid == null || huntId == null) return;

    await FirebaseFirestore.instance.collection('PlayerLocation').doc(uid).set(
      {
        'huntId': huntId,
        'stadionIndex': 0,
        'huntStarted': true,
        'startedAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Clean up listeners (call on logout / app dispose).
  static Future<void> dispose() async {
    await _playerLocSub?.cancel();
    await _huntSub?.cancel();
    await _stadionsSub?.cancel();
    _timer?.cancel();

    _playerLocSub = null;
    _huntSub = null;
    _stadionsSub = null;
    _timer = null;

    _uid = null;
    _huntId = null;

    _reset();
  }

  // =========================
  // Bindings
  // =========================
  static void _bindPlayerLocation(String uid) {
    _playerLocSub?.cancel();
    _playerLocSub = FirebaseFirestore.instance
        .collection('PlayerLocation')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      final data = snap.data();
      if (data == null) return;

      // Player position
      final loc = data['location'];
      if (loc is GeoPoint) _playerGeo = loc;

      // Current stadion index (progress)
      _currentStadionIndex = (data['stadionIndex'] as num?)?.toInt() ?? 0;

      // Hunt started + startedAt
      huntStarted.value = (data['huntStarted'] as bool?) ?? false;
      final startedAtTs = data['startedAt'] as Timestamp?;
      _startedAt = startedAtTs?.toDate();

      // If PlayerLocation says a different huntId than our current, you can optionally sync:
      final docHuntId = data['huntId'] as String?;
      if (docHuntId != null && docHuntId.isNotEmpty && docHuntId != _huntId) {
        _huntId = docHuntId;
        _bindHunt(docHuntId);
        _bindStadions(docHuntId);
      }

      _applyCurrentStadionFromCache();
      _recomputeDistance();
      _restartTimer();
    });
  }

  static void _bindHunt(String huntId) {
    _huntSub?.cancel();
    _huntSub = FirebaseFirestore.instance
        .collection('Hunts')
        .doc(huntId)
        .snapshots()
        .listen((snap) {
      final data = snap.data();
      final minutes = (data?['durationMinutes'] as num?)?.toInt();
      _durationMinutes = (minutes != null && minutes > 0) ? minutes : 15;

      _restartTimer();
    });
  }

  static void _bindStadions(String huntId) {
    _stadionsSub?.cancel();
    _stadionsSub = FirebaseFirestore.instance
        .collection('Hunts')
        .doc(huntId)
        .collection('Stadions')
        .orderBy('stadionIndex')
        .snapshots()
        .listen((snap) async {
      _stadionsCache = await _orderStadionsForUser(huntId, snap);
      _applyCurrentStadionFromCache();
      _recomputeDistance();
    });
  }

  static Future<List<Map<String, dynamic>>> _orderStadionsForUser(
    String huntId,
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    final byId = <String, Map<String, dynamic>>{
      for (final d in snap.docs) d.id: d.data(),
    };

    final uid = _uid;
    if (uid == null) return byId.values.toList();

    try {
      final userSnap =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      final stored = ((userSnap.data()?['StationOrderByHunt'] as Map?)?[huntId]
              as List?)
          ?.map((e) => e.toString())
          .toList();

      if (stored == null ||
          stored.length != byId.length ||
          stored.any((id) => !byId.containsKey(id))) {
        return byId.values.toList();
      }

      final ordered = <Map<String, dynamic>>[];
      for (final id in stored) {
        final s = byId[id];
        if (s != null) ordered.add(s);
      }
      return ordered;
    } catch (_) {
      return byId.values.toList();
    }
  }

  // =========================
  // Derivations: current station, distance, time
  // =========================
  static void _applyCurrentStadionFromCache() {
    if (_stadionsCache.isEmpty) return;

    final idx = _currentStadionIndex.clamp(0, _stadionsCache.length - 1);
    final s = _stadionsCache[idx];

    nextStationName.value =
        (s['title'] as String?) ?? 'Station ${idx + 1}';
    nextStationPoints.value = (s['points'] as num?)?.toInt() ?? 0;

    final gp = s['stadionLocation'];
    _targetGeo = gp is GeoPoint ? gp : null;
  }

  static void _recomputeDistance() {
    if (_playerGeo == null || _targetGeo == null) return;

    final meters = Geolocator.distanceBetween(
      _playerGeo!.latitude,
      _playerGeo!.longitude,
      _targetGeo!.latitude,
      _targetGeo!.longitude,
    );

    nextStationDistanceMeters.value = meters.round();
  }

  static void _restartTimer() {
    _timer?.cancel();

    final total = Duration(minutes: _durationMinutes);

    // If not started -> show full duration (or keep as you want)
    if (!huntStarted.value || _startedAt == null) {
      remainingTime.value = total;
      return;
    }

    void tick() {
      final elapsed = DateTime.now().difference(_startedAt!);
      final left = total - elapsed;
      remainingTime.value = left.isNegative ? Duration.zero : left;
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  static void _reset() {
    huntStarted.value = false;
    nextStationName.value = '—';
    nextStationDistanceMeters.value = 0;
    nextStationPoints.value = 0;
    remainingTime.value = const Duration(minutes: 15);

    _currentStadionIndex = 0;
    _durationMinutes = 15;
    _playerGeo = null;
    _targetGeo = null;
    _startedAt = null;
    _stadionsCache = [];
  }
}
