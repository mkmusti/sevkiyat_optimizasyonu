// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shipment Optimization';

  @override
  String welcomeMessage(Object userName) {
    return 'Welcome, $userName';
  }

  @override
  String get dragToRotate => 'Drag to rotate the 3D layout';

  @override
  String get truckLayout3D => '3D Truck Layout';
}
