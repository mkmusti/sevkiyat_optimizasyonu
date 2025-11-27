// lib/screens/arac_form_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // YENİ: ID kontrolü için eklendi
import '../models/arac_model.dart';
import '../services/arac_servisi.dart'; // YENİ: ID kontrolü için eklendi

class AracFormEkrani extends StatefulWidget {
  final AracModel? duzenlenecekArac;

  const AracFormEkrani({super.key, this.duzenlenecekArac});

  @override
  _AracFormEkraniState createState() => _AracFormEkraniState();
}

class _AracFormEkraniState extends State<AracFormEkrani> {
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
    if (widget.duzenlenecekArac != null) {
      _duzenlemeModu = true;
      final arac = widget.duzenlenecekArac!;

      // YENİ: ID controller'ı doldur
      _idController.text = arac.id;

      _adController.text = arac.ad;
      _enController.text = arac.yuklenebilirEn.toString();
      _boyController.text = arac.yuklenebilirBoy.toString();
      _yukseklikController.text = arac.yuklenebilirYukseklik.toString();
      _agirlikController.text = arac.maksKapasiteAgirlik.toString();
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
      final AracModel guncellenmisArac = AracModel(
        // YENİ: ID'yi DateTime yerine controller'dan al
        id: _idController.text,
        ad: _adController.text,
        yuklenebilirEn: double.tryParse(_enController.text) ?? 0.0,
        yuklenebilirBoy: double.tryParse(_boyController.text) ?? 0.0,
        yuklenebilirYukseklik:
        double.tryParse(_yukseklikController.text) ?? 0.0,
        maksKapasiteAgirlik: double.tryParse(_agirlikController.text) ?? 0.0,
      );
      Navigator.of(context).pop(guncellenmisArac);
    }
  }

  final _sayiFormatlayici =
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_duzenlemeModu ? 'Araç Düzenle' : 'Yeni Araç Ekle'),
        // backgroundColor: Colors.indigo, // KALDIRILDI -> Temadan alacak
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- YENİ: Araç ID Alanı ---
                _buildTextFormField(
                  controller: _idController,
                  label: 'Araç ID (Örn: TIR-01, KAMYON-A)',
                  icon: Icons.qr_code_2,
                  readOnly: _duzenlemeModu, // Düzenleme modunda ID kilitli
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ID alanı boş bırakılamaz';
                    }
                    if (value.contains(' ')) {
                      return 'ID boşluk içeremez';
                    }
                    // Sadece YENİ araç eklerken ID'nin benzersizliğini kontrol et
                    if (!_duzenlemeModu) {
                      final aracServisi = Provider.of<AracServisi>(context, listen: false);
                      // Araç servisinde bu ID'ye sahip bir araç var mı?
                      if (aracServisi.aracGetir(value) != null) {
                        return 'HATA: Bu ID zaten kullanılıyor!';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // --- Araç ID Alanı Bitti ---

                _buildTextFormField(
                  controller: _adController,
                  label: 'Araç Adı (Örn: Standart Tır)',
                  icon: Icons.label_important_outline,
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _enController,
                  label: 'Yüklenebilir En (cm)',
                  icon: Icons.swap_horiz,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _boyController,
                  label: 'Yüklenebilir Boy (cm) (Derinlik)', // Açıklama eklendi
                  icon: Icons.unfold_more,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _yukseklikController,
                  label: 'Yüklenebilir Yükseklik (cm)',
                  icon: Icons.height,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  formatters: [_sayiFormatlayici],
                ),
                const SizedBox(height: 10),
                _buildTextFormField(
                  controller: _agirlikController,
                  label: 'Maks. Ağırlık Kapasitesi (kg)',
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