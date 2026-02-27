import 'app_settings.dart';

String tr(String de, String en) {
  return AppSettings.language.value == AppLanguage.de ? de : en;
}
