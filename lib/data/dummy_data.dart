// lib/data/dummy_data.dart
import '../models/koli_model.dart';
import '../models/arac_model.dart';

List<KoliModel> dummyKoliListesi = [
  KoliModel(
    id: 'k1',
    ad: 'Küçük Kutu',
    en: 20,
    boy: 30,
    yukseklik: 10,
    agirlik: 5,
  ),
  KoliModel(
    id: 'k2',
    ad: 'Orta Kutu',
    en: 40,
    boy: 40,
    yukseklik: 30,
    agirlik: 10,
  ),
  KoliModel(
    id: 'k3',
    ad: 'Büyük Palet',
    en: 120,
    boy: 80,
    yukseklik: 100,
    agirlik: 150,
  ),
];

List<AracModel> dummyAracListesi = [
  AracModel(
    id: 't1',
    ad: 'Standart Tır (13.6m)',
    yuklenebilirEn: 245,
    yuklenebilirBoy: 1360,
    yuklenebilirYukseklik: 270,
    maksKapasiteAgirlik: 24000,
  ),
  AracModel(
    id: 'k1',
    ad: 'Kamyonet (Doblo)',
    yuklenebilirEn: 150,
    yuklenebilirBoy: 200,
    yuklenebilirYukseklik: 130,
    maksKapasiteAgirlik: 1000,
  ),
];
