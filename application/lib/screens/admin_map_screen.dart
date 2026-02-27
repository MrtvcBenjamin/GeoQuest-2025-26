import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../auth/admin_access.dart';
import '../theme/app_text.dart';
import 'menu_tab.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final Map<String, _HuntStations> _huntStationsById = {};
  final Set<String> _loadingHunts = {};
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _ensureHuntStationsLoaded(String? huntId) async {
    if (huntId == null || huntId.isEmpty) return;
    if (_huntStationsById.containsKey(huntId) || _loadingHunts.contains(huntId)) {
      return;
    }

    _loadingHunts.add(huntId);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Hunts')
          .doc(huntId)
          .collection('Stadions')
          .orderBy('stadionIndex')
          .get();

      final orderedIds = <String>[];
      final titleById = <String, String>{};
      for (final doc in snap.docs) {
        orderedIds.add(doc.id);
        final title = (doc.data()['title'] as String?)?.trim();
        if (title != null && title.isNotEmpty) {
          titleById[doc.id] = title;
        }
      }

      if (!mounted) return;
      setState(() {
        _huntStationsById[huntId] = _HuntStations(
          orderedIds: orderedIds,
          titleById: titleById,
        );
      });
    } catch (_) {
      // keep screen running even if one hunt cannot be loaded
    } finally {
      _loadingHunts.remove(huntId);
    }
  }

  int _readCurrentStationIndex(
    Map<String, dynamic> locationData,
    Map<String, dynamic>? userData,
    String? huntId,
  ) {
    final fromLocation = (locationData['stadionIndex'] as num?)?.toInt();
    if (fromLocation != null) return fromLocation;

    if (userData == null || huntId == null || huntId.isEmpty) return 0;
    final byHunt = userData['CurrentStadionIndexByHunt'] as Map?;
    return (byHunt?[huntId] as num?)?.toInt() ?? 0;
  }

  List<String> _readUserStationOrder(Map<String, dynamic>? userData, String? huntId) {
    if (userData == null || huntId == null || huntId.isEmpty) return const [];
    final byHunt = userData['StationOrderByHunt'] as Map?;
    final raw = byHunt?[huntId] as List?;
    if (raw == null) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  String _resolveNextStationName({
    required int currentIndex,
    required List<String> userOrder,
    required _HuntStations? hunt,
  }) {
    if (userOrder.isNotEmpty) {
      final idx = currentIndex.clamp(0, userOrder.length - 1);
      final stationId = userOrder[idx];
      final title = hunt?.titleById[stationId];
      if (title != null && title.isNotEmpty) return title;
      return '${tr('Station', 'Station')} ${idx + 1}';
    }

    if (hunt == null || hunt.orderedIds.isEmpty) {
      return tr('Unbekannt', 'Unknown');
    }
    final idx = currentIndex.clamp(0, hunt.orderedIds.length - 1);
    final stationId = hunt.orderedIds[idx];
    final title = hunt.titleById[stationId];
    if (title != null && title.isNotEmpty) return title;
    return '${tr('Station', 'Station')} ${idx + 1}';
  }

  void _openUserDetails(_TrackedUser user) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              if (user.email != null && user.email!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  user.email!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _detailLine(
                tr('Anzahl Stationen', 'Number of stations'),
                user.stationCount.toString(),
              ),
              _detailLine(
                tr('Nächste Station', 'Next station'),
                user.nextStationName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 165,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_selectedIndex == 1) {
      return Scaffold(
        body: const MenuTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: scheme.onSurface,
          unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on_outlined),
              label: tr('Karte', 'Map'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu),
              label: tr('Menü', 'Menu'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('Admin Karte', 'Admin map'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildMapBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.onSurface,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.45),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            label: tr('Karte', 'Map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu),
            label: tr('Menü', 'Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBody() {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, usersSnapshot) {
        if (usersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (usersSnapshot.hasError) {
          return Center(
            child: Text(
              tr('Benutzer konnten nicht geladen werden.',
                  'Users could not be loaded.'),
            ),
          );
        }

        final userByUid = <String, Map<String, dynamic>>{
          for (final d in (usersSnapshot.data?.docs ?? const [])) d.id: d.data(),
        };

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance.collection('PlayerLocation').snapshots(),
          builder: (context, locationSnapshot) {
            if (locationSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (locationSnapshot.hasError) {
              return Center(
                child: Text(
                  tr('Standorte konnten nicht geladen werden.',
                      'Locations could not be loaded.'),
                ),
              );
            }

            final trackedUsers = <_TrackedUser>[];
            final locationDocs = locationSnapshot.data?.docs ?? const [];
            for (final doc in locationDocs) {
              final locationData = doc.data();
              final geo = locationData['location'];
              if (geo is! GeoPoint) continue;

              final uid = doc.id;
              final userData = userByUid[uid];
              final email = (userData?['Email'] as String?)?.trim().toLowerCase();
              if (AdminAccess.isAdminEmail(email)) continue;

              final huntId = (locationData['huntId'] as String?)?.trim();
              _ensureHuntStationsLoaded(huntId);
              final hunt = huntId == null ? null : _huntStationsById[huntId];

              final currentIndex =
                  _readCurrentStationIndex(locationData, userData, huntId);
              final stationOrder = _readUserStationOrder(userData, huntId);
              final stationCount = stationOrder.isNotEmpty
                  ? stationOrder.length
                  : (hunt?.orderedIds.length ?? 0);
              final nextStationName = _resolveNextStationName(
                currentIndex: currentIndex,
                userOrder: stationOrder,
                hunt: hunt,
              );

              final username = (userData?['Username'] as String?)?.trim();
              final fallbackName =
                  (email != null && email.contains('@')) ? email.split('@').first : uid;

              trackedUsers.add(
                _TrackedUser(
                  uid: uid,
                  name: (username == null || username.isEmpty)
                      ? fallbackName
                      : username,
                  email: email,
                  position: LatLng(geo.latitude, geo.longitude),
                  stationCount: stationCount,
                  nextStationName: nextStationName,
                ),
              );
            }

            if (trackedUsers.isEmpty) {
              return Center(
                child: Text(
                  tr('Keine aktiven Spieler mit Standort gefunden.',
                      'No active players with location found.'),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final visibleUsers = trackedUsers.where(_matchesSearch).toList();
            final center = trackedUsers.first.position;

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.geoquest',
                    ),
                    MarkerLayer(
                      markers: visibleUsers
                          .map(
                            (user) => Marker(
                              point: user.position,
                              width: 46,
                              height: 46,
                              child: GestureDetector(
                                onTap: () => _openUserDetails(user),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scheme.onPrimary,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    user.name.isEmpty
                                        ? '?'
                                        : user.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: _searchPanel(visibleUsers),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _matchesSearch(_TrackedUser user) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    final name = user.name.toLowerCase();
    final email = (user.email ?? '').toLowerCase();
    return name.contains(q) || email.contains(q);
  }

  Widget _searchPanel(List<_TrackedUser> visibleUsers) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              isDense: true,
              hintText: tr('Spieler suchen...', 'Search players...'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.trim().isNotEmpty && visibleUsers.isEmpty)
            Text(
              tr('Kein Spieler gefunden.', 'No player found.'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          if (visibleUsers.isNotEmpty)
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleUsers.length.clamp(0, 8),
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final user = visibleUsers[i];
                  return ActionChip(
                    label: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _focusUser(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _focusUser(_TrackedUser user) {
    _mapController.move(user.position, 17);
    _openUserDetails(user);
  }
}

class _HuntStations {
  final List<String> orderedIds;
  final Map<String, String> titleById;

  const _HuntStations({
    required this.orderedIds,
    required this.titleById,
  });
}

class _TrackedUser {
  final String uid;
  final String name;
  final String? email;
  final LatLng position;
  final int stationCount;
  final String nextStationName;

  const _TrackedUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.position,
    required this.stationCount,
    required this.nextStationName,
  });
}
