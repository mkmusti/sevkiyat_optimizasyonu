// lib/screens/hakkinda_ekrani.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HakkindaEkrani extends StatefulWidget {
  const HakkindaEkrani({super.key});

  @override
  State<HakkindaEkrani> createState() => _HakkindaEkraniState();
}

class _HakkindaEkraniState extends State<HakkindaEkrani> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında ve Özellikler'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Icon(
              Icons.inventory_2,
              size: 80,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Depo Optimizasyon',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Versiyon: $_version',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Ana Özellikler',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const _OzellikListTile(
            icon: Icons.threed_rotation,
            title: '3D Yerleşim Görselleştirmesi',
            subtitle: 'API ile hesaplanan koli yerleşimlerini interaktif 3D modelde görün.',
          ),
          const _OzellikListTile(
            icon: Icons.storage,
            title: 'Kalıcı Veritabanı',
            subtitle: 'SQLite kullanarak koli ve araç tanımlarınızı cihazınızda kalıcı olarak saklayın.',
          ),
          const _OzellikListTile(
            icon: Icons.cloud_queue,
            title: 'Cloud Run API Entegrasyonu',
            subtitle: 'Ağır hesaplamalar için Google Cloud platformuna bağlanan "Stateless" GCS mimarisi.',
          ),
          const _OzellikListTile(
            icon: Icons.dark_mode_outlined,
            title: 'Açık/Koyu Tema Desteği',
            subtitle: 'Uygulamayı sistem ayarlarınıza veya tercihinize göre açık ya da koyu modda kullanın.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Sizin copyright bilginiz
          Center(
            child: Text(
              'Mustafa KARAOSMAN © 2025\nmkmusti@gmail.com',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _OzellikListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OzellikListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}