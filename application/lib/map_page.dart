import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? myPosition;
  List<Map<String, dynamic>> allStadionData = [];
  bool isLoading = true;
  int currentStadionIndex = 1;
  LatLng testposition = LatLng(47.377822895887235, 15.104332417155826);
  // StreamSubscription um den Standort-Stream sauber zu beenden
  StreamSubscription<Position>? _positionStream;
  bool isFirstUpload = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    // Wichtig: Stream stoppen, wenn die Seite verlassen wird
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    // 1. Stadien laden (Wichtig: Erst Daten, dann Standort-Check)
    await getAllStadionData("xISAk6mXjjEpDUHYyxZi");
    // 2. Standort-Stream starten
    await _startLocationTracking();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Präzise Einstellungen für den Stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // Update alle 2 Meter Bewegung
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position pos) {
      if (mounted) {
        setState(() {
          myPosition = LatLng(pos.latitude, pos.longitude);
        });

        // Jedes Mal prüfen, ob wir einem Stadion nah sind
        _checkProximity();

        // Standort in DB speichern (optional: Intervall drosseln für Performance)
        if (isFirstUpload) {
          saveLocationInDatabase(myPosition);
          isFirstUpload = false; // Disable so it doesn't fire again
        }
      }
    });
  }

  Future<void> getAllStadionData(String huntId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Hunts")
          .doc(huntId)
          .collection("Stadions")
          .orderBy("stadionIndex")
          .get();

      if (mounted) {
        setState(() {
          allStadionData = snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      debugPrint('Firestore Load Error: $e');
    }
  }

  void _checkProximity() {
    if (myPosition == null || allStadionData.isEmpty) return;
    if (currentStadionIndex >= allStadionData.length) return;

    final aktuellesZiel = allStadionData[currentStadionIndex];
    final targetGeo = aktuellesZiel['stadionLocation'] as GeoPoint;

    double distanceInMeters = Geolocator.distanceBetween(
      myPosition!.latitude,
      myPosition!.longitude,
      targetGeo.latitude,
      targetGeo.longitude,
    );

    // Radius auf 20 Meter gesetzt
    if (distanceInMeters < 50) {
      _showDiscoveryDialog(aktuellesZiel['title'] ?? "Stadion");
      saveLocationInDatabase(myPosition);
    }
  }

  void _showDiscoveryDialog(String name) {
    // Verhindert, dass das Pop-up mehrfach aufploppt während man im Radius steht
    _positionStream?.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.emoji_events, color: Colors.yellow, size: 50),
        content: Text("Glückwunsch! Du hast das $name erreicht!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentStadionIndex++; // Färbt das alte grün und schaltet neues frei
              });
              _positionStream?.resume(); // Tracking geht weiter
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> saveLocationInDatabase(LatLng? position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (position == null || user == null) return;
    try {
      await FirebaseFirestore.instance.collection("PlayerLocation").doc(user.uid).set({
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("GeoQuest Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: myPosition ?? const LatLng(47.3763, 15.0930),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: [
              if (myPosition != null)
                Marker(
                  point: testposition,
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.navigation, color: Colors.blue, size: 30),
                ),
              for (var data in allStadionData) ...[
                if (data['stadionIndex'] <= currentStadionIndex)
                  Marker(
                    point: LatLng(
                      (data['stadionLocation'] as GeoPoint).latitude,
                      (data['stadionLocation'] as GeoPoint).longitude,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 35,
                      color: data['stadionIndex'] < currentStadionIndex
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}