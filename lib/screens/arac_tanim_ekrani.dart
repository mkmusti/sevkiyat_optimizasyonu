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
                        Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Henüz araç tanımı eklenmemiş.",
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
                  itemCount: aracListesi.length,
                  itemBuilder: (context, index) {
                    final arac = aracListesi[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          const BannerReklamWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yeniAracEkle,
        tooltip: 'Yeni Araç Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}