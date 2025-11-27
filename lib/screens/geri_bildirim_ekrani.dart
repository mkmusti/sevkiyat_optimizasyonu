// lib/screens/geri_bildirim_ekrani.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GeriBildirimEkrani extends StatefulWidget {
  const GeriBildirimEkrani({super.key});

  @override
  State<GeriBildirimEkrani> createState() => _GeriBildirimEkraniState();
}

class _GeriBildirimEkraniState extends State<GeriBildirimEkrani> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  String _selectedCategory = 'Genel';

  final List<String> _categories = [
    'Genel',
    'Hata Bildirimi',
    'Özellik İsteği',
    'Performans Sorunu',
    'Kullanım Zorluğu',
    'Diğer',
  ];

  Future<void> _gonder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    const String toEmail = 'mkmusti@gmail.com';
    final String subject = 'Sevkiyat Optimizasyonu - $_selectedCategory';
    final String body = '''
Kategori: $_selectedCategory

Mesaj:
${_controller.text}

---
Bu mesaj Sevkiyat Optimizasyonu uygulamasından gönderilmiştir.
''';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email uygulamanız açıldı. Mesajınızı gönderin.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Formu temizle
          _controller.clear();
          setState(() {
            _selectedCategory = 'Genel';
          });
        }
      } else {
        throw Exception('Email uygulaması açılamadı.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: $e\n\nLütfen manuel olarak $toEmail adresine mail gönderin.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geri Bildirim Gönder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Açıklama Kartı
            Card(
              color: theme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.feedback,
                      size: 48,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Geri Bildiriminiz Bizim İçin Değerli!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Karşılaştığınız hataları, önerilerinizi veya düşüncelerinizi '
                          'bizimle paylaşın. Bu form, varsayılan email uygulamanızı açacaktır.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Kategori Seçimi
            Text(
              'Geri Bildirim Kategorisi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category_outlined),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _categories.map((category) {
                IconData icon;
                Color color;

                switch (category) {
                  case 'Hata Bildirimi':
                    icon = Icons.bug_report;
                    color = Colors.red;
                    break;
                  case 'Özellik İsteği':
                    icon = Icons.lightbulb_outline;
                    color = Colors.orange;
                    break;
                  case 'Performans Sorunu':
                    icon = Icons.speed;
                    color = Colors.blue;
                    break;
                  case 'Kullanım Zorluğu':
                    icon = Icons.help_outline;
                    color = Colors.purple;
                    break;
                  default:
                    icon = Icons.message;
                    color = Colors.green;
                }

                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // Mesaj Alanı
            Text(
              'Mesajınız',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _getHintText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 120),
                  child: Icon(Icons.edit_outlined),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 10,
              minLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir mesaj girin.';
                }
                if (value.trim().length < 10) {
                  return 'Mesaj en az 10 karakter olmalıdır.';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Gönder Butonu
            ElevatedButton.icon(
              onPressed: _isSending ? null : _gonder,
              icon: _isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'Gönderiliyor...' : 'Email İle Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Bilgi Notu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mesajınızı gönderdikten sonra email uygulamanızdan gönderim işlemini tamamlamanız gerekir. '
                          'En kısa sürede size geri dönüş yapacağız.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // İletişim Bilgileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_mail, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Diğer İletişim Yolları',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'mkmusti@gmail.com',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email ile doğrudan ulaşabilirsiniz. Genellikle 24 saat içinde yanıt veriyoruz.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedCategory) {
      case 'Hata Bildirimi':
        return 'Örnek: 3D görsel yüklenemiyor hatası alıyorum. Hesapla butonuna bastıktan sonra...';
      case 'Özellik İsteği':
        return 'Örnek: Uygulamaya Excel dosyasından toplu koli ekleme özelliği gelebilir mi?';
      case 'Performans Sorunu':
        return 'Örnek: Çok sayıda koli ekleyince uygulama yavaşlıyor...';
      case 'Kullanım Zorluğu':
        return 'Örnek: Araç ekleme ekranını anlamakta zorlanıyorum...';
      default:
        return 'Mesajınızı buraya yazın...';
    }
  }
}