import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum MapUiState { normal, warningDialog, blockedDialog, unblockDialog, inRadius }

class MapTab extends StatefulWidget {
  final bool isActive;
  const MapTab({super.key, required this.isActive});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();
  static const LatLng _station = LatLng(47.3833, 15.0944);

  StreamSubscription<Position>? _posSub;
  LatLng? _player;

  MapUiState _uiState = MapUiState.normal;
  int _warnings = 0;
  String _remainingTime = '15:00';
  String _stationName = 'Station 1';

  bool _streamRunning = false;

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
        setState(() => _player = LatLng(pos.latitude, pos.longitude));
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

  @override
  void dispose() {
    _stopLocationStream();
    super.dispose();
  }

  void _closeOverlay() => setState(() => _uiState = MapUiState.normal);

  Widget _bottomPanel() {
    final scheme = Theme.of(context).colorScheme;
    final showWarningsLine = _warnings > 0;

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
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _stationName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: scheme.onSurface,
              ),
            ),
            if (showWarningsLine) ...[
              const SizedBox(height: 4),
              Text(
                'Warnungen: $_warnings/3',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
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

  Widget _dialogCard({required String title, required String body, required Widget bottom}) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 285,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.0, color: scheme.onSurface)),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.25, color: scheme.onSurface),
            ),
            const SizedBox(height: 14),
            bottom,
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
        child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
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
          body: 'Du bewegst dich zu schnell!\nDa du dich gegen die Spielregeln\nverstoßen hast bekommst du eine\nSperre!',
          bottom: const Text('5:00', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, height: 1.0)),
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
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 96,
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Continue to Quiz', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final LatLng mapCenter = _player ?? _station;

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
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.geoquest',
              ),
              if (_player != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_player!, _station],
                      strokeWidth: 4,
                      color: Colors.red.withOpacity(0.85),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _station,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.location_pin, size: 44, color: Colors.red),
                  ),
                  if (_player != null)
                    Marker(
                      point: _player!,
                      width: 16,
                      height: 16,
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
          _bottomPanel(),

          if (_uiState == MapUiState.warningDialog || _uiState == MapUiState.blockedDialog || _uiState == MapUiState.unblockDialog)
            Container(
              color: scheme.onSurface.withOpacity(0.10),
              child: _overlay(),
            ),
        ],
      ),
    );
  }
}
