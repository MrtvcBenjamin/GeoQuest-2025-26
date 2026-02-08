import 'package:flutter/material.dart';

import '../models/app_nav.dart';
import 'map_tab.dart';
import 'menu_tab.dart';
import 'progress_tab.dart';
import 'start_hunt_screen.dart';
import 'start_route_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dashboardNavKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    AppNav.selectedIndex.addListener(_rebuild);
    AppNav.mapBlocked.addListener(_onBlockChanged);
  }

  @override
  void dispose() {
    AppNav.selectedIndex.removeListener(_rebuild);
    AppNav.mapBlocked.removeListener(_onBlockChanged);
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void _onBlockChanged() {
    if (!mounted) return;

    // Wenn gesperrt -> immer Map Tab anzeigen.
    if (AppNav.mapBlocked.value) {
      AppNav.selectedIndex.value = 1;
    }
    setState(() {});
  }

  void _onTabTapped(int index) {
    // Wenn gesperrt: keine anderen Tabs erlauben
    if (AppNav.mapBlocked.value) {
      AppNav.selectedIndex.value = 1;
      return;
    }

    // Wenn man im Dashboard-Tab ist und nochmal Dashboard klickt -> zurück zur Startseite des Dashboard-Stacks.
    if (index == 0 && AppNav.selectedIndex.value == 0) {
      _dashboardNavKey.currentState?.popUntil((r) => r.isFirst);
    }
    AppNav.selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idx = AppNav.selectedIndex.value;

    return Scaffold(
      body: IndexedStack(
        index: idx,
        children: [
          Navigator(
            key: _dashboardNavKey,
            initialRoute: '/start-hunt',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/start-route':
                  return MaterialPageRoute(
                    builder: (_) => const StartRouteScreen(),
                    settings: settings,
                  );
                case '/start-hunt':
                default:
                  return MaterialPageRoute(
                    builder: (_) => const StartHuntScreen(),
                    settings: settings,
                  );
              }
            },
          ),

          // Map (aktiv nur wenn Tab ausgewählt)
          MapTab(isActive: idx == 1),

          // Progress
          const ProgressTab(),

          // Menu
          const MenuTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.onSurface,
        unselectedItemColor: scheme.onSurface.withOpacity(0.45),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.flag_outlined), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
