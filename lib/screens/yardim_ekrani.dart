// lib/screens/yardim_ekrani.dart
import 'package:flutter/material.dart';

class YardimEkrani extends StatelessWidget {
  const YardimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve SSS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Başlık
          Text(
            'Sıkça Sorulan Sorular',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uygulamayı daha iyi kullanmanız için hazırladığımız kılavuz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // GENEL KULLANIM
          _buildSectionHeader(context, '📱 Genel Kullanım'),
          const ExpansionTile(
            leading: Icon(Icons.question_answer_outlined, color: Colors.blue),
            title: Text('Uygulamaya nasıl giriş yapabilirim?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Uygulama açıldığında email ve şifrenizle giriş yapabilirsiniz. '
                      'Hesabınız yoksa "Hesap Oluştur" butonuna tıklayarak yeni bir hesap açabilirsiniz. '
                      'Her yeni kullanıcıya aylık 30 ücretsiz API hakkı verilir.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.inventory_2_outlined, color: Colors.green),
            title: Text('Koli ve araç nasıl tanımlanır?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sol menüden "Koli Tanımları" veya "Araç Tanımları" seçeneğine tıklayın. '
                      'Sağ alttaki (+) butonuna basarak yeni tanım ekleyebilirsiniz. '
                      'Her tanım için benzersiz bir ID girmeniz gerekir (örn: KUTU-A, TIR-01).',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.calculate_outlined, color: Colors.orange),
            title: Text('Sevkiyat planlaması nasıl yapılır?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ana ekranda koli listesinden göndermek istediğiniz kolilerin adetlerini girin. '
                      'İsterseniz "3D Görselleştirme" seçeneğini açabilirsiniz (API hakkı gerektirir). '
                      'Hesapla butonuna bastığınızda optimizasyon başlar ve sonuçlar görüntülenir.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3D GÖRSELLEŞTİRME
          _buildSectionHeader(context, '🎨 3D Görselleştirme'),
          const ExpansionTile(
            leading: Icon(Icons.threed_rotation, color: Colors.purple),
            title: Text('3D görsel nedir ve nasıl kullanılır?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '3D görselleştirme, kolilerinizin araca nasıl yerleştirildiğini interaktif '
                      'olarak gösterir. Fare ile döndürebilir, zoom yapabilirsiniz. '
                      'Bu özellik API hakkı kullanır ve sunucu tarafında oluşturulur.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.error_outline, color: Colors.red),
            title: Text('"3D Görsel Yüklenemedi" hatası alıyorum'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bu hata genellikle şu nedenlerle oluşur:\n\n'
                      '• Sunucu görseli henüz oluşturmadı (10-15 saniye bekleyin)\n'
                      '• İnternet bağlantısı sorunu var\n'
                      '• API sunucusu meşgul\n\n'
                      'Çözüm: "Tekrar Dene" butonuna basın. Sorun devam ederse geri bildirim gönderin.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // API VE HAKLAR
          _buildSectionHeader(context, '🎯 API ve Kullanım Hakları'),
          const ExpansionTile(
            leading: Icon(Icons.api, color: Colors.teal),
            title: Text('API hakkı nedir ve nasıl kullanılır?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ücretsiz kullanıcılar ayda 30 API çağrısı yapabilir. '
                      'Her 3D optimizasyon veya batch hesaplama 1 hak kullanır. '
                      'Yerel FFD algoritması (hızlı mod) hak kullanmaz. '
                      'Haklar her ayın 1\'inde sıfırlanır.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.cloud_off_outlined, color: Colors.red),
            title: Text('API "500 Sunucu Hatası" veriyor'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sunucu tarafında bir sorun oluşmuş demektir. Bu durumda:\n\n'
                      '• Birkaç dakika bekleyip tekrar deneyin\n'
                      '• Yerel FFD algoritmasını kullanın (API hakkı gerektirmez)\n'
                      '• Sorun devam ederse "Geri Bildirim" ekranından bildirin\n\n'
                      'Sunucu genellikle 5 dakika içinde düzelir.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // VERİTABANI
          _buildSectionHeader(context, '💾 Veri Yönetimi'),
          const ExpansionTile(
            leading: Icon(Icons.storage, color: Colors.indigo),
            title: Text('Verilerim nerede saklanıyor?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Koli ve araç tanımlarınız cihazınızda SQLite veritabanında saklanır. '
                      'Bu veriler yalnızca sizin cihazınızdadır ve başka kimse erişemez. '
                      'Kullanıcı bilgileriniz (email, API hakkı) ise Firebase\'de güvenle saklanır.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.qr_code_2, color: Colors.brown),
            title: Text('Neden benzersiz ID girmem gerekiyor?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Veritabanında her kayıt benzersiz bir kimlik (ID) ile tanımlanır. '
                      'Bu sayede kolilerinizi düzenleyebilir veya silebilirsiniz. '
                      'ID boşluk içermemeli ve her tanım için farklı olmalıdır.\n\n'
                      'Örnekler: KUTU-A, TIR-01, PALET-BUYUK',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // TEMA VE AYARLAR
          _buildSectionHeader(context, '🎨 Tema ve Ayarlar'),
          const ExpansionTile(
            leading: Icon(Icons.dark_mode_outlined, color: Colors.blueGrey),
            title: Text('Karanlık modu nasıl aktif ederim?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sol menüden "Ayarlar" seçeneğine tıklayın. '
                      '"Karanlık Mod" seçeneğini işaretleyin. '
                      'Tema tercihiniz otomatik olarak kaydedilir ve bir sonraki açılışta uygulanır.',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DESTEK
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daha Fazla Yardıma mı İhtiyacınız Var?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sorunuz yanıtlanmadıysa "Geri Bildirim" ekranından bize ulaşın. '
                        'En kısa sürede size yardımcı olacağız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/geri-bildirim');
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Geri Bildirim Gönder'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}