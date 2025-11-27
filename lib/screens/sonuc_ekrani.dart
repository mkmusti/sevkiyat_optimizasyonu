// lib/screens/sonuc_ekrani.dart
import 'package:flutter/material.dart';
import '../bin_packing_3d_viewer.dart';
import '../models/sevkiyat_sonuc_model.dart';
import '../widgets/banner_reklam_widget.dart';

class SonucEkrani extends StatelessWidget {
  final SevkiyatSonucu sonuc;
  final DateTime baslangicZamani;
  final DateTime bitisZamani;
  final String? apiSunucuAdresi;

  const SonucEkrani({
    super.key,
    required this.sonuc,
    required this.baslangicZamani,
    required this.bitisZamani,
    this.apiSunucuAdresi,
  });

  @override
  Widget build(BuildContext context) {
    final sure = bitisZamani.difference(baslangicZamani);
    final toplamKoli = _calculateToplamKoli();
    final toplamArac = sonuc.doluAraclar.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimizasyon Sonuçları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Özet Bilgiler
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  icon: Icons.local_shipping,
                  value: '$toplamArac',
                  label: 'Araç',
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.inventory_2,
                  value: '$toplamKoli',
                  label: 'Toplam Koli',
                ),
                _buildInfoItem(
                  context,
                  icon: Icons.timer,
                  value: '${sure.inSeconds}s',
                  label: 'Süre',
                ),
              ],
            ),
          ),

          // 3D Görsel Butonu
          if (_has3DVisualization())
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.threed_rotation),
                label: const Text('3D Görselleştirmeyi Aç'),
                onPressed: () {
                  final visualPath = _getFirstVisualPath();
                  if (visualPath != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BinPacking3DViewer(visualPath: visualPath), // ✅ ARTIK TANIMLI
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

          // Araç Listesi
          Expanded(
            child: ListView.builder(
              itemCount: sonuc.doluAraclar.length,
              itemBuilder: (context, index) {
                final arac = sonuc.doluAraclar[index];
                return _buildAracCard(context, arac, index);
              },
            ),
          ),

          // Yerleşemeyen Koliler
          if (sonuc.yerlesemeyenKoliIdler.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Yerleşemeyen Koliler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${sonuc.yerlesemeyenKoliIdler.length} koli yerleştirilemedi',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),

          // Banner Reklam
          const BannerReklamWidget(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAracCard(BuildContext context, DoluArac arac, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${index + 1}. Araç - ${arac.aracTipi.ad}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ebat: ${arac.aracTipi.yuklenebilirEn}x${arac.aracTipi.yuklenebilirBoy}x${arac.aracTipi.yuklenebilirYukseklik} cm',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yüklenen Koliler:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...arac.yuklenenKoliler.map((kalem) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '• ${kalem.koli.ad}: ${kalem.adet} adet (${kalem.koli.en}x${kalem.koli.boy}x${kalem.koli.yukseklik} cm)',
              ),
            )),
            if (arac.visualPath != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BinPacking3DViewer(visualPath: arac.visualPath!), // ✅ ARTIK TANIMLI
                    ),
                  );
                },
                child: const Text('3D Görseli Görüntüle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _calculateToplamKoli() {
    int toplam = 0;
    for (final arac in sonuc.doluAraclar) {
      for (final kalem in arac.yuklenenKoliler) {
        toplam += kalem.adet;
      }
    }
    return toplam;
  }

  bool _has3DVisualization() {
    return sonuc.doluAraclar.any((arac) => arac.visualPath != null);
  }

  String? _getFirstVisualPath() {
    for (final arac in sonuc.doluAraclar) {
      if (arac.visualPath != null) {
        return arac.visualPath;
      }
    }
    return null;
  }
}