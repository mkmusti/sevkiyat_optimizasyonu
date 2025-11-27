import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'theme_mode';

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  /// Tema modunu değiştir ve SharedPreferences'a kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode();
  }

  /// SharedPreferences'tan kayıtlı tema modunu yükler
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      print("ThemeMode Yükleme Hatası: $e");
    }
  }

  /// Tema modunu SharedPreferences'a kaydeder
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      print("ThemeMode Kaydetme Hatası: $e");
    }
  }

  /// Tema modunu değiştirmek için kolay metodlar
  void setLight() => setThemeMode(ThemeMode.light);
  void setDark() => setThemeMode(ThemeMode.dark);
  void setSystem() => setThemeMode(ThemeMode.system);

  /// Mevcut temanın açık mı koyu mu olduğunu kontrol etmek için
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}