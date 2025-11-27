import 'dart:async'; // Timer için
import 'package:flutter/material.dart';
import 'auth_wrapper.dart';

class SplashEkrani extends StatefulWidget {
  const SplashEkrani({super.key});

  @override
  State<SplashEkrani> createState() => _SplashEkraniState();
}

class _SplashEkraniState extends State<SplashEkrani> {
  @override
  void initState() {
    super.initState();
    _baslataGit();
  }

  Future<void> _baslataGit() async {
    // 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerine erişim
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Arka planı temadan al
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Program İkonu (Yer Tutucu)
            // BURAYA KENDİ İKONUNUZU KOYUN (örn: Image.asset('assets/icon.png'))
            Icon(
              Icons.inventory_2, // Koli ikonu
              size: 100,
              color: theme.primaryColor, // Ana tema rengi
            ),
            const SizedBox(height: 24),

            // 2. Uygulama Adı
            Text(
              'Depo Optimizasyon', // main.dart'tan
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Kısa Açıklama
            Text(
              '3D Sevkiyat Planlama ve Koli Optimizasyonu',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),

            // 4. Copyright (Ekranın en altına sabitlenmiş)
            const Expanded(
              child: SizedBox(), // Araya boşluk koyar
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                children: [
                  Text(
                    'Mustafa KARAOSMAN © 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  Text(
                    'mkmusti@gmail.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
