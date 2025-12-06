// lib/screens/ayarlar_ekrani.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/user_service.dart';
import '../services/database_helper.dart';
import '../services/in_app_purchase_service.dart'; // ⬅️ YENİ EKLENDİ
import 'package:in_app_purchase/in_app_purchase.dart'; // ⬅️ YENİ EKLENDİ

class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  // ⬅️ YENİ METOT: Premium satın alma butonu tıklandığında çalışır
  void _startPurchase(BuildContext context) {
    final iapService = Provider.of<InAppPurchaseService>(context, listen: false);

    if (!iapService.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Uygulama içi satın alma hizmeti kullanılamıyor.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (iapService.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Ürünler yükleniyor, lütfen bekleyin...'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      iapService.loadProducts();
      return;
    }

    // Satın alma akışını başlat (İlk ürünü varsayıyoruz)
    final product = iapService.products.first;
    iapService.buySubscription(product);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userService = Provider.of<UserService>(context);
    final theme = Theme.of(context);

    // ⬅️ YENİ EKLENDİ: IAP Servisi
    final iapService = Provider.of<InAppPurchaseService>(context);

    // Kapatmadan önce Context'i set et (IAP servisi için kritik)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iapService.setContext(context);
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Kullanıcı Bilgileri Kartı (Mevcut)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Kullanıcı avatar ve email kısmı aynı) ...
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.primaryColor,
                        child: const Icon(Icons.person, size: 30, color: Colors.white),
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
                          Text('Hesap Durumu', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                          Text('Kalan API Hakkı', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Text(
                            userService.isPremium
                                ? '∞ Sınırsız'
                                : '${userService.kalanHak}/${UserService.AYLIK_FREE_LIMIT}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ⬅️ YENİ EKLENDİ: PREMIUM SATIN ALMA KARTI
          if (!userService.isPremium)
            Card(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              child: ListTile(
                leading: iapService.purchasePending
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.workspace_premium, color: Colors.indigo),
                title: Text(
                  iapService.purchasePending ? 'Satın Alma Onaylanıyor...' : 'Premium Abonelik Al',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  iapService.products.isNotEmpty
                      ? 'Aylık ${iapService.products.first.price}' // Ürün fiyatını göster
                      : 'Sınırsız hak ve reklamsız deneyim.',
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: iapService.purchasePending ? null : () => _startPurchase(context),
              ),
            ),
          // ----------------------------------------------------

          const SizedBox(height: 24),

          // ... (Tema Ayarları, Veri Yönetimi ve Uygulama kısımları aynı kalır)

          // Tema Ayarları
          Text(
            "Görünüm Ayarları",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ... (Tema RadioListTile'lar aynı) ...

          // Veri Yönetimi
          const SizedBox(height: 24),
          Text(
            "Veri Yönetimi",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ... (Veritabanı Konumu ve Tüm Verileri Sil kısımları aynı) ...

          // Hakkında
          const SizedBox(height: 24),
          Text(
            "Uygulama",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ... (Gizlilik Politikası ve Kullanım Şartları kısımları aynı) ...

        ],
      ),
    );
  }

  // --- (Kullanılan diğer metotlar: _showDatabaseInfo, _confirmDeleteAllData, _deleteAllData, _showPrivacyPolicy, _showTermsOfService aynı kalır) ---

  // (Uzunluk nedeniyle eski metotların içeriğini buraya dahil etmiyorum, mevcut dosyanızdaki içeriği kullanın.)

  // (Ancak _showDatabaseInfo metodu ve diğer pop-up metotları burada bitiyor olmalı.)

  // ... (Geri kalan metotlar: _showDatabaseInfo, _confirmDeleteAllData, _deleteAllData, _showPrivacyPolicy, _showTermsOfService) ...

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