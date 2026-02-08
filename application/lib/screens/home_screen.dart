import 'package:flutter/material.dart';
import 'menu_tab.dart';
import 'progress_tab.dart';
import 'start_hunt_screen.dart';
import 'map_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const StartHuntScreen(),
          MapTab(isActive: _index == 1),
          const ProgressTab(),
          const MenuTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? scheme.onSurface,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? scheme.onSurface.withOpacity(0.45),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          iconSize: 22,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
        ),
      ),
    );
  }
}
