// lib/screens/start_hunt_screen.dart
import 'package:flutter/material.dart';

class StartHuntScreen extends StatefulWidget {
  const StartHuntScreen({super.key});

  @override
  State<StartHuntScreen> createState() => _StartHuntScreenState();
}

class _StartHuntScreenState extends State<StartHuntScreen> {
  int _currentIndex = 0; // 0 = Dashboard

  @override
  Widget build(BuildContext context) {
    const userName = 'Name'; // TODO: später echten Namen verwenden.

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.location_on, size: 40, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'GeoQuest',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Hello, "$userName"',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nachdem du "Start Hunt"\n'
                    'klickst startet das Spiel\n'
                    'und somit auch die Zeit!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Info: Hier können später zusätzliche\n'
                      'Details zur aktuellen Jagd stehen.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    // TODO: hier später die eigentliche Schnitzeljagd starten
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Start Hunt pressed (coming soon)'),
                      ),
                    );
                  },
                  child: const Text('Start Hunt'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // TODO: später auf andere Screens navigieren (Map, Progress, Menu)
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
