import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_nav.dart';
import 'qr_scan_screen.dart';
import 'quiz_intro_screen.dart';

enum MapUiState {
  normal,
  warningDialog,
  blockedDialog,
  unblockDialog,
  inRadius
}

class _Station {
  final String name;
  final LatLng pos;
  final String teacherName;
  final String qrCode;

  const _Station({
    required this.name,
    required this.pos,
    required this.teacherName,
    required this.qrCode,
  });
}

class MapTab extends StatefulWidget {
  final bool isActive;
  const MapTab({super.key, required this.isActive});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  static const List<_Station> _stations = [
    _Station(
      name: 'Station 1 - Hauptplatz Leoben',
      pos: LatLng(47.38262, 15.09494),
      teacherName: 'Frau Prof. Steiner',
      qrCode: 'GEOQUEST_STATION_1',
    ),
    _Station(
      name: 'Station 2 - Schwammerlturm',
      pos: LatLng(47.38209, 15.09575),
      teacherName: 'Herr Prof. Berger',
      qrCode: 'GEOQUEST_STATION_2',
    ),
    _Station(
      name: 'Station 3 - Asia Spa Leoben',
      pos: LatLng(47.38855, 15.08990),
      teacherName: 'Frau Prof. Koch',
      qrCode: 'GEOQUEST_STATION_3',
    ),
    _Station(
      name: 'Station 4 - Stadtpark Leoben',
      pos: LatLng(47.38365, 15.09210),
      teacherName: 'Herr Prof. Leitner',
      qrCode: 'GEOQUEST_STATION_4',
    ),
    _Station(
      name: 'Station 5 - Leoben Hbf',
      pos: LatLng(47.38938, 15.09109),
      teacherName: 'Frau Prof. Moser',
      qrCode: 'GEOQUEST_STATION_5',
    ),
    _Station(
      name: 'Station 6 - Montanuniversitaet',
      pos: LatLng(47.38717, 15.09440),
      teacherName: 'Herr Prof. Kurz',
      qrCode: 'GEOQUEST_STATION_6',
    ),
    _Station(
      name: 'Station 7 - Goesser Brauerei',
      pos: LatLng(47.36890, 15.09220),
      teacherName: 'Frau Prof. Egger',
      qrCode: 'GEOQUEST_STATION_7',
    ),
    _Station(
      name: 'Station 8 - Massenburg',
      pos: LatLng(47.38490, 15.08855),
      teacherName: 'Herr Prof. Pichler',
      qrCode: 'GEOQUEST_STATION_8',
    ),
    _Station(
      name: 'Station 9 - Glanegg (Aussicht)',
      pos: LatLng(47.38590, 15.08230),
      teacherName: 'Frau Prof. Reiter',
      qrCode: 'GEOQUEST_STATION_9',
    ),
    _Station(
      name: 'Station 10 - Murbruecke (Zentrum)',
      pos: LatLng(47.38310, 15.09840),
      teacherName: 'Herr Prof. Wagner',
      qrCode: 'GEOQUEST_STATION_10',
    ),
  ];

  static const double _stationRadiusMeters = 60;
  static const double _speedWarnThresholdMps = 6.0;
  static const double _minUiMoveMeters = 4.0;
  static const double _minRouteRefreshMoveMeters = 12.0;
  static const double _minSpeedDeltaForUiMps = 0.8;
  static const Duration _warnCooldown = Duration(seconds: 12);
  static const int _blockSeconds = 5 * 60;
  static const Duration _routeRefreshInterval = Duration(seconds: 8);

  int _stationIndex = 0;
  int _warnings = 0;
  bool _streamRunning = false;
  bool _didInitialFit = false;
  bool _routeLoading = false;
  bool _taskUnlocked = false;
  String? _unlockMethod;
  final String _remainingTime = '15:00';
  MapUiState _uiState = MapUiState.normal;

  DateTime? _lastWarnAt;
  DateTime? _lastRouteFetchAt;
  StreamSubscription<Position>? _posSub;
  Timer? _blockTimer;
  final ValueNotifier<int> _blockLeft = ValueNotifier<int>(0);
  LatLng? _player;
  double _playerSpeedMps = 0;
  LatLng? _lastRouteFrom;
  List<LatLng> _routePoints = [];

  _Station get _currentStation => _stations[_stationIndex];
  bool get _isBlocked => _blockLeft.value > 0;

  bool _isFiniteCoord(double value) => value.isFinite && !value.isNaN;

  bool _isValidLatLng(LatLng p) {
    return _isFiniteCoord(p.latitude) &&
        _isFiniteCoord(p.longitude) &&
        p.latitude.abs() <= 90 &&
        p.longitude.abs() <= 180;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _startLocationStream();
  }

  @override
  void didUpdateWidget(covariant MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_streamRunning) _startLocationStream();
    if (!widget.isActive && _streamRunning) _stopLocationStream();
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    AppNav.mapBlocked.value = false;
    _blockLeft.dispose();
    _stopLocationStream();
    super.dispose();
  }

  Future<void> _startLocationStream() async {
    _streamRunning = true;

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _streamRunning = false;
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _streamRunning = false;
        return;
      }

      await _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 4,
        ),
      ).listen((pos) {
        if (!mounted || !widget.isActive) return;

        final prevPlayer = _player;
        final prevSpeed = _playerSpeedMps;
        final p = LatLng(pos.latitude, pos.longitude);
        if (!_isValidLatLng(p)) return;

        final speed = (pos.speed.isFinite && pos.speed >= 0) ? pos.speed : 0.0;
        final moved = prevPlayer == null
            ? double.infinity
            : const Distance().as(LengthUnit.Meter, prevPlayer, p);
        final speedDelta = (speed - prevSpeed).abs();
        final shouldRebuildMap = prevPlayer == null ||
            moved >= _minUiMoveMeters ||
            speedDelta >= _minSpeedDeltaForUiMps;

        _player = p;
        _playerSpeedMps = speed;
        if (shouldRebuildMap) {
          setState(() {});
        }

        _checkSpeedAndWarn();
        _checkRadiusAndUnlock();

        if (!_didInitialFit) {
          _fitToPlayerAndStation();
        } else {
          _updateRoute(throttle: true);
        }
      });
    } catch (_) {
      _streamRunning = false;
    }
  }

  void _stopLocationStream() {
    _posSub?.cancel();
    _posSub = null;
    _streamRunning = false;
  }

  void _checkRadiusAndUnlock() {
    if (_player == null) return;
    final d =
        const Distance().as(LengthUnit.Meter, _player!, _currentStation.pos);
    final inRad = d <= _stationRadiusMeters;

    var needsUiUpdate = false;
    var nextUiState = _uiState;
    var nextTaskUnlocked = _taskUnlocked;
    var nextUnlockMethod = _unlockMethod;

    if (inRad && !_taskUnlocked) {
      nextTaskUnlocked = true;
      nextUnlockMethod = 'Standort';
      needsUiUpdate = true;
    }

    if (!inRad && _uiState == MapUiState.inRadius) {
      nextUiState = MapUiState.normal;
      needsUiUpdate = true;
    } else if (inRad && _uiState != MapUiState.inRadius && !_isBlocked) {
      nextUiState = MapUiState.inRadius;
      needsUiUpdate = true;
    }

    if (needsUiUpdate) {
      setState(() {
        _uiState = nextUiState;
        _taskUnlocked = nextTaskUnlocked;
        _unlockMethod = nextUnlockMethod;
      });
    }
  }

  void _checkSpeedAndWarn() {
    if (_player == null) return;
    if (_isBlocked) return;
    if (_playerSpeedMps < _speedWarnThresholdMps) return;

    final now = DateTime.now();
    if (_lastWarnAt != null && now.difference(_lastWarnAt!) < _warnCooldown) {
      return;
    }
    _lastWarnAt = now;

    setState(() {
      _warnings = (_warnings + 1).clamp(0, 3);
      _uiState = MapUiState.warningDialog;
    });
    if (_warnings >= 3) {
      _startBlock();
    }
  }

  void _startBlock() {
    _blockTimer?.cancel();
    AppNav.mapBlocked.value = true;
    _blockLeft.value = _blockSeconds;
    setState(() {
      _uiState = MapUiState.blockedDialog;
    });

    _blockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_blockLeft.value <= 1) {
        t.cancel();
        AppNav.mapBlocked.value = false;
        _blockLeft.value = 0;
        setState(() {
          _uiState = MapUiState.unblockDialog;
        });
        return;
      }
      _blockLeft.value = _blockLeft.value - 1;
    });
  }

  void _skipBlockForTesting() {
    _blockTimer?.cancel();
    AppNav.mapBlocked.value = false;
    _blockLeft.value = 0;
    setState(() {
      _uiState = MapUiState.unblockDialog;
    });
  }

  void _closeOverlay() {
    if (_isBlocked) return;
    setState(() {
      if (_uiState == MapUiState.warningDialog ||
          _uiState == MapUiState.unblockDialog) {
        _uiState = MapUiState.normal;
        _checkRadiusAndUnlock();
      }
    });
  }

  Future<void> _updateRoute({bool throttle = false}) async {
    if (_player == null) return;
    if (_routeLoading) return;

    final now = DateTime.now();
    final movedSinceLastRoute = _lastRouteFrom == null
        ? double.infinity
        : const Distance().as(LengthUnit.Meter, _lastRouteFrom!, _player!);

    if (throttle &&
        _lastRouteFetchAt != null &&
        now.difference(_lastRouteFetchAt!) < _routeRefreshInterval &&
        movedSinceLastRoute < _minRouteRefreshMoveMeters) {
      return;
    }

    _routeLoading = true;
    _lastRouteFetchAt = now;

    try {
      final from = _player!;
      final to = _currentStation.pos;

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson&alternatives=false&steps=false',
      );

      final jsonStr = await _httpGet(url);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) return;

      final geom = (routes.first as Map<String, dynamic>)['geometry']
          as Map<String, dynamic>;
      final coords = (geom['coordinates'] as List?) ?? const [];
      final pts = <LatLng>[];

      for (final c in coords) {
        if (c is! List || c.length < 2) continue;
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        final point = LatLng(lat, lon);
        if (_isValidLatLng(point)) {
          pts.add(point);
        }
      }

      if (!mounted || pts.length < 2) return;
      _lastRouteFrom = from;
      setState(() => _routePoints = pts);
    } catch (_) {
      // keep previous route if fetch fails
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
      return res.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  void _fitToPlayerAndStation() {
    if (_player == null) return;
    _didInitialFit = true;

    final distanceToStation = const Distance().as(
      LengthUnit.Meter,
      _player!,
      _currentStation.pos,
    );

    try {
      // Prevent NaN/Infinity camera math when both points are effectively identical.
      if (distanceToStation < 1.0) {
        _mapController.move(_player!, 17.5);
      } else {
        final bounds = LatLngBounds(_player!, _currentStation.pos);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.fromLTRB(30, 90, 30, 220),
          ),
        );
      }
    } catch (_) {}

    _updateRoute();
  }

  Future<void> _scanQrUnlock() async {
    if (_isBlocked) return;

    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanScreen(expectedCode: _currentStation.qrCode),
      ),
    );

    if (!mounted || scannedCode == null) return;

    if (scannedCode.trim() == _currentStation.qrCode) {
      setState(() {
        _taskUnlocked = true;
        _unlockMethod = 'QR';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aufgabe via QR freigeschaltet.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Dieser QR Code passt nicht zur aktuellen Station.')),
    );
  }

  Future<void> _openQuizFlow() async {
    if (_isBlocked || !_taskUnlocked) return;

    final points = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (_) => QuizIntroScreen(
          stationName: _currentStation.name,
          teacherName: _currentStation.teacherName,
        ),
      ),
    );

    if (!mounted || points == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Bewertet mit ${points.toStringAsFixed(1)} Punkten.')),
    );

    setState(() {
      _stationIndex = (_stationIndex + 1) % _stations.length;
      _uiState = MapUiState.normal;
      _routePoints = [];
      _didInitialFit = false;
      _taskUnlocked = false;
      _unlockMethod = null;
      _lastRouteFetchAt = null;
      _lastRouteFrom = null;
    });

    _checkRadiusAndUnlock();
    _updateRoute();
  }

  void _teleportToStationForTesting() {
    setState(() {
      _player =
          LatLng(_currentStation.pos.latitude, _currentStation.pos.longitude);
      _playerSpeedMps = 0;
      _taskUnlocked = true;
      _unlockMethod = 'Standort';
      _uiState = MapUiState.inRadius;
    });
    _fitToPlayerAndStation();
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
        child: Text(text,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
      ),
    );
  }

  String _fmtCountdown(int seconds) {
    final m = (seconds ~/ 60).toString();
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
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: scheme.onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: scheme.onSurface),
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
                    foregroundColor: scheme.onSurface.withValues(alpha: 0.85),
                    side: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('TEST: Timer ueberspringen',
                      style: TextStyle(fontWeight: FontWeight.w800)),
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
          title: 'Warnung',
          body: 'Du bewegst dich zu schnell.\nBitte zu Fuss!',
          bottom: _blackButton('Verstanden', _closeOverlay),
        );
      case MapUiState.blockedDialog:
        return _dialogCard(
          title: 'Sperre',
          body:
              'Du warst zu oft zu schnell.\nWarte bis der Timer abgelaufen ist.',
          bottom: ValueListenableBuilder<int>(
            valueListenable: _blockLeft,
            builder: (context, seconds, _) => Text(
              _fmtCountdown(seconds),
              style: const TextStyle(
                  fontSize: 44, fontWeight: FontWeight.w900, height: 1),
            ),
          ),
          showSkip: true,
        );
      case MapUiState.unblockDialog:
        return _dialogCard(
          title: 'Hinweis',
          body: 'Bitte beachte die Spielregeln.',
          bottom: _blackButton('Verstanden', _closeOverlay),
        );
      case MapUiState.inRadius:
      case MapUiState.normal:
        return const SizedBox.shrink();
    }
  }

  Widget _bottomPanel() {
    final scheme = Theme.of(context).colorScheme;
    final unlockText = _taskUnlocked
        ? 'Aufgabe freigeschaltet ($_unlockMethod)'
        : 'Nicht freigeschaltet';
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
              topLeft: Radius.circular(18), topRight: Radius.circular(18)),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Station ${_stationIndex + 1}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              unlockText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _taskUnlocked
                    ? Colors.green[700]
                    : scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (showWarningsLine || _isBlocked) ...[
              const SizedBox(height: 4),
              Text(
                warnText,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                    height: 1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _unlockButtons() {
    if (_isBlocked) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 148,
      child: Column(
        children: [
          if (!_taskUnlocked)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _scanQrUnlock,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Mit QR freischalten',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          if (_taskUnlocked)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _openQuizFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Aufgabe starten',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _testTeleportButton() {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      right: 14,
      bottom: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              'TEST',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'teleport',
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            onPressed: _teleportToStationForTesting,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mapCenter = _player ?? _currentStation.pos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map', style: TextStyle(fontWeight: FontWeight.w900)),
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
                  _fitToPlayerAndStation();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geoquest',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentStation.pos,
                    radius: _stationRadiusMeters,
                    useRadiusInMeter: true,
                    color: Colors.red.withValues(alpha: 0.12),
                    borderColor: Colors.red.withValues(alpha: 0.60),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.red.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentStation.pos,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.location_pin,
                        size: 44, color: Colors.red),
                  ),
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
          _unlockButtons(),
          _testTeleportButton(),
          _bottomPanel(),
          if (_uiState == MapUiState.warningDialog ||
              _uiState == MapUiState.blockedDialog ||
              _uiState == MapUiState.unblockDialog)
            Container(
              color: scheme.onSurface.withValues(alpha: 0.10),
              child: _overlay(),
            ),
        ],
      ),
    );
  }
}
