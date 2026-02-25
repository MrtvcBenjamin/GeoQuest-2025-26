import 'package:flutter/foundation.dart';

class AppNav {
  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  /// Wenn true, soll der User im Map-Tab "gefangen" sein (Sperre).
  static final ValueNotifier<bool> mapBlocked = ValueNotifier<bool>(false);

  /// True, wenn die nächste Aufgabe aktiv gespielt wird.
  /// False bedeutet: Map zeigt nur den eigenen Standort.
  static final ValueNotifier<bool> stationActive = ValueNotifier<bool>(false);
}
