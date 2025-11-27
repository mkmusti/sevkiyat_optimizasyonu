// lib/models/arac_model.dart
class AracModel {
  final String id;
  final String ad;
  final double yuklenebilirEn;
  final double yuklenebilirBoy;
  final double yuklenebilirYukseklik;
  final double maksKapasiteAgirlik;

  AracModel({
    required this.id,
    required this.ad,
    required this.yuklenebilirEn,
    required this.yuklenebilirBoy,
    required this.yuklenebilirYukseklik,
    required this.maksKapasiteAgirlik,
  });

  double get yuklenebilirHacim => yuklenebilirEn * yuklenebilirBoy * yuklenebilirYukseklik;

  // --- YENİ: Veritabanı için metodlar ---

  // Veritabanına yazmak için Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad': ad,
      'genislik': yuklenebilirEn,      // Model(yuklenebilirEn) -> DB(genislik)
      'uzunluk': yuklenebilirBoy,     // Model(yuklenebilirBoy) -> DB(uzunluk)
      'yukseklik': yuklenebilirYukseklik,
      'maksAgirlik': maksKapasiteAgirlik,
    };
  }

  // Veritabanından okumak için Map'ten oluştur
  factory AracModel.fromMap(Map<String, dynamic> map) {
    return AracModel(
      id: map['id'],
      ad: map['ad'],
      yuklenebilirEn: map['genislik'],      // DB(genislik) -> Model(yuklenebilirEn)
      yuklenebilirBoy: map['uzunluk'],      // DB(uzunluk) -> Model(yuklenebilirBoy)
      yuklenebilirYukseklik: map['yukseklik'],
      maksKapasiteAgirlik: map['maksAgirlik'],
    );
  }
}