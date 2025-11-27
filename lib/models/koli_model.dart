// lib/models/koli_model.dart

class KoliModel {
  final String id;
  final String ad;
  final double en;
  final double boy;
  final double yukseklik;
  final double agirlik;

  // Orijinal koli referansını veritabanına yazmaya gerek yok,
  // bu bir 'runtime' (çalışma zamanı) mantığıdır.
  final KoliModel? _orijinalKoliReferansi;

  KoliModel({
    required this.id,
    required this.ad,
    required this.en,
    required this.boy,
    required this.yukseklik,
    required this.agirlik,
    KoliModel? orijinalKoliReferansi,
  }) : _orijinalKoliReferansi = orijinalKoliReferansi;

  /// Bu kopyanın orijinal (toleranssız) halini döndürür.
  /// Eğer bu zaten orijinalse, kendini döndürür.
  KoliModel get orijinalKoli => _orijinalKoliReferansi ?? this;

  /// Bu kopyanın hacmini (ister toleranslı ister orijinal olsun) hesaplar.
  double get hacim => en * boy * yukseklik;

  // --- YENİ: Veritabanı için metodlar ---

  /// Veritabanına yazmak için Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      // ID'yi (String) ana anahtar olarak kaydet
      'id': id,
      'ad': ad,
      // Modeldeki alan adlarını (en, boy) veritabanındaki (genislik, uzunluk) alan adlarıyla eşleştir
      'genislik': en,
      'uzunluk': boy,
      'yukseklik': yukseklik,
      'agirlik': agirlik,
    };
  }

  /// Veritabanından okumak için Map'ten oluştur
  factory KoliModel.fromMap(Map<String, dynamic> map) {
    return KoliModel(
      id: map['id'],
      ad: map['ad'],
      // Veritabanındaki alan adlarını (genislik, uzunluk) modeldeki (en, boy) alan adlarıyla eşleştir
      en: map['genislik'],
      boy: map['uzunluk'],
      yukseklik: map['yukseklik'],
      agirlik: map['agirlik'],
    );
  }
}