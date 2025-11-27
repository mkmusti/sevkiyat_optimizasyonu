// lib/screens/ayarlar_ekrani.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/user_service.dart';
import '../services/database_helper.dart';

class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userService = Provider.of<UserService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Kullanıcı Bilgileri Kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.primaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kullanıcı Bilgileri',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userService.currentUserEmail ?? 'Giriş yapılmamış',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hesap Durumu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                userService.isPremium ? Icons.star : Icons.person_outline,
                                size: 16,
                                color: userService.isPremium ? Colors.amber : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userService.isPremium ? 'PREMIUM' : 'Ücretsiz',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: userService.isPremium ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Kalan API Hakkı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userService.isPremium
                                ? '∞ Sınırsız'
                                : '${userService.kalanHak}/${UserService.AYLIK_FREE_LIMIT}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tema Ayarları
          Text(
            "Görünüm Ayarları",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('☀️ Aydınlık Mod'),
                  subtitle: const Text('Her zaman açık tema'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.wb_sunny, color: Colors.orange),
                  ),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('🌙 Karanlık Mod'),
                  subtitle: const Text('Her zaman koyu tema'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.dark_mode, color: Colors.indigo),
                  ),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('🔄 Sistem Varsayılanı'),
                  subtitle: const Text('Cihazınızın ayarlarını kullan'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_android, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Veri Yönetimi
          Text(
            "Veri Yönetimi",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storage, color: Colors.blue),
                  ),
                  title: const Text('Veritabanı Konumu'),
                  subtitle: const Text('Yerel cihaz (SQLite)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showDatabaseInfo(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  title: const Text(
                    'Tüm Verileri Sil',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('Koli ve araç tanımları silinir'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () {
                    _confirmDeleteAllData(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hakkında
          Text(
            "Uygulama",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.privacy_tip, color: Colors.purple),
                  ),
                  title: const Text('Gizlilik Politikası'),
                  subtitle: const Text('Verilerinizi nasıl koruyoruz'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showPrivacyPolicy(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description, color: Colors.green),
                  ),
                  title: const Text('Kullanım Şartları'),
                  subtitle: const Text('Hizmet şartlarımız'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showTermsOfService(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDatabaseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veritabanı Bilgileri'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📍 Konum:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Tüm koli ve araç tanımlarınız cihazınızda SQLite veritabanında saklanır.'),
              SizedBox(height: 16),
              Text('🔒 Güvenlik:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Verileriniz yalnızca sizin cihazınızdadır ve başka kimse erişemez.'),
              SizedBox(height: 16),
              Text('☁️ Firebase:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Sadece kullanıcı bilgileriniz (email, API hakkı) Firebase\'de saklanır.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Dikkat!'),
        content: const Text(
          'Tüm koli ve araç tanımlarınız kalıcı olarak silinecek. '
              'Bu işlem geri alınamaz!\n\n'
              'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData(BuildContext context) async {
    try {
      // Tüm kolileri ve araçları sil
      final db = await DatabaseHelper.instance.database;
      await db.delete('koliler');
      await db.delete('araclar');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tüm veriler başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: const SingleChildScrollView(
          child: Text(
            'Bu uygulama, koli ve araç tanımlarınızı yalnızca cihazınızda saklar. '
                'Hiçbir veri üçüncü şahıslarla paylaşılmaz.\n\n'
                'Firebase Authentication kullanılarak güvenli giriş sağlanır. '
                'Email adresiniz ve API kullanım bilgileriniz Firebase\'de saklanır.\n\n'
                'API çağrıları Google Cloud Run üzerinden yapılır ve sonuçlar '
                'geçici olarak Google Cloud Storage\'da tutulur.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanım Şartları'),
        content: const SingleChildScrollView(
          child: Text(
            'Bu uygulama, sevkiyat optimizasyonu için bir araçtır. '
                'Ücretsiz kullanıcılar ayda 30 API çağrısı yapabilir.\n\n'
                'Uygulama "olduğu gibi" sunulur ve hiçbir garanti verilmez. '
                'Optimizasyon sonuçları tavsiye niteliğindedir.\n\n'
                'Kötüye kullanım tespit edilirse hesabınız askıya alınabilir.\n\n'
                'Sorularınız için: mkmusti@gmail.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}