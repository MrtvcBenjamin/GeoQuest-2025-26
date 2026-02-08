import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum MapUiState { normal, warningDialog, blockedDialog, unblockDialog, inRadius }

class _Station {
  final String name;
  final LatLng pos;

  const _Station({required this.name, required this.pos});
}

class MapTab extends StatefulWidget {
  final bool isActive;
  const MapTab({super.key, required this.isActive});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  // 10 Stationen in Leoben (Sehenswürdigkeiten / markante Punkte)
  static const List<_Station> _stations = [
    _Station(name: 'Station 1 – Hauptplatz Leoben', pos: LatLng(47.38262, 15.09494)),
    _Station(name: 'Station 2 – Schwammerlturm', pos: LatLng(47.38209, 15.09575)),
    _Station(name: 'Station 3 – Asia Spa Leoben', pos: LatLng(47.38855, 15.08990)),
    _Station(name: 'Station 4 – Stadtpark Leoben', pos: LatLng(47.38365, 15.09210)),
    _Station(name: 'Station 5 – Leoben Hbf', pos: LatLng(47.38938, 15.09109)),
    _Station(name: 'Station 6 – Montanuniversität', pos: LatLng(47.38717, 15.09440)),
    _Station(name: 'Station 7 – Gösser Brauerei', pos: LatLng(47.36890, 15.09220)),
    _Station(name: 'Station 8 – Massenburg', pos: LatLng(47.38490, 15.08855)),
    _Station(name: 'Station 9 – Glanegg (Aussicht)', pos: LatLng(47.38590, 15.08230)),
    _Station(name: 'Station 10 – Murbrücke (Zentrum)', pos: LatLng(47.38310, 15.09840)),
  ];

  int _stationIndex = 0;

  _Station get _currentStation => _stations[_stationIndex];

  // Radius um Station (Meter)
  static const double _stationRadiusMeters = 60;

  // Speed-Logik
  static const double _speedWarnThresholdMps = 6.0; // ~21.6 km/h
  static const Duration _warnCooldown = Duration(seconds: 12);
  DateTime? _lastWarnAt;

  // Block
  static const int _blockSeconds = 5 * 60;
  Timer? _blockTimer;
  int _blockLeft = 0;

  // Location
  StreamSubscription<Position>? _posSub;
  bool _streamRunning = false;
  LatLng? _player;
  double _playerSpeedMps = 0;

  // Route (OSRM)
  bool _routeLoading = false;
  List<LatLng> _routePoints = [];

  // UI State
  MapUiState _uiState = MapUiState.normal;
  int _warnings = 0;

  // Demo/Mock Werte
  String _remainingTime = '15:00';

  bool _didInitialFit = false;

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
    _stopLocationStream();
    super.dispose();
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

        _checkSpeedAndWarn();
        _checkRadius();

        if (!_didInitialFit) {
          _fitToPlayerAndStation();
        } else {
          // route nicht bei jedem Update neu laden; throttled
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

  // =========================
  // Radius / In-Radius UI
  // =========================
  void _checkRadius() {
    if (_player == null) return;
    final d = const Distance().as(LengthUnit.Meter, _player!, _currentStation.pos);

    final inRad = d <= _stationRadiusMeters;
    if (!inRad) {
      if (_uiState == MapUiState.inRadius) {
        setState(() => _uiState = MapUiState.normal);
      }
      return;
    }

    if (_uiState != MapUiState.inRadius && !_isBlocked) {
      setState(() => _uiState = MapUiState.inRadius);
    }
  }

  // =========================
  // Speed warnings + block
  // =========================
  bool get _isBlocked => _blockLeft > 0;

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

    if (_warnings >= 3) {
      // direkt blocken
      _startBlock();
    }
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
          _uiState = MapUiState.unblockDialog; // Screen 3
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
    if (_isBlocked) return; // während Block: "gefangen" bleiben
    setState(() {
      if (_uiState == MapUiState.warningDialog || _uiState == MapUiState.unblockDialog) {
        // nach "Verstanden" zurück zur normalen Map (oder inRadius, falls im Kreis)
        _uiState = MapUiState.normal;
        _checkRadius();
      }
    });
  }

  // =========================
  // Routing via OSRM (kein extra package)
  // =========================
  Future<void> _updateRoute({bool throttle = false}) async {
    if (_player == null) return;
    if (_routeLoading) return;
    if (throttle && _routePoints.isNotEmpty) return;

    _routeLoading = true;

    try {
      final from = _player!;
      final to = _currentStation.pos;

      // OSRM expects lon,lat
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
      final body = await res.transform(utf8.decoder).join();
      return body;
    } finally {
      client.close(force: true);
    }
  }

  // =========================
  // Camera helpers
  // =========================
  void _fitToPlayerAndStation() {
    if (_player == null) return;
    _didInitialFit = true;

    final bounds = LatLngBounds(_player!, _currentStation.pos);

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
  // Quiz / Station flow
  // =========================
  Future<void> _openQuiz() async {
    if (_isBlocked) return;
    if (_uiState != MapUiState.inRadius) return;

    // Placeholder: hier später dein QuizScreen rein
    // Für jetzt: Station als "abgeschlossen" simulieren
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
      setState(() {
        _stationIndex = (_stationIndex + 1) % _stations.length;
        _uiState = MapUiState.normal;
        _routePoints = [];
        _didInitialFit = false;
      });
      _checkRadius();
      _updateRoute();
    }
  }

  void _teleportToStationForTesting() {
    setState(() {
      _player = LatLng(_currentStation.pos.latitude, _currentStation.pos.longitude);
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
              'Station ${_stationIndex + 1}',
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
                if (_player != null && !_didInitialFit) _fitToPlayerAndStation();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geoquest',
              ),

              // Radius-Kreis um aktuelle Station
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentStation.pos,
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

              // Marker
              MarkerLayer(
                markers: [
                  // Station marker (immer sichtbar)
                  Marker(
                    point: _currentStation.pos,
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
