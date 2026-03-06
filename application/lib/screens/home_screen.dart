import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_nav.dart';
import '../theme/app_text.dart';
import '../theme/app_ui.dart';
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
  static const String _legacyHuntId = 'xISAk6mXjjEpDUHYyxZi';

  late final Future<String?> _huntIdFuture = _resolveHuntId();

  @override
  void initState() {
    super.initState();
    AppNav.mapBlocked.addListener(_onBlockChanged);
  }

  @override
  void dispose() {
    AppNav.mapBlocked.removeListener(_onBlockChanged);
    super.dispose();
  }

  void _onBlockChanged() {
    if (AppNav.mapBlocked.value) {
      AppNav.selectedIndex.value = 1;
    }
  }

  void _onTabTapped(int index) {
    if (AppNav.mapBlocked.value) {
      AppNav.selectedIndex.value = 1;
      return;
    }

    if (index == 0 && AppNav.selectedIndex.value == 0) {
      _dashboardNavKey.currentState?.popUntil((r) => r.isFirst);
    }
    AppNav.selectedIndex.value = index;
  }

  Future<String?> _resolveHuntId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final userSnap =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      final data = userSnap.data() ?? const <String, dynamic>{};
      final fromUser = (data['ActiveHuntId'] ??
              data['CurrentHuntId'] ??
              data['huntId'] ??
              data['HuntId'])
          ?.toString()
          .trim();
      if (fromUser != null && fromUser.isNotEmpty) return fromUser;
    } catch (_) {}

    try {
      final locSnap = await FirebaseFirestore.instance
          .collection('PlayerLocation')
          .doc(uid)
          .get();
      final fromLoc = locSnap.data()?['huntId']?.toString().trim();
      if (fromLoc != null && fromLoc.isNotEmpty) return fromLoc;
    } catch (_) {}

    try {
      final legacyStations = await FirebaseFirestore.instance
          .collection('Hunts')
          .doc(_legacyHuntId)
          .collection('Stadions')
          .limit(1)
          .get();
      if (legacyStations.docs.isNotEmpty) return _legacyHuntId;
    } catch (_) {}

    try {
      final hunts = await FirebaseFirestore.instance.collection('Hunts').get();
      for (final hunt in hunts.docs) {
        final stations = await hunt.reference.collection('Stadions').limit(1).get();
        if (stations.docs.isNotEmpty) return hunt.id;
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dashboardLabel = tr('Dashboard', 'Dashboard');
    final mapLabel = tr('Karte', 'Map');
    final progressLabel = tr('Fortschritt', 'Progress');
    final menuLabel = tr('Menü', 'Menu');

    return FutureBuilder<String?>(
      future: _huntIdFuture,
      builder: (context, huntSnap) {
        if (huntSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoadingState());
        }

        final huntId = huntSnap.data;
        if (huntId == null || huntId.isEmpty) {
          return Scaffold(
            body: AppMessageCard(
              title: tr('Keine Hunt gefunden', 'No hunt found'),
              body: tr(
                'Für dein Konto wurde keine Hunt mit Stationen gefunden.',
                'No hunt with stations was found for your account.',
              ),
            ),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: AppNav.selectedIndex,
          builder: (context, idx, _) => Scaffold(
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
                          builder: (_) => StartRouteScreen(huntId: huntId),
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
                MapTab(
                  isActive: idx == 1,
                  huntId: huntId,
                ),
                const ProgressTab(),
                const MenuTab(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: idx,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: scheme.onSurface,
              unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home_filled), label: dashboardLabel),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.location_on_outlined), label: mapLabel),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.flag_outlined), label: progressLabel),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.menu), label: menuLabel),
              ],
            ),
          ),
        );
      },
    );
  }
}
