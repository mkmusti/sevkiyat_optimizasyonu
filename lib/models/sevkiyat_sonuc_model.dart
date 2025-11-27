// lib/models/sevkiyat_sonuc_model.dart
import 'arac_model.dart';
import 'sevkiyat_kalemi_model.dart';

class DoluArac {
  final AracModel aracTipi;
  final List<SevkiyatKalemi> yuklenenKoliler;
  final String? visualPath; // Sunucudan gelen görselin URL yolu

  DoluArac({
    required this.aracTipi,
    required this.yuklenenKoliler,
    this.visualPath, // Constructor'a eklendi
  });

  double get toplamYuklenenHacim {
    return yuklenenKoliler.fold(0.0, (toplam, kalem) {
      return toplam + (kalem.koli.hacim * kalem.adet);
    });
  }

  double get hacimDolulukOrani {
    if (aracTipi.yuklenebilirHacim == 0) return 0.0;
    return (toplamYuklenenHacim / aracTipi.yuklenebilirHacim) * 100;
  }

  double get toplamYuklenenAgirlik {
    return yuklenenKoliler.fold(0.0, (toplam, kalem) {
      return toplam + (kalem.koli.agirlik * kalem.adet);
    });
  }

  double get agirlikDolulukOrani {
    if (aracTipi.maksKapasiteAgirlik == 0) return 0.0;
    return (toplamYuklenenAgirlik / aracTipi.maksKapasiteAgirlik) * 100;
  }
}

class SevkiyatSonucu {
  final List<DoluArac> doluAraclar;
  // 📢 KRİTİK EKLENTİ: Yerleşemeyen koli ID'lerini tutar
  final List<String> yerlesemeyenKoliIdler;

  SevkiyatSonucu({required this.doluAraclar, this.yerlesemeyenKoliIdler = const []});
}