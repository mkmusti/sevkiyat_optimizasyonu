// lib/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import 'ana_sayfa.dart';
import 'login_ekrani.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    // --- YENİ KONTROL: Başlatma Durumunu Bekle ---
    if (userService.isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Oturum durumu kontrol ediliyor..."),
            ],
          ),
        ),
      );
    }
    // --------------------------------------------------

    // KULLANICI KONTROLÜ
    if (userService.currentUser != null) {
      return const AnaSayfa();
    } else {
      return const LoginEkrani();
    }
  }
}