import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_nav.dart';
import 'quiz_intro_screen.dart';

enum MapUiState { normal, warningDialog, blockedDialog, unblockDialog, inRadius }

class MapTab extends StatefulWidget {
final bool isActive;

/// Firestore: Hunts/{huntId}/Stadions (ordered by stadionIndex)
final String huntId;

const MapTab({
super.key,
required this.isActive,
required this.huntId,
});

@override
State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
final MapController _mapController = MapController();
bool get _isStationActive => AppNav.stationActive.value;

// =========================
// DB Stadions (your structure)
// =========================
List<Map<String, dynamic>> allStadionData = [];
bool _stadionsLoading = true;

int _stadionIndex = 0; // points to current stadion in allStadionData

// Helpers to read current stadion from allStadionData
bool get _hasStadions => allStadionData.isNotEmpty && _stadionIndex >= 0 && _stadionIndex < allStadionData.length;

String get _currentStadionName {
if (!_hasStadions) return 'Station';
return (allStadionData[_stadionIndex]['title'] as String?) ??
(allStadionData[_stadionIndex]['name'] as String?) ??
'Station ${_stadionIndex + 1}';
}

LatLng get _currentStadionPos {
if (!_hasStadions) return const LatLng(47.3763, 15.0930);
final gp = allStadionData[_stadionIndex]['stadionLocation'] as GeoPoint;
return LatLng(gp.latitude, gp.longitude);
}

// Radius (Meter)
static const double _stationRadiusMeters = 15;

// =========================
// Speed logic
// =========================
static const double _speedWarnThresholdMps = 6.0; // ~21.6 km/h
static const Duration _warnCooldown = Duration(seconds: 12);
DateTime? _lastWarnAt;

// Block
static const int _blockSeconds = 5 * 60;
Timer? _blockTimer;
int _blockLeft = 0;

bool get _isBlocked => _blockLeft > 0;

// =========================
// Location
// =========================
StreamSubscription<Position>? _posSub;
bool _streamRunning = false;

LatLng? _player;
double _playerSpeedMps = 0;

bool _didInitialFit = false;

// DB throttling (location writes)
DateTime? _lastDbWriteAt;
static const Duration _dbWriteCooldown = Duration(seconds: 10);

// Route (OSRM)
bool _routeLoading = false;
List<LatLng> _routePoints = [];

// UI State
MapUiState _uiState = MapUiState.normal;
int _warnings = 0;

// Demo/mock values
String _remainingTime = '15:00';
int? _remainingSeconds;
Timer? _remainingTicker;
DateTime? _stationStartedAt;

// =========================
// Lifecycle
// =========================
@override
void initState() {
super.initState();
AppNav.stationActive.addListener(_onStationActiveChanged);
_init();
}

Future<void> _init() async {
await _loadAllStadionData(widget.huntId);
await _loadSavedProgress();

if (mounted && widget.isActive) {
await _startLocationStream();
}

if (mounted) {
setState(() => _stadionsLoading = false);
}
_stationStartedAt ??= DateTime.now();
}

Future<void> _loadSavedProgress() async {
final user = FirebaseAuth.instance.currentUser;
if (user == null || allStadionData.isEmpty) return;

int? saved;

try {
final userSnap =
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).get();
saved = ((userSnap.data()?['CurrentStadionIndexByHunt'] as Map?)?[widget.huntId]
        as num?)
    ?.toInt();
} catch (_) {}

try {
final locSnap =
    await FirebaseFirestore.instance.collection("PlayerLocation").doc(user.uid).get();
saved ??= (locSnap.data()?['stadionIndex'] as num?)?.toInt();
} catch (_) {}

if (saved == null) return;
final clamped = saved.clamp(0, allStadionData.length);
if (mounted) {
setState(() => _stadionIndex = clamped);
}
}

@override
void didUpdateWidget(covariant MapTab oldWidget) {
super.didUpdateWidget(oldWidget);

// If huntId changes, reload stadions
if (oldWidget.huntId != widget.huntId) {
_stadionsLoading = true;
allStadionData = [];
_stadionIndex = 0;
_didInitialFit = false;
_routePoints = [];
_stationStartedAt = DateTime.now();
_init();
return;
}

// Start/stop stream based on active tab
if (widget.isActive && !_streamRunning) _startLocationStream();
if (!widget.isActive && _streamRunning) _stopLocationStream();
}

@override
void dispose() {
AppNav.stationActive.removeListener(_onStationActiveChanged);
_blockTimer?.cancel();
_remainingTicker?.cancel();
_stopLocationStream();
super.dispose();
}

void _onStationActiveChanged() {
if (!mounted) return;

setState(() {
_uiState = MapUiState.normal;
_didInitialFit = false;
_routePoints = [];
if (_isStationActive) {
_remainingSeconds = null;
_remainingTime = '15:00';
_stationStartedAt = DateTime.now();
}
});

if (_player != null) {
if (_isStationActive) {
_fitToPlayerAndStation();
} else {
_fitToPlayerOnly();
}
}
}

// =========================
// Firestore: load stadions
// =========================
Future<void> _loadAllStadionData(String huntId) async {
try {
final snapshot = await FirebaseFirestore.instance
    .collection("Hunts")
    .doc(huntId)
    .collection("Stadions")
    .orderBy("stadionIndex")
    .get();

final list = await _loadRandomizedStations(snapshot.docs);

if (mounted) {
setState(() {
allStadionData = list;
// clamp index if needed
if (_stadionIndex >= allStadionData.length) {
_stadionIndex = allStadionData.isEmpty ? 0 : allStadionData.length - 1;
}
});
}
_stationStartedAt ??= DateTime.now();
} catch (e) {
debugPrint('Firestore Load Error (Stadions): $e');
if (mounted) {
setState(() => allStadionData = []);
}
}
}

// =========================
// Firestore: save player location
// =========================
Future<void> _saveLocationInDatabase(LatLng position) async {
final user = FirebaseAuth.instance.currentUser;
if (user == null) return;

final now = DateTime.now();
if (_lastDbWriteAt != null && now.difference(_lastDbWriteAt!) < _dbWriteCooldown) return;
_lastDbWriteAt = now;

try {
await FirebaseFirestore.instance.collection("PlayerLocation").doc(user.uid).set(
{
'location': GeoPoint(position.latitude, position.longitude),
'timestamp': FieldValue.serverTimestamp(),
'huntId': widget.huntId,
'stadionIndex': _stadionIndex,
},
SetOptions(merge: true),
);
} catch (e) {
debugPrint('Firestore Save Error (PlayerLocation): $e');
}
}

// Optional: save progress (remove if you don’t want it)
Future<void> _saveProgress(int stadionIndex, {bool finished = false}) async {
final user = FirebaseAuth.instance.currentUser;
if (user == null) return;

try {
await FirebaseFirestore.instance.collection("PlayerLocation").doc(user.uid).set(
{
'huntId': widget.huntId,
'stadionIndex': stadionIndex,
'timestamp': FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);
} catch (e) {
debugPrint('Firestore Save Error (Progress): $e');
}

try {
await FirebaseFirestore.instance.collection("Users").doc(user.uid).set(
{
'CurrentStadionIndexByHunt.${widget.huntId}': stadionIndex,
if (finished) 'FinishedHunts.${widget.huntId}': true,
'updatedAt': FieldValue.serverTimestamp(),
},
SetOptions(merge: true),
);
} catch (e) {
debugPrint('Firestore Save Error (User progress): $e');
}
}

Future<List<Map<String, dynamic>>> _loadRandomizedStations(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
  final user = FirebaseAuth.instance.currentUser;
  final byId = <String, Map<String, dynamic>>{
    for (final d in docs) d.id: {...d.data(), '_docId': d.id},
  };
  final allIds = byId.keys.toSet();
  if (user == null || allIds.isEmpty) return byId.values.toList();

  final userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  List<String>? orderedIds;

  try {
    final snap = await userRef.get();
    final stored =
        ((snap.data()?['StationOrderByHunt'] as Map?)?[widget.huntId] as List?)
            ?.map((e) => e.toString())
            .toList();
    if (stored != null &&
        stored.length == allIds.length &&
        stored.every(allIds.contains)) {
      orderedIds = stored;
    }
  } catch (_) {}

  if (orderedIds == null) {
    orderedIds = allIds.toList()..shuffle();
    try {
      await userRef.set(
        {'StationOrderByHunt.${widget.huntId}': orderedIds},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  final ordered = <Map<String, dynamic>>[];
  for (final id in orderedIds) {
    final row = byId[id];
    if (row != null) ordered.add(row);
  }
  return ordered;
}

// =========================
// Location stream
// =========================
Future<void> _startLocationStream() async {
_streamRunning = true;

try {
final enabled = await Geolocator.isLocationServiceEnabled();
if (!enabled) {
_streamRunning = false;
return;
}

LocationPermission perm = await Geolocator.checkPermission();
if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
_streamRunning = false;
return;
}

await _posSub?.cancel();
_posSub = Geolocator.getPositionStream(
locationSettings: const LocationSettings(
accuracy: LocationAccuracy.best,
distanceFilter: 2,
),
).listen((pos) {
if (!mounted || !widget.isActive) return;

final p = LatLng(pos.latitude, pos.longitude);

setState(() {
_player = p;
_playerSpeedMps = (pos.speed.isFinite && pos.speed >= 0) ? pos.speed : 0;
});

// Save location (throttled)
_saveLocationInDatabase(p);

if (_isStationActive) {
_checkSpeedAndWarn();
_checkRadius();
_updateRemainingTimeEstimate();
}

if (!_didInitialFit) {
if (_isStationActive) {
_fitToPlayerAndStation();
} else {
_fitToPlayerOnly();
}
} else {
if (_isStationActive) {
_updateRoute(throttle: true);
}
}
});
} catch (e) {
debugPrint('Location stream error: $e');
_streamRunning = false;
}
}

void _stopLocationStream() {
_posSub?.cancel();
_posSub = null;
_streamRunning = false;
}

// =========================
// Radius / In-Radius UI
// =========================
void _checkRadius() {
if (!_isStationActive) return;
if (_player == null || !_hasStadions) return;

final p = _player!;
final t = _currentStadionPos;

// ✅ guard against NaN / Infinity
if (!p.latitude.isFinite || !p.longitude.isFinite || !t.latitude.isFinite || !t.longitude.isFinite) {
debugPrint("Invalid coords. player=$p target=$t");
return;
}

final d = const Distance().as(LengthUnit.Meter, p, t);

if (!d.isFinite) {
debugPrint("Distance is NaN. player=$p target=$t");
return;
}

final inRad = d <= _stationRadiusMeters;

if (!inRad) {
if (_uiState == MapUiState.inRadius) setState(() => _uiState = MapUiState.normal);
return;
}

if (_uiState != MapUiState.inRadius && !_isBlocked) {
setState(() => _uiState = MapUiState.inRadius);
}
}


// =========================
// Speed warnings + block
// =========================
void _checkSpeedAndWarn() {
if (_player == null) return;
if (_isBlocked) return;
if (_playerSpeedMps < _speedWarnThresholdMps) return;

final now = DateTime.now();
if (_lastWarnAt != null && now.difference(_lastWarnAt!) < _warnCooldown) return;

_lastWarnAt = now;

setState(() {
_warnings = (_warnings + 1).clamp(0, 3);
_uiState = MapUiState.warningDialog;
});

if (_warnings >= 3) _startBlock();
}

void _startBlock() {
_blockTimer?.cancel();
setState(() {
_blockLeft = _blockSeconds;
_uiState = MapUiState.blockedDialog;
});

_blockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
if (!mounted) return;

if (_blockLeft <= 1) {
t.cancel();
setState(() {
_blockLeft = 0;
_uiState = MapUiState.unblockDialog;
});
return;
}

setState(() => _blockLeft -= 1);
});
}

void _skipBlockForTesting() {
_blockTimer?.cancel();
setState(() {
_blockLeft = 0;
_uiState = MapUiState.unblockDialog;
});
}

void _closeOverlay() {
if (_isBlocked) return;
setState(() {
if (_uiState == MapUiState.warningDialog || _uiState == MapUiState.unblockDialog) {
_uiState = MapUiState.normal;
_checkRadius();
}
});
}

// =========================
// Routing via OSRM
// =========================
Future<void> _updateRoute({bool throttle = false}) async {
if (!_isStationActive) return;
if (_player == null) return;
if (!_hasStadions) return;
if (_routeLoading) return;
if (throttle && _routePoints.isNotEmpty) return;

_routeLoading = true;

try {
final from = _player!;
final to = _currentStadionPos;

final url = Uri.parse(
'https://router.project-osrm.org/route/v1/foot/'
'${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
'?overview=full&geometries=geojson&alternatives=false&steps=false',
);

final jsonStr = await _httpGet(url);
final data = json.decode(jsonStr) as Map<String, dynamic>;

final routes = (data['routes'] as List?) ?? const [];
if (routes.isEmpty) return;

final route = routes.first as Map<String, dynamic>;
final geom = route['geometry'] as Map<String, dynamic>;
final coords = (geom['coordinates'] as List).cast<List>();
final routeDistance = (route['distance'] as num?)?.toDouble();
final routeDuration = (route['duration'] as num?)?.toDouble();

final pts = <LatLng>[];
for (final c in coords) {
if (c.length < 2) continue;
final lon = (c[0] as num).toDouble();
final lat = (c[1] as num).toDouble();

if (!lat.isFinite || !lon.isFinite) continue; // ✅ skip bad points
pts.add(LatLng(lat, lon));

}

if (!mounted) return;
setState(() => _routePoints = pts);
_updateRemainingTimeEstimate(
routeMeters: routeDistance,
routeDurationSeconds: routeDuration,
);
} catch (_) {
// ignore
} finally {
_routeLoading = false;
}
}

Future<String> _httpGet(Uri url) async {
final client = HttpClient();
try {
final req = await client.getUrl(url);
req.headers.set(HttpHeaders.userAgentHeader, 'GeoQuest-App');
final res = await req.close();
return await res.transform(utf8.decoder).join();
} finally {
client.close(force: true);
}
}

void _updateRemainingTimeEstimate({
double? routeMeters,
double? routeDurationSeconds,
}) {
if (!_isStationActive) return;
double? baseSeconds;

if (routeDurationSeconds != null &&
routeDurationSeconds.isFinite &&
routeDurationSeconds > 0) {
baseSeconds = routeDurationSeconds;
} else if (routeMeters != null && routeMeters.isFinite && routeMeters > 0) {
baseSeconds = routeMeters / 1.35;
} else if (_player != null && _hasStadions) {
final d = const Distance().as(LengthUnit.Meter, _player!, _currentStadionPos);
if (d.isFinite && d > 0) {
baseSeconds = d / 1.35;
routeMeters = d;
}
}

if (baseSeconds == null || !baseSeconds.isFinite) return;

final meters = (routeMeters != null && routeMeters.isFinite && routeMeters > 0)
? routeMeters
: baseSeconds * 1.35;
final km = meters / 1000.0;
final bufferMinutes = km < 1.0 ? 5 : (km < 2.5 ? 7 : 10);
final totalSeconds =
(baseSeconds + (bufferMinutes * 60)).round().clamp(60, 4 * 60 * 60);

_applyRemainingEstimate(totalSeconds);
}

String _fmtRemaining(int totalSeconds) {
final m = (totalSeconds ~/ 60).toString();
final s = (totalSeconds % 60).toString().padLeft(2, '0');
return '$m:$s';
}

String _currentTeacherName() {
  if (!_hasStadions) return 'Lehrperson';
  final data = allStadionData[_stadionIndex];
  final teacher =
      (data['teacherName'] as String?) ??
      (data['teacher'] as String?) ??
      (data['professor'] as String?) ??
      (data['lehrer'] as String?);
  if (teacher == null || teacher.trim().isEmpty) return 'Lehrperson';
  return teacher.trim();
}

void _applyRemainingEstimate(int estimatedSeconds) {
  final roundedToFullMinute = ((estimatedSeconds + 59) ~/ 60) * 60;
  final current = _remainingSeconds;

  // Keep countdown stable; only adjust when estimate changed at least 1 minute.
  if (current != null && (roundedToFullMinute - current).abs() < 60) {
    return;
  }

  if (!mounted) return;
  setState(() {
    _remainingSeconds = roundedToFullMinute;
    _remainingTime = _fmtRemaining(roundedToFullMinute);
  });
  _ensureRemainingTickerRunning();
}

void _ensureRemainingTickerRunning() {
  if (_remainingTicker != null) return;
  _remainingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
    if (!mounted) return;
    final value = _remainingSeconds;
    if (value == null) return;
    if (value <= 0) return;
    setState(() {
      _remainingSeconds = value - 1;
      _remainingTime = _fmtRemaining(_remainingSeconds!);
    });
  });
}

  // =========================
  // Camera helpers
  // =========================
  bool _isValidLatLng(LatLng p) {
    return p.latitude.isFinite &&
        p.longitude.isFinite &&
        p.latitude >= -90 &&
        p.latitude <= 90 &&
        p.longitude >= -180 &&
        p.longitude <= 180;
  }

  void _fitToPlayerAndStation() {
    if (!_isStationActive) {
      _fitToPlayerOnly();
      return;
    }
    if (_player == null) return;
    if (!_hasStadions) return;

    final player = _player!;
    final station = _currentStadionPos;
    if (!_isValidLatLng(player) || !_isValidLatLng(station)) return;

    _didInitialFit = true;

    final dist = const Distance().as(LengthUnit.Meter, player, station);

    try {
      if (!dist.isFinite || dist < 1.0) {
        _mapController.move(station, 17);
      } else {
        final bounds = LatLngBounds(player, station);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.fromLTRB(30, 90, 30, 220),
          ),
        );
      }
    } catch (_) {
      _mapController.move(station, 17);
    }

    _updateRoute();
}

void _fitToPlayerOnly() {
if (_player == null) return;
if (!_isValidLatLng(_player!)) return;
_didInitialFit = true;
try {
_mapController.move(_player!, 17);
} catch (_) {}
}

// =========================
// Quiz / Stadion flow
// =========================
Future<void> _openQuiz() async {
if (!_isStationActive) return;
if (_isBlocked) return;
if (_uiState != MapUiState.inRadius) return;

final teacherPoints = await Navigator.of(context).push<double>(
  MaterialPageRoute(
    builder: (_) => QuizIntroScreen(
      stationName: _currentStadionName,
      teacherName: _currentTeacherName(),
    ),
  ),
);

if (!mounted || teacherPoints == null) return;

final next = _stadionIndex + 1;
final isFinished = next >= allStadionData.length;

await _awardPointsForCurrentStadion(teacherPoints);

await _saveProgress(isFinished ? allStadionData.length : next, finished: isFinished);

setState(() {
if (!isFinished) {
_stadionIndex = next;
}
_uiState = MapUiState.normal;
_routePoints = [];
_didInitialFit = false;
_remainingSeconds = null;
_remainingTime = '15:00';
_stationStartedAt = DateTime.now();
});

AppNav.stationActive.value = false;
AppNav.selectedIndex.value = 0;
}

Future<void> _awardPointsForCurrentStadion(double teacherPoints) async {
final user = FirebaseAuth.instance.currentUser;
if (user == null || !_hasStadions) return;

final fallbackRemaining = _remainingTime.split(':');
final fallbackSeconds = fallbackRemaining.length == 2
    ? ((int.tryParse(fallbackRemaining[0]) ?? 0) * 60) +
        (int.tryParse(fallbackRemaining[1]) ?? 0)
    : 0;
final remainingSeconds = _remainingSeconds ?? fallbackSeconds;
final inTime = remainingSeconds > 0;
final timeBonus = inTime ? 2.0 : 0.0;
final sanitizedTeacherPoints = teacherPoints.clamp(0.0, 10.0);
final spentSeconds = _stationStartedAt == null
    ? 0
    : DateTime.now()
        .difference(_stationStartedAt!)
        .inSeconds
        .clamp(0, 24 * 60 * 60);
final userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
final stationKey = _stadionIndex.toString();

try {
await FirebaseFirestore.instance.runTransaction((tx) async {
final snap = await tx.get(userRef);
final data = snap.data() ?? <String, dynamic>{};

final completedRaw = (data['CompletedStadions'] as List?) ?? const [];
final completed = completedRaw
    .map((e) {
      if (e is num) return e.toInt();
      return int.tryParse(e.toString());
    })
    .whereType<int>()
    .toSet();
final rawTeacherByStation =
    (data['TeacherPointsByStation'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
final rawBonusByStation =
    (data['TimeBonusByStation'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
final rawTimeByStation =
    (data['TimeSecondsByStation'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

final previousTeacherPoints =
    (rawTeacherByStation[stationKey] as num?)?.toDouble() ?? 0.0;
final previousTimeBonus =
    (rawBonusByStation[stationKey] as num?)?.toDouble() ?? 0.0;
final previousStationTime =
    (rawTimeByStation[stationKey] as num?)?.toInt() ?? 0;

final currentTotalPoints =
    (data['Points'] as num?)?.toDouble() ??
    (data['points'] as num?)?.toDouble() ??
    (data['score'] as num?)?.toDouble() ??
    0.0;
final currentTimeBonusTotal =
    (data['TimeBonusPoints'] as num?)?.toDouble() ?? 0.0;
final currentTeacherTotal =
    (data['TeacherPointsTotal'] as num?)?.toDouble() ??
    (currentTotalPoints - currentTimeBonusTotal);
final currentTotalTimeSeconds =
    (data['TotalTimeSeconds'] as num?)?.toInt() ??
    (data['totalTimeSeconds'] as num?)?.toInt() ??
    0;

final nextTeacherTotal =
    currentTeacherTotal - previousTeacherPoints + sanitizedTeacherPoints;
final nextTimeBonusTotal = currentTimeBonusTotal - previousTimeBonus + timeBonus;
final nextTotalPoints = nextTeacherTotal + nextTimeBonusTotal;
final nextTotalTimeSeconds =
    currentTotalTimeSeconds - previousStationTime + spentSeconds;
final nextTotalTimeText =
    '${nextTotalTimeSeconds ~/ 60}:${(nextTotalTimeSeconds % 60).toString().padLeft(2, '0')}';

tx.set(
  userRef,
  {
    'Points': double.parse(nextTotalPoints.toStringAsFixed(1)),
    'TeacherPointsTotal': double.parse(nextTeacherTotal.toStringAsFixed(1)),
    'TimeBonusPoints': double.parse(nextTimeBonusTotal.toStringAsFixed(1)),
    'LastTeacherScore': sanitizedTeacherPoints,
    'LastTimeBonus': timeBonus,
    'TotalTimeSeconds': nextTotalTimeSeconds,
    'TotalTimeText': nextTotalTimeText,
    'TeacherPointsByStation.$stationKey':
        double.parse(sanitizedTeacherPoints.toStringAsFixed(1)),
    'TimeBonusByStation.$stationKey': double.parse(timeBonus.toStringAsFixed(1)),
    'TimeSecondsByStation.$stationKey': spentSeconds,
    'CompletedStadions': FieldValue.arrayUnion([_stadionIndex]),
    if (!completed.contains(_stadionIndex)) 'SolvedCount': FieldValue.increment(1),
  },
  SetOptions(merge: true),
);
});
} catch (e) {
debugPrint('Award points error: $e');
}
}

void _teleportToStationForTesting() {
if (!_hasStadions) return;

final t = _currentStadionPos;
if (!t.latitude.isFinite || !t.longitude.isFinite) {
debugPrint("Teleport blocked: target coords invalid: $t");
return;
}

setState(() {
_player = LatLng(t.latitude, t.longitude);
_playerSpeedMps = 0;
_uiState = MapUiState.inRadius;
});

_fitToPlayerAndStation();
_checkRadius();
}


// =========================
// UI building blocks
// =========================
Widget _bottomPanel() {
final scheme = Theme.of(context).colorScheme;

final showWarningsLine = _warnings > 0;
final warnText = _isBlocked ? 'Warnungen: 3/3' : 'Warnungen: $_warnings/3';

return Align(
alignment: Alignment.bottomCenter,
child: Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
decoration: BoxDecoration(
color: scheme.surface,
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(18),
topRight: Radius.circular(18),
),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
if (_isStationActive) ...[
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.circle, size: 10, color: Color(0xFFFFC107)),
const SizedBox(width: 8),
Text(
'remaining Time: $_remainingTime',
style: TextStyle(
fontSize: 12.0,
fontWeight: FontWeight.w800,
color: scheme.onSurface.withOpacity(0.75),
),
),
],
),
const SizedBox(height: 8),
],
Text(
_isStationActive
    ? (_hasStadions ? 'Station ${_stadionIndex + 1}' : 'Station -')
    : 'Nächste Aufgabe im Dashboard starten',
style: TextStyle(
fontSize: _isStationActive ? 18 : 14,
fontWeight: FontWeight.w900,
height: 1.0,
color: scheme.onSurface,
),
),
if (showWarningsLine || _isBlocked) ...[
const SizedBox(height: 4),
Text(
warnText,
style: const TextStyle(
fontSize: 12.0,
fontWeight: FontWeight.w900,
color: Colors.red,
height: 1.0,
),
),
],
],
),
),
);
}

Widget _blackButton(String text, VoidCallback onTap) {
final scheme = Theme.of(context).colorScheme;
return SizedBox(
width: double.infinity,
height: 42,
child: ElevatedButton(
onPressed: onTap,
style: ElevatedButton.styleFrom(
backgroundColor: scheme.primary,
foregroundColor: scheme.onPrimary,
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
),
);
}

String _fmtCountdown(int seconds) {
final m = (seconds ~/ 60).toString().padLeft(1, '0');
final s = (seconds % 60).toString().padLeft(2, '0');
return '$m:$s';
}

Widget _dialogCard({
required String title,
required String body,
required Widget bottom,
bool showSkip = false,
}) {
final scheme = Theme.of(context).colorScheme;

return Center(
child: Container(
width: 300,
padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
decoration: BoxDecoration(
color: scheme.surface,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Theme.of(context).dividerColor, width: 1),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
title,
style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.0, color: scheme.onSurface),
),
const SizedBox(height: 10),
Text(
body,
textAlign: TextAlign.center,
style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.25, color: scheme.onSurface),
),
const SizedBox(height: 14),
bottom,
if (showSkip) ...[
const SizedBox(height: 10),
SizedBox(
width: double.infinity,
height: 38,
child: OutlinedButton(
onPressed: _skipBlockForTesting,
style: OutlinedButton.styleFrom(
foregroundColor: scheme.onSurface.withOpacity(0.85),
side: BorderSide(color: scheme.outline.withOpacity(0.5)),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: const Text('TEST: Timer überspringen', style: TextStyle(fontWeight: FontWeight.w800)),
),
),
],
],
),
),
);
}

Widget _overlay() {
switch (_uiState) {
case MapUiState.warningDialog:
return _dialogCard(
title: 'Warnung!',
body: 'Du bewegst dich zu schnell!\nBitte zu Fuß!',
bottom: _blackButton('Verstanden!', _closeOverlay),
);

case MapUiState.blockedDialog:
return _dialogCard(
title: 'Warnung!',
body: 'Du bewegst dich zu schnell!!!!!\n'
'Da du zu oft gegen die Spielregeln\n'
'verstoßen hast bekommst du eine\n'
'Sperre!',
bottom: Text(
_fmtCountdown(_blockLeft),
style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, height: 1.0),
),
showSkip: true,
);

case MapUiState.unblockDialog:
return _dialogCard(
title: 'Warnung!',
body: 'Bitte beachte die Spielregeln um ein\nfaires Spiel zu garantieren!',
bottom: _blackButton('Verstanden!', _closeOverlay),
);

case MapUiState.inRadius:
case MapUiState.normal:
default:
return const SizedBox.shrink();
}
}

Widget _continueToQuizButton() {
if (!_isStationActive) return const SizedBox.shrink();
if (_uiState != MapUiState.inRadius) return const SizedBox.shrink();
if (_isBlocked) return const SizedBox.shrink();

final scheme = Theme.of(context).colorScheme;

return Positioned(
left: 24,
right: 24,
bottom: 96,
child: SizedBox(
height: 44,
child: ElevatedButton(
onPressed: _openQuiz,
style: ElevatedButton.styleFrom(
backgroundColor: scheme.primary,
foregroundColor: scheme.onPrimary,
elevation: 0,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
child: const Text('Zur Aufgabenbewertung', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
),
),
);
}

Widget _testTeleportButton() {
if (!_isStationActive) return const SizedBox.shrink();
final scheme = Theme.of(context).colorScheme;
return Positioned(
right: 14,
bottom: 168,
child: FloatingActionButton(
heroTag: 'teleport',
backgroundColor: scheme.primary,
foregroundColor: scheme.onPrimary,
onPressed: _teleportToStationForTesting,
child: const Icon(Icons.my_location),
),
);
}

// =========================
// Build
// =========================
@override
Widget build(BuildContext context) {
final scheme = Theme.of(context).colorScheme;

if (_stadionsLoading) {
return const Scaffold(body: Center(child: CircularProgressIndicator()));
}

if (allStadionData.isEmpty) {
return const Scaffold(
body: Center(child: Text('No stadions found for this hunt.')),
);
}

    final centerCandidate =
        _player ?? (_isStationActive ? _currentStadionPos : const LatLng(47.3763, 15.0930));
    final mapCenter = _isValidLatLng(centerCandidate)
        ? centerCandidate
        : const LatLng(47.3763, 15.0930);

return Scaffold(
appBar: AppBar(
title: Text(
  _isStationActive ? _currentStadionName : 'Karte',
  style: const TextStyle(fontWeight: FontWeight.w900),
),
centerTitle: true,
),
body: Stack(
children: [
FlutterMap(
mapController: _mapController,
options: MapOptions(
initialCenter: mapCenter,
initialZoom: 15,
onMapReady: () {
if (_player != null && !_didInitialFit) {
if (_isStationActive) {
_fitToPlayerAndStation();
} else {
_fitToPlayerOnly();
}
}
},
),
children: [
TileLayer(
urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
userAgentPackageName: 'com.example.geoquest',
),

// Radius circle around current stadion
if (_isStationActive)
CircleLayer(
circles: [
CircleMarker(
point: _currentStadionPos,
radius: _stationRadiusMeters,
useRadiusInMeter: true,
color: Colors.red.withOpacity(0.12),
borderColor: Colors.red.withOpacity(0.60),
borderStrokeWidth: 2,
),
],
),

// Route (OSRM)
if (_isStationActive && _routePoints.length >= 2)
PolylineLayer(
polylines: [
Polyline(
points: _routePoints,
strokeWidth: 5,
color: Colors.red.withOpacity(0.85),
),
],
),

// Markers
MarkerLayer(
markers: [
// Current stadion marker
if (_isStationActive)
Marker(
point: _currentStadionPos,
width: 44,
height: 44,
child: const Icon(Icons.location_pin, size: 44, color: Colors.red),
),

// Player marker
if (_player != null)
Marker(
point: _player!,
width: 18,
height: 18,
child: Container(
decoration: BoxDecoration(
color: Colors.blue,
shape: BoxShape.circle,
border: Border.all(color: Colors.white, width: 2),
),
),
),
],
),
],
),

_continueToQuizButton(),
_testTeleportButton(),
_bottomPanel(),

// Overlay (Warn/Block/Unblock)
if (_uiState == MapUiState.warningDialog ||
_uiState == MapUiState.blockedDialog ||
_uiState == MapUiState.unblockDialog)
Container(
color: scheme.onSurface.withOpacity(0.10),
child: _overlay(),
),
],
),
);
}
}
