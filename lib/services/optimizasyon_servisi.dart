// lib/services/optimizasyon_servisi.dart
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_service.dart';
import 'ad_manager.dart';

import '../models/arac_model.dart';
import '../models/koli_model.dart';
import '../models/sevkiyat_kalemi_model.dart';
import '../models/sevkiyat_sonuc_model.dart';

class OptimizasyonServisi {
  // ========================================
  // CLOUD RUN API KONFİGÜRASYONU
  // ========================================
  static const String baseUrl = 'https://sevkiyat-api-547787121667.europe-west1.run.app';
  static const String _packItemsEndpoint = '/optimize';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Ana planlama metodu (Freemium model uygulandı)
  Future<SevkiyatSonucu> planla(
      List<SevkiyatKalemi> siparis,
      List<AracModel> mevcutAraclar,
      {required BuildContext context,
        required String algoritma,
        required bool gorselOlustur}
      ) async {

    final userService = Provider.of<UserService>(context, listen: false);
    final adManager = Provider.of<AdManager>(context, listen: false);
    final bool isApiCall = algoritma != 'ffd';

    if (isApiCall) {
      // --- 1. GİRİŞ KONTROLÜ ---
      if (userService.currentUser == null) {
        throw Exception('API kullanmak için önce giriş yapmalısınız (Firebase).');
      }

      // --- 2. HAK KONTROLÜ ---
      if (!userService.isPremium && userService.kalanHak <= 0) {
        throw Exception('API kullanım hakkınız kalmadı! Lütfen yerel FFD algoritmasını seçin veya abonelik alın.');
      }

      // --- 3. FREEMIUM REKLAM GÖSTERİMİ ---
      adManager.showAdBasedOnUsage(
        isPremium: userService.isPremium,
        isApiCall: true,
      );

      // Hak varsa, API'yi çağır
      final sonuc = await _kendiApiIleOptimize(siparis, mevcutAraclar, algoritma: algoritma, gorselOlustur: gorselOlustur);

      // --- 4. HAK AZALTMA ---
      if (!userService.isPremium) {
        await userService.decrementHak();
      }

      return sonuc;
    } else {
      // Yerel FFD algoritması
      final sonuc = await _yerliOptimizasyonMotoru(siparis, mevcutAraclar);
      // --- FREEMIUM: Yerel motor için akıllı reklam ---
      adManager.showAdBasedOnUsage(
        isPremium: userService.isPremium,
        isApiCall: false,
      );
      return sonuc;
    }
  }

  /// Kendi API'miz ile optimizasyon
  Future<SevkiyatSonucu> _kendiApiIleOptimize(List<SevkiyatKalemi> siparis, List<AracModel> mevcutAraclar,
      {required String algoritma, required bool gorselOlustur}) async {

    // print("Kendi API ile optimizasyon başlatılıyor..."); // Log temizlendi
    Map<String, dynamic> apiYanit = {};
    List<String> yerlesemeyenler = [];

    try {
      // 1. API için veri hazırla
      Map<String, dynamic> requestData = _apiVerisiHazirla(siparis, mevcutAraclar,
          algoritma: algoritma, gorselOlustur: gorselOlustur);
      // print("API'ye gönderilen koli tipleri: ${siparis.length}"); // Log temizlendi

      // 2. API'ye istek gönder
      final response = await http
          .post(
        Uri.parse('$baseUrl$_packItemsEndpoint'),
        headers: _headers,
        body: jsonEncode(requestData),
      )
          .timeout(
        const Duration(seconds: 180),
        onTimeout: () {
          throw Exception('API yanıt vermedi (180 saniye). Hesaplama zaman aşımına uğradı.');
        },
      );
      // print("API Yanıt Kodu: ${response.statusCode}"); // Log temizlendi

      // 3. Yanıtı değerlendir
      if (response.statusCode == 200) {
        apiYanit = jsonDecode(response.body);
        // print("✅ API yanıtı başarılı!"); // Log temizlendi

        // Yerleşemeyen kolileri al
        if(apiYanit.containsKey('unpacked_items')) {
          yerlesemeyenler = List<String>.from(apiYanit['unpacked_items'] ?? []);
        }

        // 4. API yanıtını Flutter modellerine çevir
        SevkiyatSonucu sonuc = _apiYanitiniCevir(apiYanit, mevcutAraclar, siparis, yerlesemeyenler);
        // print("Kendi API optimizasyonu tamamlandı: ${sonuc.doluAraclar.length} araç"); // Log temizlendi
        return sonuc;
      } else {
        // Hata
        print("API Hatası: ${response.statusCode}");
        print("Yanıt: ${response.body}");
        throw Exception('API sunucusu hata kodu döndürdü: ${response.statusCode}. Detaylar loglarda.');
      }
    } catch (e) {
      // Bağlantı hatası
      print("API Bağlantı Hatası: $e");
      throw Exception('API bağlantısı başarısız oldu. Sunucu çalışıyor mu? Detay: ${e.toString()}');
    }
  }

  /// API için veri hazırlama - GRUPLANMIŞ FORMAT
  Map<String, dynamic> _apiVerisiHazirla(List<SevkiyatKalemi> siparis, List<AracModel> mevcutAraclar,
      {required String algoritma, required bool gorselOlustur}) {

    // Kolileri API formatına çevir
    List<Map<String, dynamic>> items = siparis.map((kalem) {
      return {
        'id': kalem.koli.id,
        'ad': kalem.koli.ad,
        'length': kalem.koli.boy,
        'width': kalem.koli.en,
        'height': kalem.koli.yukseklik,
        'weight': kalem.koli.agirlik,
        'quantity': kalem.adet,
      };
    }).toList();
    // Araçları API formatına çevir
    List<Map<String, dynamic>> bins = mevcutAraclar.map((arac) {
      return {
        'id': arac.id,
        'ad': arac.ad,
        'length': arac.yuklenebilirBoy,
        'width': arac.yuklenebilirEn,
        'height': arac.yuklenebilirYukseklik,
        'max_weight': arac.maksKapasiteAgirlik,
      };
    }).toList();
    return {
      'items': items,
      'bins': bins,
      'algoritma': algoritma,
      'gorsel_olustur': gorselOlustur,
    };
  }

  /// API yanıtını Flutter modellerine çevirme
  SevkiyatSonucu _apiYanitiniCevir(Map<String, dynamic> apiYanit, List<AracModel> mevcutAraclar,
      List<SevkiyatKalemi> siparis, List<String> yerlesemeyenKoliIdler) {
    List<DoluArac> doluAracListesi = [];
    try {
      if (apiYanit.containsKey('packed_bins')) {
        List packedBins = apiYanit['packed_bins'] ?? [];

        for (var binData in packedBins) {
          String binId = binData['bin_id']?.toString() ?? '';
          List items = binData['items'] ?? [];
          String? visualPath = binData['visual_path']?.toString();

          // --- 🔴 DÜZELTME (BUG FIX) ---
          // API "00716dd1_STANDART-DORSE_1" formatında dönüyor.
          // Bize ortadaki, yani [1] numaralı index'teki ID lazım.

          String aracId = "";
          try {
            // API'nin tutarsız formatına karşı koruma:
            // Önce item (koli) formatını dene: [YEREL_ID]_[API_ID]
            String olasiId = binId.split('_').first;
            var aracTest = mevcutAraclar.firstWhereOrNull((a) => a.id == olasiId);

            if (aracTest != null) {
              aracId = olasiId;
            } else {
              // Eğer ilk deneme başarısızsa, [API_ID]_[YEREL_ID]_[API_ID] formatını dene
              aracId = binId.split('_')[1];
            }
          } catch (e) {
            print("  ❌ Araç ID'si ayrıştırılamadı: $binId - Hata: $e");
            continue;
          }
          // --- DÜZELTME BİTTİ ---

          // Araç tipini bul - ID'ye göre
          AracModel? arac = mevcutAraclar.firstWhereOrNull((a) => a.id == aracId);

          if (arac == null) {
            print("  ❌ Araç tipi bulunamadı (Aranan ID: '$aracId', Orijinal: '$binId')");
            continue;
          }

          if (items.isNotEmpty) {
            // Yüklenen kolilerin ID'lerini topla
            Map<String, int> koliSayilari = {};
            for (var item in items) {
              String itemId = item['item_id']?.toString() ?? '';
              // Koli parser (item_id) doğru çalışıyor ([YEREL_ID]_[API_ID])
              String koliId = itemId.split('_').first;
              koliSayilari[koliId] = (koliSayilari[koliId] ?? 0) + 1;
            }

            // SevkiyatKalemi listesi oluştur
            List<SevkiyatKalemi> ozetListe = [];
            koliSayilari.forEach((koliId, adet) {
              var kalem = siparis.firstWhereOrNull((k) => k.koli.id == koliId);
              if (kalem != null) {
                ozetListe.add(SevkiyatKalemi(koli: kalem.koli, adet: adet));
              }
            });
            if (ozetListe.isNotEmpty) {
              doluAracListesi.add(DoluArac(
                aracTipi: arac,
                yuklenenKoliler: ozetListe,
                visualPath: visualPath,
              ));
            }
          }
        }
      }

    } catch (e) {
      print("API yanıtı işlenirken hata: $e");
    }

    return SevkiyatSonucu(doluAraclar: doluAracListesi, yerlesemeyenKoliIdler: yerlesemeyenKoliIdler);
  }


  /// Yerli Optimizasyon Motoru (Yedek)
  Future<SevkiyatSonucu> _yerliOptimizasyonMotoru(List<SevkiyatKalemi> siparis, List<AracModel> mevcutAraclar) async {
    // print("Yerli Optimizasyon Motoru (Versiyon 2.0) Çalıştı..."); // Log temizlendi
    List<KoliModel> yerlestirilecekTumKoliler = _siparisListesiniOlustur(siparis);
    yerlestirilecekTumKoliler.sort((a, b) => b.hacim.compareTo(a.hacim));

    List<AracModel> siraliAracTipleri = List.from(mevcutAraclar);
    siraliAracTipleri.sort((a, b) => b.yuklenebilirHacim.compareTo(a.yuklenebilirHacim));
    if (siraliAracTipleri.isEmpty) {
      print("HATA: Hiç araç tanımı bulunamadı.");
      return Future.value(SevkiyatSonucu(doluAraclar: []));
    }

    AracModel secilenAracTipi = siraliAracTipleri.first;
    List<DoluArac> doluAracListesi = [];
    List<String> yerlesemeyenler = [];
    while (yerlestirilecekTumKoliler.isNotEmpty) {
      double kalanHacim = secilenAracTipi.yuklenebilirHacim;
      double kalanAgirlik = secilenAracTipi.maksKapasiteAgirlik;
      List<KoliModel> buAracaYuklenenler = [];
      List<KoliModel> kalanKoliler = [];

      for (KoliModel koli in yerlestirilecekTumKoliler) {
        if (koli.hacim <= kalanHacim && koli.agirlik <= kalanAgirlik) {
          kalanHacim -= koli.hacim;
          kalanAgirlik -= koli.agirlik;
          buAracaYuklenenler.add(koli);
        } else {
          kalanKoliler.add(koli);
        }
      }

      if (buAracaYuklenenler.isNotEmpty) {
        List<SevkiyatKalemi> ozetListe = _yuklenenListeyiOzetle(buAracaYuklenenler);
        doluAracListesi.add(DoluArac(aracTipi: secilenAracTipi, yuklenenKoliler: ozetListe));
      }

      yerlestirilecekTumKoliler = kalanKoliler;
      if (buAracaYuklenenler.isEmpty && yerlestirilecekTumKoliler.isNotEmpty) {
        // print("⚠️ Bazı koliler araca sığmadı"); // Log temizlendi
        yerlestirilecekTumKoliler.forEach((koli) => yerlesemeyenler.add(koli.id));
        break;
      }
    }

    // print("Yerli motor tamamlandı: ${doluAracListesi.length} araç"); // Log temizlendi
    return Future.value(SevkiyatSonucu(doluAraclar: doluAracListesi, yerlesemeyenKoliIdler: yerlesemeyenler));
  }

  // YARDIMCI METOTLAR

  List<KoliModel> _siparisListesiniOlustur(List<SevkiyatKalemi> siparis) {
    List<KoliModel> tekilListe = [];
    for (var kalem in siparis) {
      for (int i = 0; i < kalem.adet; i++) {
        tekilListe.add(kalem.koli);
      }
    }
    return tekilListe;
  }

  List<SevkiyatKalemi> _yuklenenListeyiOzetle(List<KoliModel> yuklenenListe) {
    final gruplar = groupBy(yuklenenListe, (KoliModel koli) => koli.id);
    List<SevkiyatKalemi> ozetListe = [];
    gruplar.forEach((id, liste) {
      ozetListe.add(SevkiyatKalemi(koli: liste.first, adet: liste.length));
    });
    return ozetListe;
  }
}