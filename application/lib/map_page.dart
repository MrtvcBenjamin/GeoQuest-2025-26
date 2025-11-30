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
  LatLng? myPosition; // wird später geladen

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      myPosition = LatLng(pos.latitude, pos.longitude);
    });

    await saveLocationInDatabase(myPosition);
  }

  Future<void> saveLocationInDatabase(LatLng? position) async{
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Sicherheitsprüfung: Ist der Standort vorhanden UND ist der Benutzer angemeldet?
    if (position != null && userId != null) {
      try {
        final playerLocation = await FirebaseFirestore.instance
            .collection("PlayerLocation")
            .add({
          'location': GeoPoint(position.latitude, position.longitude),
          'userId': userId // Jetzt verwenden wir die geprüfte Variable
        });
        print('Location successfully saved with ID: ${playerLocation.id}');
      } catch (e) {
        print('Firestore error: $e');
      }
    } else {
      print('Error: Position is null OR User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zeige Ladebildschirm solange Position null ist
    if (myPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("OpenStreetMap"),
      ),

      body: FlutterMap(
        options: MapOptions(
            initialCenter: const LatLng(47.37636193740281, 15.09308188079115),
          initialZoom: 14,
        ),

        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(),
          ),

          MarkerLayer(
            markers: [
              // Fixer Marker
              const Marker(
                point: LatLng(47.38014809760746, 15.092492796820286),
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),

              // Dein Standort
              if (myPosition != null)
                Marker(
                  point: myPosition!,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 35,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
