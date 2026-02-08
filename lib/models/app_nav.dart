import 'package:flutter/foundation.dart';

class AppNav {
  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  /// Wenn true, soll der User im Map-Tab "gefangen" sein (Sperre).
  static final ValueNotifier<bool> mapBlocked = ValueNotifier<bool>(false);
}
