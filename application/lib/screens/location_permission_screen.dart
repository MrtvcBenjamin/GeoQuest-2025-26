import 'package:flutter/material.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _locationAllowed = false;
  bool _notificationsAllowed = false;

  void _continueToApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const FlutterLogo(size: 80),
            const SizedBox(height: 16),
            const Text(
              'GeoQuest',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fast fertig!\nErlaube bitte folgende Berechtigungen:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.location_on),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Standortzugriff\nBenötigt, um deine Position an Stationen zu überprüfen.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  setState(() => _locationAllowed = true);
                },
                child: const Text(
                  'Standort erlauben',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _locationAllowed ? 'Aktiviert' : 'Noch nicht erlaubt',
                style: TextStyle(
                  color: _locationAllowed ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.notifications),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Benachrichtigungen\nDamit du über neue Aufgaben informiert wirst.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  setState(() => _notificationsAllowed = true);
                },
                child: const Text(
                  'Benachrichtigungen erlauben',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _notificationsAllowed ? 'Aktiviert' : 'Noch nicht erlaubt',
                style: TextStyle(
                  color: _notificationsAllowed ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _continueToApp,
                child: const Text(
                  'Continue to App',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
