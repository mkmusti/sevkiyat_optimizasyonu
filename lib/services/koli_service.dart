// lib/services/koli_service.dart

import 'package:flutter/foundation.dart';
import '../models/koli_model.dart';
import 'database_helper.dart';

class KoliServisi extends ChangeNotifier {
  final List<KoliModel> _koliler = [];
  bool _isLoading = true;

  KoliServisi() {
    _veritabaniOku();
  }

  List<KoliModel> get koliler => List.unmodifiable(_koliler);
  bool get isLoading => _isLoading;

  Future<void> _veritabaniOku() async {
    _isLoading = true;

    try {
      final koliListesi = await DatabaseHelper.instance.getAllKoliler();
      _koliler.clear();
      _koliler.addAll(koliListesi);
    } catch (e) {
      // Hata olursa (örn. Windows'ta), en azından konsolda görelim
      if (kDebugMode) {
        print("HATA: [KoliServisi] Veritabanı okuma HATASI: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> koliEkle(KoliModel koli) async {
    try {
      await DatabaseHelper.instance.createKoli(koli);
      _koliler.add(koli);
      notifyListeners();
    } catch (e) {
      print("Koli Ekleme Hatası: $e");
      throw Exception("Koli eklenirken bir hata oluştu: $e");
    }
  }

  Future<void> koliGuncelle(String id, KoliModel yeniKoli) async {
    try {
      await DatabaseHelper.instance.updateKoli(yeniKoli);
      final index = _koliler.indexWhere((k) => k.id == id);
      if (index != -1) {
        _koliler[index] = yeniKoli;
        notifyListeners();
      }
    } catch (e) {
      print("Koli Güncelleme Hatası: $e");
      throw Exception("Koli güncellenirken bir hata oluştu: $e");
    }
  }

  Future<void> koliSil(String id) async {
    try {
      await DatabaseHelper.instance.deleteKoli(id);
      _koliler.removeWhere((k) => k.id == id);
      notifyListeners();
    } catch (e) {
      print("Koli Silme Hatası: $e");
      throw Exception("Koli silinirken bir hata oluştu: $e");
    }
  }

  KoliModel? koliGetir(String id) {
    try {
      return _koliler.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
}