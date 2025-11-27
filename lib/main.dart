// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';
import 'services/koli_service.dart';
import 'services/arac_servisi.dart';
import 'theme/app_theme.dart';
import 'screens/splash_ekrani.dart';
import 'services/user_service.dart';
import 'services/ad_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- KRİTİK DÜZELTME: REKLAMLARI SADECE MOBİLDE BAŞLAT ---
  // (Android'de yayınlayacağımız için bu gereklidir)
  if (Platform.isAndroid || Platform.isIOS) {
    await MobileAds.instance.initialize();
  }
  // -------------------------------------------------------------

  // KRİTİK: Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Veritabanı Motoru Ataması (Windows/Linux için) ---
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // --- DÜZELTME BİTTİ ---

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => KoliServisi()),
        ChangeNotifierProvider(create: (context) => AracServisi()),
        ChangeNotifierProvider(create: (context) => UserService()),
        ChangeNotifierProvider(create: (context) => AdManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Depo Optimizasyon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashEkrani(),
    );
  }
}