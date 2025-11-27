// lib/screens/koli_tanim_ekrani.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/koli_model.dart';
import 'koli_form_ekrani.dart';
import '../services/koli_service.dart';
import '../widgets/banner_reklam_widget.dart';

class KoliTanimEkrani extends StatefulWidget {
  const KoliTanimEkrani({super.key});

  @override
  _KoliTanimEkraniState createState() => _KoliTanimEkraniState();
}

class _KoliTanimEkraniState extends State<KoliTanimEkrani> {
  void _yeniKoliEkle() async {
    final yeniKoli = await Navigator.push<KoliModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const KoliFormEkrani(),
        fullscreenDialog: true,
      ),
    );

    if (yeniKoli != null) {
      await Provider.of<KoliServisi>(context, listen: false).koliEkle(yeniKoli);
    }
  }

  void _koliDuzenle(KoliModel eskiKoli, int index) async {
    final KoliModel? guncellenmisKoli = await Navigator.push<KoliModel>(
      context,
      MaterialPageRoute(
        builder: (context) => KoliFormEkrani(duzenlenecekKoli: eskiKoli),
        fullscreenDialog: true,
      ),
    );

    if (guncellenmisKoli != null) {
      await Provider.of<KoliServisi>(context, listen: false).koliGuncelle(eskiKoli.id, guncellenmisKoli);
    }
  }

  void _koliSil(KoliModel koli) async {
    final bool silmeyiOnayla = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Koli Silinsin mi?'),
          content: Text('"${koli.ad}" adlı koli tanımı kalıcı olarak silinecek. Emin misiniz?'),
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
        await Provider.of<KoliServisi>(context, listen: false).koliSil(koli.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koli Tanımları'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<KoliServisi>(
              builder: (context, koliServisi, child) {
                if (koliServisi.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Kayıtlı koliler yükleniyor..."),
                      ],
                    ),
                  );
                }

                final koliListesi = koliServisi.koliler;

                if (koliListesi.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Henüz koli tanımı eklenmemiş.",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Başlamak için (+) butonuna dokunun.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: koliListesi.length,
                  itemBuilder: (context, index) {
                    final koli = koliListesi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.inventory_2_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                        title: Text(koli.ad,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Ebat: ${koli.en}cm x ${koli.boy}cm x ${koli.yukseklik}cm\n'
                                'Ağırlık: ${koli.agirlik}kg'),
                        isThreeLine: true,
                        onTap: () {
                          _koliDuzenle(koli, index);
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            _koliSil(koli);
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
          const BannerReklamWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniKoliEkle,
        tooltip: 'Yeni Koli Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}