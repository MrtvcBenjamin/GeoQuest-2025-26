// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'GeoQuest';

  @override
  String get genericRetry => 'Erneut versuchen';

  @override
  String get genericErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get genericOffline => 'Keine Internetverbindung';
}
