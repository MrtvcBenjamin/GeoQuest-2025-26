// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GeoQuest';

  @override
  String get genericRetry => 'Retry';

  @override
  String get genericErrorTitle => 'Something went wrong';

  @override
  String get genericOffline => 'No internet connection';
}
