// lib/screens/arac_tanim_ekrani.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/arac_model.dart';
import 'arac_form_ekrani.dart';
import '../services/arac_servisi.dart';
import '../widgets/banner_reklam_widget.dart';

class AracTanimEkrani extends StatefulWidget {
  const AracTanimEkrani({super.key});

  @override
  _AracTanimEkraniState createState() => _AracTanimEkraniState();
}

class _AracTanimEkraniState extends State<AracTanimEkrani> {
  // Banner reklam yüksekliği (AdMob standart banner: 50-60px)
  static const double _bannerHeight = 60.0;
  static const double _fabBottomPadding = 16.0;

  void _yeniAracEkle() async {
    final yeniArac = await Navigator.push<AracModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const AracFormEkrani(),
        fullscreenDialog: true,
      ),
    );

    if (yeniArac != null) {
      await Provider.of<AracServisi>(context, listen: false).aracEkle(yeniArac);
    }
  }

  void _aracDuzenle(AracModel eskiArac, int index) async {
    final AracModel? guncellenmisArac = await Navigator.push<AracModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AracFormEkrani(duzenlenecekArac: eskiArac),
        fullscreenDialog: true,
      ),
    );

    if (guncellenmisArac != null) {
      await Provider.of<AracServisi>(context, listen: false).aracGuncelle(eskiArac.id, guncellenmisArac);
    }
  }

  void _aracSil(AracModel arac) async {
    final bool silmeyiOnayla = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Araç Silinsin mi?'),
          content: Text('"${arac.ad}" adlı araç tanımı kalıcı olarak silinecek. Emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    ) ?? false;

    if (silmeyiOnayla) {
      if (mounted) {
        await Provider.of<AracServisi>(context, listen: false).aracSil(arac.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Tanımları'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AracServisi>(
              builder: (context, aracServisi, child) {
                if (aracServisi.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Kayıtlı araçlar yükleniyor..."),
                      ],
                    ),
                  );
                }

                final aracListesi = aracServisi.araclar;

                if (aracListesi.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "Henüz araç tanımı eklenmemiş.",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Başlamak için (+) butonuna dokunun.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  // ListView'e alt padding ekleyerek içeriğin FAB'ın altında kalmamasını sağlıyoruz
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 5,
                    bottom: _bannerHeight + 80, // Banner + FAB için alan
                  ),
                  itemCount: aracListesi.length,
                  itemBuilder: (context, index) {
                    final arac = aracListesi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.local_shipping_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                        title: Text(arac.ad,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Ebat: ${arac.yuklenebilirEn}cm x ${arac.yuklenebilirBoy}cm x ${arac.yuklenebilirYukseklik}cm\n'
                                'Maks Ağırlık: ${arac.maksKapasiteAgirlik}kg'),
                        isThreeLine: true,
                        onTap: () {
                          _aracDuzenle(arac, index);
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            _aracSil(arac);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ALT KISIMDA BANNER REKLAM
          // const BannerReklamWidget(), //reklam için bu satırın remarklarını aç
        ],
      ),
      // FAB'ı banner reklamın üzerine binmeyecek şekilde konumlandırma
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _bannerHeight + _fabBottomPadding),
        child: FloatingActionButton(
          onPressed: _yeniAracEkle,
          tooltip: 'Yeni Araç Ekle',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}