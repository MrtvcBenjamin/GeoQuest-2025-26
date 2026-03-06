import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StationCacheService {
  static String _key(String huntId) => 'stations_cache_$huntId';

  static Future<void> save(
    String huntId,
    List<Map<String, dynamic>> stations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final normalized = stations.map(_normalizeStation).toList();
      await prefs.setString(_key(huntId), jsonEncode(normalized));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> load(String huntId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(huntId));
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final stations = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = <String, dynamic>{};
        item.forEach((key, value) {
          map[key.toString()] = value;
        });
        stations.add(_restoreStation(map));
      }
      return stations;
    } catch (_) {
      return const [];
    }
  }

  static Map<String, dynamic> _normalizeStation(Map<String, dynamic> station) {
    final out = <String, dynamic>{};
    station.forEach((key, value) {
      if (value is GeoPoint) {
        out[key] = {
          '_geo': true,
          'lat': value.latitude,
          'lng': value.longitude,
        };
      } else {
        out[key] = value;
      }
    });
    return out;
  }

  static Map<String, dynamic> _restoreStation(Map<String, dynamic> station) {
    final out = <String, dynamic>{};
    station.forEach((key, value) {
      if (value is Map && value['_geo'] == true) {
        final lat = (value['lat'] as num?)?.toDouble();
        final lng = (value['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          out[key] = GeoPoint(lat, lng);
          return;
        }
      }
      out[key] = value;
    });
    return out;
  }
}

