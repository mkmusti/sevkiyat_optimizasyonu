// lib/services/database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/arac_model.dart';
import '../models/koli_model.dart';
import 'dart:io'; // Platform kontrolü için

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      print("LOG: [DatabaseHelper] Mevcut veritabanı kullanılıyor.");
      return _database!;
    }
    print("LOG: [DatabaseHelper] Yeni veritabanı oluşturuluyor...");
    _database = await _initDB('sevkiyat_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      // DÜZELTME: Windows/Linux için özel yol
      String path;

      if (Platform.isWindows || Platform.isLinux) {
        // Desktop platformlar için Documents klasörü
        final String appDocDir = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.current.path;

        // Uygulama için özel klasör oluştur
        final dbDir = Directory(join(appDocDir, 'SevkiyatOptimizasyonu'));
        if (!await dbDir.exists()) {
          await dbDir.create(recursive: true);
          print("LOG: [DatabaseHelper] Veritabanı klasörü oluşturuldu: ${dbDir.path}");
        }

        path = join(dbDir.path, filePath);
      } else {
        // Android/iOS için normal yol
        final dbPath = await getDatabasesPath();
        path = join(dbPath, filePath);
      }

      print("LOG: [DatabaseHelper] Veritabanı tam yolu: $path");

      // Veritabanını aç
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) {
          print("LOG: [DatabaseHelper] Veritabanı başarıyla açıldı.");
        },
      );
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] _initDB hatası:");
      print("   Hata: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    try {
      print("LOG: [DatabaseHelper] _createDB çalışıyor, tablolar oluşturuluyor...");

      const idType = 'TEXT PRIMARY KEY';
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';

      // Araçlar tablosunu oluştur
      await db.execute('''
        CREATE TABLE araclar ( 
          id $idType, 
          ad $textType,
          genislik $realType,
          uzunluk $realType,
          yukseklik $realType,
          maksAgirlik $realType
        )
      ''');
      print("LOG: [DatabaseHelper] 'araclar' tablosu oluşturuldu.");

      // Koliler tablosunu oluştur
      await db.execute('''
        CREATE TABLE koliler ( 
          id $idType, 
          ad $textType,
          genislik $realType,
          uzunluk $realType,
          yukseklik $realType,
          agirlik $realType
        )
      ''');
      print("LOG: [DatabaseHelper] 'koliler' tablosu oluşturuldu.");

      // --- Başlangıç Verisi (Seeding) ---
      const String standartAracId = 'STANDART-DORSE';
      final mevcutAraclar = await db.query(
        'araclar',
        where: 'id = ?',
        whereArgs: [standartAracId],
        limit: 1,
      );

      if (mevcutAraclar.isEmpty) {
        await db.insert('araclar', {
          'id': standartAracId,
          'ad': 'Standart Dorse (40ft)',
          'genislik': 245.0,
          'uzunluk': 1360.0,
          'yukseklik': 270.0,
          'maksAgirlik': 20000.0,
        });
        print("LOG: [DatabaseHelper] Başlangıç aracı eklendi.");
      }

      print("✅ LOG: [DatabaseHelper] Veritabanı başarıyla oluşturuldu!");
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] _createDB hatası:");
      print("   Hata: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  // --- ARAÇ CRUD İŞLEMLERİ ---

  Future<AracModel> createArac(AracModel arac) async {
    try {
      final db = await instance.database;
      await db.insert('araclar', arac.toMap());
      print("LOG: [DatabaseHelper] Araç eklendi: ${arac.ad}");
      return arac;
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] createArac: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<List<AracModel>> getAllAraclar() async {
    try {
      final db = await instance.database;
      print("LOG: [DatabaseHelper] getAllAraclar() çağrıldı.");
      final result = await db.query('araclar', orderBy: 'ad ASC');
      print("LOG: [DatabaseHelper] ${result.length} adet araç bulundu.");
      return result.map((json) => AracModel.fromMap(json)).toList();
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] getAllAraclar: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<int> updateArac(AracModel arac) async {
    try {
      final db = await instance.database;
      return db.update(
        'araclar',
        arac.toMap(),
        where: 'id = ?',
        whereArgs: [arac.id],
      );
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] updateArac: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<int> deleteArac(String id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'araclar',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] deleteArac: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  // --- KOLİ CRUD İŞLEMLERİ ---

  Future<KoliModel> createKoli(KoliModel koli) async {
    try {
      final db = await instance.database;
      await db.insert('koliler', koli.toMap());
      print("LOG: [DatabaseHelper] Koli eklendi: ${koli.ad}");
      return koli;
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] createKoli: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<List<KoliModel>> getAllKoliler() async {
    try {
      final db = await instance.database;
      print("LOG: [DatabaseHelper] getAllKoliler() çağrıldı.");
      final result = await db.query('koliler', orderBy: 'ad ASC');
      print("LOG: [DatabaseHelper] ${result.length} adet koli bulundu.");
      return result.map((json) => KoliModel.fromMap(json)).toList();
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] getAllKoliler: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<int> updateKoli(KoliModel koli) async {
    try {
      final db = await instance.database;
      return db.update(
        'koliler',
        koli.toMap(),
        where: 'id = ?',
        whereArgs: [koli.id],
      );
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] updateKoli: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future<int> deleteKoli(String id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'koliler',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print("❌ HATA [DatabaseHelper] deleteKoli: $e");
      print("   Stack: $stackTrace");
      rethrow;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    _database = null;
    print("LOG: [DatabaseHelper] Veritabanı kapatıldı.");
  }
}
