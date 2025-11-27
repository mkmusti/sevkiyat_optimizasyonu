// lib/services/arac_servisi.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/arac_model.dart';
import 'database_helper.dart';

class AracServisi extends ChangeNotifier {
  final List<AracModel> _araclar = [];
  bool _isLoading = true;

  AracServisi() {
    _veritabaniOku();
  }

  List<AracModel> get araclar => List.unmodifiable(_araclar);
  bool get isLoading => _isLoading;

  Future<void> _veritabaniOku() async {
    _isLoading = true;

    try {
      final aracListesi = await DatabaseHelper.instance.getAllAraclar();
      _araclar.clear();
      _araclar.addAll(aracListesi);
    } catch (e) {
      // Hata olursa (örn. Windows'ta), en azından konsolda görelim
      if (kDebugMode) {
        print("HATA: [AracServisi] Veritabanı okuma HATASI: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> aracEkle(AracModel arac) async {
    try {
      await DatabaseHelper.instance.createArac(arac);
      _araclar.add(arac);
      notifyListeners();
    } catch (e) {
      print("Araç Ekleme Hatası: $e");
      throw Exception("Araç eklenirken bir hata oluştu (ID çakışması?): $e");
    }
  }

  Future<void> aracGuncelle(String id, AracModel yeniArac) async {
    try {
      await DatabaseHelper.instance.updateArac(yeniArac);
      final index = _araclar.indexWhere((a) => a.id == id);
      if (index != -1) {
        _araclar[index] = yeniArac;
        notifyListeners();
      }
    } catch (e) {
      print("Araç Güncelleme Hatası: $e");
      throw Exception("Araç güncellenirken bir hata oluştu: $e");
    }
  }

  Future<void> aracSil(String id) async {
    try {
      await DatabaseHelper.instance.deleteArac(id);
      _araclar.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print("Araç Silme Hatası: $e");
      throw Exception("Araç silinirken bir hata oluştu: $e");
    }
  }

  AracModel? aracGetir(String id) {
    try {
      return _araclar.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AracModel> tumMevcutAraclar() {
    return List.from(_araclar);
  }
}