import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  static const double _stationRadiusMeters = 60;

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

  // =========================
  // Lifecycle
  // =========================
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadAllStadionData(widget.huntId);

    if (mounted && widget.isActive) {
      await _startLocationStream();
    }

    if (mounted) {
      setState(() => _stadionsLoading = false);
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
      _init();
      return;
    }

    // Start/stop stream based on active tab
    if (widget.isActive && !_streamRunning) _startLocationStream();
    if (!widget.isActive && _streamRunning) _stopLocationStream();
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    _stopLocationStream();
    super.dispose();
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

      final list = snapshot.docs.map((d) => d.data()).toList();

      if (mounted) {
        setState(() {
          allStadionData = list;
          // clamp index if needed
           if (_stadionIndex >= allStadionData.length) {
            _stadionIndex = allStadionData.isEmpty ? 0 : allStadionData.length - 1;
          }
        });
      }
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
  Future<void> _saveProgress(int stadionIndex) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("Hunts")
          .doc(widget.huntId)
          .collection("Progress")
          .doc(user.uid)
          .set(
        {
          'currentStadionIndex': stadionIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Firestore Save Error (Progress): $e');
    }
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
        if (!_hasStadions) return;

        final p = LatLng(pos.latitude, pos.longitude);

        setState(() {
          _player = p;
          _playerSpeedMps = (pos.speed.isFinite && pos.speed >= 0) ? pos.speed : 0;
        });

        // Save location (throttled)
        _saveLocationInDatabase(p);

        _checkSpeedAndWarn();
        _checkRadius();

        if (!_didInitialFit) {
          _fitToPlayerAndStation();
        } else {
          _updateRoute(throttle: true);
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

      final geom = (routes.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
      final coords = (geom['coordinates'] as List).cast<List>();

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

  // =========================
  // Camera helpers
  // =========================
  void _fitToPlayerAndStation() {
    if (_player == null) return;
    if (!_hasStadions) return;

    _didInitialFit = true;

    final bounds = LatLngBounds(_player!, _currentStadionPos);

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(30, 90, 30, 220),
        ),
      );
    } catch (_) {
      // ignore
    }

    _updateRoute();
  }

  // =========================
  // Quiz / Stadion flow
  // =========================
  Future<void> _openQuiz() async {
    if (_isBlocked) return;
    if (_uiState != MapUiState.inRadius) return;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Text(
            'Quiz von Frau Professor xxx',
            style: TextStyle(fontWeight: FontWeight.w900, color: scheme.onSurface),
          ),
          content: Text(
            'Test-Code eingeben: 123',
            style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 0,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (ok == true) {
      final next = (_stadionIndex + 1) % allStadionData.length;

      // Optional progress save
      await _saveProgress(next);

      setState(() {
        _stadionIndex = next;
        _uiState = MapUiState.normal;
        _routePoints = [];
        _didInitialFit = false;
      });

      _checkRadius();
      _updateRoute();
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
            Text(
              _hasStadions ? 'Station ${_stadionIndex + 1}' : 'Station -',
              style: TextStyle(
                fontSize: 18,
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
          child: const Text('Continue to Quiz', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _testTeleportButton() {
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

    final mapCenter = _player ?? _currentStadionPos;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStadionName, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                if (_player != null && !_didInitialFit) _fitToPlayerAndStation();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geoquest',
              ),

              // Radius circle around current stadion
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
              if (_routePoints.length >= 2)
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
