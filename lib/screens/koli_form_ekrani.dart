// lib/screens/koli_form_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // YENİ: ID kontrolü için eklendi
import '../models/koli_model.dart';
import '../services/koli_service.dart'; // YENİ: ID kontrolü için eklendi

class KoliFormEkrani extends StatefulWidget {
  final KoliModel? duzenlenecekKoli;

  const KoliFormEkrani({super.key, this.duzenlenecekKoli});

  @override
  _KoliFormEkraniState createState() => _KoliFormEkraniState();
}

class _KoliFormEkraniState extends State<KoliFormEkrani> {
  final _formKey = GlobalKey<FormState>();

  // YENİ: ID için controller eklendi
  final _idController = TextEditingController();
  final _adController = TextEditingController();
  final _enController = TextEditingController();
  final _boyController = TextEditingController();
  final _yukseklikController = TextEditingController();
  final _agirlikController = TextEditingController();
  bool _duzenlemeModu = false;

  @override
  void initState() {
    super.initState();
    if (widget.duzenlenecekKoli != null) {
      _duzenlemeModu = true;
      final koli = widget.duzenlenecekKoli!;

      // YENİ: ID controller'ı doldur
      _idController.text = koli.id;

      _adController.text = koli.ad;
      _enController.text = koli.en.toString();
      _boyController.text = koli.boy.toString();
      _yukseklikController.text = koli.yukseklik.toString();
      _agirlikController.text = koli.agirlik.toString();
    }
  }

  @override
  void dispose() {
    // YENİ: ID controller'ı dispose et
    _idController.dispose();
    _adController.dispose();
    _enController.dispose();
    _boyController.dispose();
    _yukseklikController.dispose();
    _agirlikController.dispose();
    super.dispose();
  }

  void _kaydetVeCik() {
    if (_formKey.currentState!.validate()) {
      final KoliModel guncellenmisKoli = KoliModel(
        // YENİ: ID'yi DateTime yerine controller'dan al
        id: _idController.text,
        ad: _adController.text,
        en: double.tryParse(_enController.text) ?? 0.0,
        boy: double.tryParse(_boyController.text) ?? 0.0,
        yukseklik: double.tryParse(_yukseklikController.text) ?? 0.0,
        agirlik: double.tryParse(_agirlikController.text) ?? 0.0,
      );
      Navigator.of(context).pop(guncellenmisKoli);
    }
  }

  final _sayiFormatlayici =
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'));


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_duzenlemeModu ? 'Koli Düzenle' : 'Yeni Koli Ekle'),
        // backgroundColor: Colors.indigo, // KALDIRILDI -> Temadan alacak
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- YENİ: Koli ID Alanı ---
                _buildTextFormField(
                  controller: _idController,
                  label: 'Koli ID (Örn: KUTU-A, PALET-001)',
                  icon: Icons.qr_code_2,
                  readOnly: _duzenlemeModu, // Düzenleme modunda ID kilitli
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ID alanı boş bırakılamaz';
                    }
                    if (value.contains(' ')) {
                      return 'ID boşluk içeremez';
                    }
                    // Sadece YENİ koli eklerken ID'nin benzersizliğini kontrol et
                    if (!_duzenlemeModu) {
                      final koliServisi = Provider.of<KoliServisi>(context, listen: false);
                      // Koli servisinde bu ID'ye sahip bir koli var mı?
                      if (koliServisi.koliGetir(value) != null) {
                        return 'HATA: Bu ID zaten kullanılıyor!';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // --- Koli ID Alanı Bitti ---

                _buildTextFormField(
                  controller: _adController,
                  label: 'Koli Adı (Örn: Küçük Kutu)',
                  icon: Icons.label_important_outline,
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _enController,
                  label: 'En (cm)',
                  icon: Icons.swap_horiz,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _boyController,
                  label: 'Boy (cm) (Derinlik)',
                  icon: Icons.unfold_more,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _yukseklikController,
                  label: 'Yükseklik (cm)',
                  icon: Icons.height,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _agirlikController,
                  label: 'Ağırlık (kg)',
                  icon: Icons.scale_outlined,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _kaydetVeCik,
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.indigo, // KALDIRILDI
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Kaydet', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // YENİ: Validator ve ReadOnly parametreleri eklendi
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        // ID alanı readOnly ise biraz soluk göster
        fillColor: readOnly ? Theme.of(context).disabledColor.withOpacity(0.1) : null,
        filled: readOnly,
      ),
      keyboardType: keyboardType,
      inputFormatters: formatters,
      // Gelen validator'ı kullan veya varsayılanı kullan
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan boş bırakılamaz';
        }
        if (keyboardType.toString().contains('number')) {
          if (double.tryParse(value) == null || double.parse(value) <= 0) {
            return 'Lütfen 0\'dan büyük geçerli bir sayı girin';
          }
        }
        return null;
      },
    );
  }
}