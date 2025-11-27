// lib/screens/sevkiyat_planlama_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/arac_servisi.dart';
import '../services/koli_service.dart';
import '../models/koli_model.dart';
import '../models/sevkiyat_kalemi_model.dart';
import '../models/sevkiyat_sonuc_model.dart';
import '../services/optimizasyon_servisi.dart';
import '../services/user_service.dart';
import '../widgets/banner_reklam_widget.dart';
import 'sonuc_ekrani.dart';

class SevkiyatPlanlamaEkrani extends StatefulWidget {
  final String secilenAlgoritma;

  const SevkiyatPlanlamaEkrani({
    Key? key,
    required this.secilenAlgoritma,
  }) : super(key: key);

  @override
  _SevkiyatPlanlamaEkraniState createState() => _SevkiyatPlanlamaEkraniState();
}

class _SevkiyatPlanlamaEkraniState extends State<SevkiyatPlanlamaEkrani> {
  late List<SevkiyatKalemi> _sevkiyatListesi;
  late Map<String, TextEditingController> _controllers;

  bool _isLoading = false;
  bool _gorselOlustur = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _sevkiyatListesi = [];
    _controllers = {};
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _hesapla() async {
    if (_sevkiyatListesi == null || _sevkiyatListesi.isEmpty) return;

    _controllers.forEach((koliId, controller) {
      try {
        final kalem = _sevkiyatListesi.firstWhere((k) => k.koli.id == koliId);
        kalem.adet = int.tryParse(controller.text) ?? 0;
      } catch (e) {
        print("Hata: Controller ile sevkiyat listesi eşleşmedi: $koliId");
      }
    });

    final List<SevkiyatKalemi> gonderilecekler = _sevkiyatListesi.where((kalem) => kalem.adet > 0).toList();

    if (gonderilecekler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen sevkiyat için en az bir koli adedi girin."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final aracServisi = Provider.of<AracServisi>(context, listen: false);
    final mevcutAraclar = aracServisi.tumMevcutAraclar();

    if (mevcutAraclar.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("HATA: Hiç araç tanımı yapılmamış. Lütfen araç ekleyin."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      setState(() { _isLoading = false; });
      return;
    }


    final DateTime baslangicZamani = DateTime.now();
    bool isApiKullanildi = widget.secilenAlgoritma != 'ffd';

    try {
      final OptimizasyonServisi servis = OptimizasyonServisi();

      if (isApiKullanildi) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("3D hesaplama başlatıldı... Lütfen bekleyin."),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      final SevkiyatSonucu sonuc = await servis.planla(
        gonderilecekler,
        mevcutAraclar,
        context: context,
        algoritma: widget.secilenAlgoritma,
        gorselOlustur: _gorselOlustur,
      );

      final DateTime bitisZamani = DateTime.now();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SonucEkrani(
            sonuc: sonuc,
            baslangicZamani: baslangicZamani,
            bitisZamani: bitisZamani,
            apiSunucuAdresi: isApiKullanildi ? OptimizasyonServisi.baseUrl : null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hesaplama/API Hatası: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 7),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<KoliServisi, AracServisi>(
      builder: (context, koliServisi, aracServisi, child) {

        final bool isDatabaseLoading = koliServisi.isLoading || aracServisi.isLoading;

        if (isDatabaseLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sevkiyat Planla')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Veritabanı verileri yükleniyor..."),
                ],
              ),
            ),
          );
        }

        if (!isDatabaseLoading && !_isInitialized) {
          _sevkiyatListesi = koliServisi.koliler.map((koli) {
            return SevkiyatKalemi(koli: koli, adet: 0);
          }).toList();

          _controllers = {
            for (var kalem in _sevkiyatListesi) kalem.koli.id: TextEditingController(),
          };

          _isInitialized = true;
        }

        String algoritmaMetni;
        Color algoritmaRengi;
        bool apiKullaniliyor = widget.secilenAlgoritma != 'ffd';

        switch (widget.secilenAlgoritma) {
          case 'batch':
          case 'full3d':
            algoritmaMetni = 'API ile (3D)';
            algoritmaRengi = Colors.blue;
            break;
          default: // 'ffd'
            algoritmaMetni = 'Yerel Motor (Hızlı FFD)';
            algoritmaRengi = Colors.green;
        }

        if (koliServisi.koliler.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sevkiyat Planla')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber, size: 60, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      "Önce Koli Tanımları ekranında en az bir koli eklemelisiniz.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Yeni Sevkiyat Planla'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calculate),
                onPressed: _isLoading ? null : _hesapla,
                tooltip: 'Hesapla',
              ),
            ],
          ),
          body: Column(
            children: [
              // Kontrol Paneli
              Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: algoritmaRengi.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: algoritmaRengi)),
                      child: Text(
                        'Mod: $algoritmaMetni',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: algoritmaRengi,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // 3D Görsel SwitchListTile
                    if (apiKullaniliyor)
                      SwitchListTile(
                        title: Row(
                          children: [
                            Icon(
                              Icons.threed_rotation,
                              color: _gorselOlustur ? Theme.of(context).colorScheme.secondary : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '3D Görselleştirme',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _gorselOlustur ? '3D yükleme planı web linki oluşturulacak' : 'Sadece metin sonuç',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        value: _gorselOlustur,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                          setState(() {
                            _gorselOlustur = value;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.secondary,
                        dense: true,
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Koli Listesi
              Expanded(
                child: Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: AbsorbPointer(
                    absorbing: _isLoading,
                    child: ListView.builder(
                      itemCount: _sevkiyatListesi.length,
                      itemBuilder: (context, index) {
                        final kalem = _sevkiyatListesi[index];
                        final controller = _controllers[kalem.koli.id];

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).primaryColor),
                            ),
                            title: Text(kalem.koli.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Ebat: ${kalem.koli.en}x${kalem.koli.boy}x${kalem.koli.yukseklik} cm'),
                            trailing: SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '0',
                                  labelText: 'Adet',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Hesapla Butonu
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : (apiKullaniliyor ? const Icon(Icons.cloud_done) : const Icon(Icons.calculate_outlined)),
                  label: Text(
                    _isLoading ? 'Hesaplanıyor...' : 'Hesapla',
                    style: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _isLoading ? null : _hesapla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: algoritmaRengi,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

              // ALT KISIMDA BANNER REKLAM
              const BannerReklamWidget(),
            ],
          ),
        );
      },
    );
  }
}