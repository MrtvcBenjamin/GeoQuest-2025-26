import 'package:flutter/material.dart';

class StartHuntScreen extends StatefulWidget {
  final VoidCallback onStartRoute;

  const StartHuntScreen({super.key, required this.onStartRoute});

  @override
  State<StartHuntScreen> createState() => _StartHuntScreenState();
}

class _StartHuntScreenState extends State<StartHuntScreen> {
  bool _huntStarted = false;

  @override
  Widget build(BuildContext context) {
    const userName = 'Name';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const FlutterLogo(size: 80),
            const SizedBox(height: 8),
            const Text(
              'GeoQuest',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hello, "$userName"',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _huntStarted
                  ? _buildStartRouteCard()
                  : _buildStartHuntCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartHuntCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nachdem du "Start Hunt"\nklickst startet das Spiel\nund somit auch die Zeit!',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                _huntStarted = true;
              });
            },
            child: const Text(
              'Start Hunt',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartRouteCard() {
    const nextStation = 'Station 1';
    const distance = 250;
    const points = 10;
    const remainingTime = '15:00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Station:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          nextStation,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text('Distance: ${distance}m   Points: $points p'),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.circle, size: 10, color: Colors.orange),
            SizedBox(width: 8),
            Text('remaining Time: $remainingTime'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: widget.onStartRoute,
            child: const Text(
              'Start',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
