import 'package:flutter/material.dart';

/// Frontend-only Game State (Backend ersetzt später).
class GameState {
  static final ValueNotifier<bool> huntStarted = ValueNotifier<bool>(false);

  // Demo / Placeholder für UI (später aus Firestore).
  static final ValueNotifier<String> nextStationName = ValueNotifier<String>('Station 1');
  static final ValueNotifier<int> nextStationDistanceMeters = ValueNotifier<int>(250);
  static final ValueNotifier<int> nextStationPoints = ValueNotifier<int>(10);
  static final ValueNotifier<Duration> remainingTime = ValueNotifier<Duration>(const Duration(minutes: 15));

  static void startHunt() {
    huntStarted.value = true;
  }
}
