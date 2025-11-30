import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deine Stationen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Schnitzeljagd Leoben',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text('Hauptplatz'),
              subtitle: Text('Station 1 von 12'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text('Schwammerlturm'),
              subtitle: Text('Station 2 von 12'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
