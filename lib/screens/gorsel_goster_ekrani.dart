// lib/screens/sonuc_ekrani.dart
import 'package:flutter/material.dart';
import 'package:sevkiyat_optimizasyonu/bin_packing_3d_viewer.dart';
import '../models/sevkiyat_sonuc_model.dart';

class SonucEkrani extends StatelessWidget {
  final SevkiyatSonucu sonuc;
  final DateTime baslangicZamani;
  final DateTime bitisZamani;
  final String? apiSunucuAdresi;

  const SonucEkrani({
    Key? key,
    required this.sonuc,
    required this.baslangicZamani,
    required this.bitisZamani,
    this.apiSunucuAdresi,
  }) : super(key: key);

  // ... (formatlama metodları aynı) ...
  double _cm3ToM3(double cm3) {
    return cm3 / 1000000.0;
  }

  String _formatZaman(DateTime zaman) {
    return "${zaman.hour.toString().padLeft(2, '0')}:"
        "${zaman.minute.toString().padLeft(2, '0')}:"
        "${zaman.second.toString().padLeft(2, '0')}";
  }

  String _formatGecenSure(Duration sure) {
    double saniye = sure.inMilliseconds / 1000.0;
    return "${saniye.toStringAsFixed(2)} saniye";
  }

  @override
  Widget build(BuildContext context) {
    final int toplamAracSayisi = sonuc.doluAraclar.length;
    final Duration gecenSure = bitisZamani.difference(baslangicZamani);
    final theme = Theme.of(context); // Temayı değişkene al

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevkiyat Planı Sonucu'),
        // backgroundColor: Colors.indigo, // KALDIRILDI
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Bilgi Alanı
          Container(
            padding: const EdgeInsets.all(16.0),
            // Temanın 'canvas' rengini kullan (açıkta açık, koyuda koyu)
            color: theme.canvasColor,
            child: Column(
              children: [
                Text(
                  'Toplam $toplamAracSayisi Araç Gerekli',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor, // GÜNCELLENDİ
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 16, thickness: 1),
                _buildZamanSatiri(context, "Başlangıç:", _formatZaman(baslangicZamani)),
                const SizedBox(height: 4),
                _buildZamanSatiri(context, "Bitiş:", _formatZaman(bitisZamani)),
                const SizedBox(height: 4),
                _buildZamanSatiri(context, "Geçen Süre:", _formatGecenSure(gecenSure), isBold: true),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Araç Listesi
          Expanded(
            child: ListView.builder(
              itemCount: sonuc.doluAraclar.length,
              itemBuilder: (context, index) {
                // ... (Hesaplamalar aynı) ...
                final doluArac = sonuc.doluAraclar[index];
                final aracAdi = doluArac.aracTipi.ad;
                final double aracHacmiM3 = _cm3ToM3(doluArac.aracTipi.yuklenebilirHacim);
                final double yuklenenHacimM3 = _cm3ToM3(doluArac.toplamYuklenenHacim);
                final double hacimDolulukYuzdesi = doluArac.hacimDolulukOrani;
                final double aracAgirlikKG = doluArac.aracTipi.maksKapasiteAgirlik;
                final double yuklenenAgirlikKG = doluArac.toplamYuklenenAgirlik;
                final double agirlikDolulukYuzdesi = doluArac.agirlikDolulukOrani;
                final String? gorselYolu = doluArac.visualPath;
                final bool gorselVar = (gorselYolu != null && gorselYolu.isNotEmpty);
                final String tamGorselUrl = (gorselVar && apiSunucuAdresi != null) ? "$apiSunucuAdresi$gorselYolu" : "URL Yok";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      // Amber yerine 'secondary' (ikincil) tema rengini kullan
                      backgroundColor: theme.colorScheme.secondary,
                      child: const Icon(Icons.local_shipping, color: Colors.white),
                    ),
                    title: Text(
                      'Araç ${index + 1}: ${aracAdi.replaceAll("_", " ")}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Hacim: ${hacimDolulukYuzdesi.toStringAsFixed(1)}% (${yuklenenHacimM3.toStringAsFixed(2)} m³ / ${aracHacmiM3.toStringAsFixed(2)} m³)\n'
                      'Ağırlık: ${agirlikDolulukYuzdesi.toStringAsFixed(1)}% (${yuklenenAgirlikKG.toStringAsFixed(0)} kg / ${aracAgirlikKG.toStringAsFixed(0)} kg)',
                      style: const TextStyle(fontSize: 12.0),
                    ),

                    // ... (children ve görsel butonu aynı, onlar semantik) ...
                    children: [
                      ...doluArac.yuklenenKoliler.map((kalem) {
                        return ListTile(
                          title: Text('• ${kalem.koli.ad}'),
                          trailing: Text(
                            '${kalem.adet} Adet',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
                          dense: true,
                        );
                      }).toList(),
                      if (gorselVar)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  'API Yolu: $gorselYolu\nTam URL: $tamGorselUrl',
                                  style: const TextStyle(fontSize: 10, color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.threed_rotation),
                                label: const Text("3D Yükleme Planını Gör"),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green.shade800, side: BorderSide(color: Colors.green.shade700)),
                                onPressed: () {
                                  print("🖼️ 3D Görsel açılıyor (yol): $gorselYolu");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BinPacking3DViewer(
                                        visualPath: gorselYolu,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                          child: Text(
                            'Bu araç için API görseli oluşturulmadı.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Zaman Satırı Widget'ı
  Widget _buildZamanSatiri(BuildContext context, String etiket, String deger, {bool isBold = false}) {
    final theme = Theme.of(context); // Temayı al

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiket, style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)) // GÜNCELLENDİ
            ),
        Text(
          deger,
          style: TextStyle(
            fontSize: 14,
            color: isBold ? theme.primaryColor : theme.textTheme.bodyLarge?.color, // GÜNCELLENDİ
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
