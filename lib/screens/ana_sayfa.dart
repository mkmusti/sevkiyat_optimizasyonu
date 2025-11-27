// lib/screens/ana_sayfa.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sevkiyat_planlama_ekrani.dart';
import 'arac_tanim_ekrani.dart';
import 'koli_tanim_ekrani.dart';
import '../services/user_service.dart';
import 'ayarlar_ekrani.dart';
import 'hakkinda_ekrani.dart';
import 'yardim_ekrani.dart';
import 'geri_bildirim_ekrani.dart';

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});

  // Drawer menü elemanlarını oluşturur
  Widget _buildDrawerItem(BuildContext context, {required String title, required IconData icon, required Widget screen}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Drawer'ı kapat
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // UserService'i dinle ve kullanıcı durumunu al
    final userService = Provider.of<UserService>(context);
    final bool isLoggedIn = userService.isLoggedIn;

    // Kullanıcının durumuna göre gösterilecek modlar (sekmeler)
    final List<Tab> tabs = [
      const Tab(text: 'Yerel Mod (FFD)'), // Her zaman gösterilir
      if (isLoggedIn) const Tab(text: 'API Modu (3D/Batch)'), // Sadece giriş yapılmışsa gösterilir
    ];

    // Kullanıcının durumuna göre gösterilecek ekranlar (sekme içerikleri)
    final List<Widget> tabViews = [
      const SevkiyatPlanlamaEkrani(secilenAlgoritma: 'ffd'), // Yerel FFD algoritması
      if (isLoggedIn) const SevkiyatPlanlamaEkrani(secilenAlgoritma: 'batch'), // Gelişmiş API optimizasyonu
    ];

    // DefaultTabController, sekme yapısını yönetmek için kullanılır.
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sevkiyat Optimizasyonu'),
          // TabBar'ı AppBar'ın altına yerleştir
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menü',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLoggedIn ? 'Hoş geldiniz, ${userService.currentUser?.email ?? 'Kullanıcı'}' : 'Giriş Yapılmadı',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(context, title: 'Araç Tanımlama', icon: Icons.local_shipping, screen: const AracTanimEkrani()),
              _buildDrawerItem(context, title: 'Koli Tanımlama', icon: Icons.inventory, screen: const KoliTanimEkrani()),
              const Divider(),
              _buildDrawerItem(context, title: 'Ayarlar', icon: Icons.settings, screen: const AyarlarEkrani()),
              _buildDrawerItem(context, title: 'Geri Bildirim', icon: Icons.feedback, screen: const GeriBildirimEkrani()),
              _buildDrawerItem(context, title: 'Yardım', icon: Icons.help, screen: const YardimEkrani()),
              _buildDrawerItem(context, title: 'Hakkında', icon: Icons.info, screen: const HakkindaEkrani()),

              // Oturum Açma/Kapatma butonu
              ListTile(
                leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
                title: Text(isLoggedIn ? 'Çıkış Yap' : 'Giriş Yap'),
                onTap: () {
                  Navigator.pop(context); // Drawer'ı kapat
                  if (isLoggedIn) {
                    userService.signOut();
                  } else {
                    // Oturum açma ekranına gitmek için adlandırılmış rotayı kullan
                    Navigator.pushNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
        // TabBarView, seçilen sekmeye ait ekranı gösterir
        body: TabBarView(
          children: tabViews,
        ),
      ),
    );
  }
}