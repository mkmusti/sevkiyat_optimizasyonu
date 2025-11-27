// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sevkiyat Optimizasyon';

  @override
  String welcomeMessage(Object userName) {
    return 'Hoş geldin, $userName';
  }

  @override
  String get dragToRotate => '3D yerleşimi döndürmek için sürükleyin';

  @override
  String get truckLayout3D => '3D Tır Yerleşimi';
}
