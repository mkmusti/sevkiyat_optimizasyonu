// lib/services/user_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io'; // Platform kontrolü için

class UserService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DÜZELTME: StreamSubscription ile listener'ı kontrol et
  StreamSubscription<User?>? _authSubscription;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get currentUserEmail => currentUser?.email;

  int _kalanHak = 0;
  bool _isPremium = false;
  bool _isInitializing = true;

  int get kalanHak => _kalanHak;
  bool get isPremium => _isPremium;
  bool get isInitializing => _isInitializing;

  static const int AYLIK_FREE_LIMIT = 30;
  static const String USERS_COLLECTION = 'users';

  UserService() {
    print("LOG: [UserService] Constructor başlatılıyor...");
    _initializeAuth();
  }

  // DÜZELTME: Async başlatma metodunu ayır
  Future<void> _initializeAuth() async {
    try {
      print("LOG: [UserService] Auth listener kuruluyor...");

      // KRİTİK DÜZELTME: Windows'ta Firebase Auth listener'ı devre dışı bırak
      // Çünkü Windows'ta thread hatası veriyor ve uygulama çöküyor
      if (Platform.isWindows || Platform.isLinux) {
        print("⚠️ UYARI: Desktop platformda Firebase Auth listener devre dışı.");
        print("   Kullanıcı girişi sadece mobil platformlarda destekleniyor.");
        _isInitializing = false;
        _kalanHak = AYLIK_FREE_LIMIT; // Desktop'ta sınırsız kullanım
        _isPremium = false;
        notifyListeners();
        return; // Windows'ta listener kurma, çökmeyi önle
      }

      // SADECE MOBİL PLATFORMLARDA: Auth listener'ı kur
      await Future.delayed(const Duration(milliseconds: 100));

      // Auth state değişikliklerini dinle
      _authSubscription = _auth.authStateChanges().listen(
        (User? user) {
          print("LOG: [UserService] Auth state değişti: ${user?.email ?? 'null'}");
          if (user != null) {
            _fetchUserRights(user.uid);
          } else {
            _kalanHak = 0;
            _isPremium = false;
            _isInitializing = false;
            notifyListeners();
          }
        },
        onError: (error) {
          print("❌ HATA [UserService] Auth listener hatası: $error");
          _isInitializing = false;
          notifyListeners();
        },
      );

      print("✅ LOG: [UserService] Auth listener başarıyla kuruldu.");
    } catch (e, stack) {
      print("❌ HATA [UserService] _initializeAuth: $e");
      print("   Stack: $stack");
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserRights(String uid) async {
    print("LOG: [UserService] Kullanıcı hakları çekiliyor: $uid");
    try {
      final userDocRef = _firestore.collection(USERS_COLLECTION).doc(uid);
      final doc = await userDocRef.get();
      final now = DateTime.now();

      if (doc.exists) {
        final data = doc.data()!;
        _kalanHak = data['kalanHak'] ?? 0;
        _isPremium = data['isPremium'] ?? false;
        final Timestamp? lastLoginTimestamp = data['lastLogin'] as Timestamp?;
        final lastLoginDate = lastLoginTimestamp?.toDate();

        // Hak Yenileme Kontrolü (Aylık yenilenme)
        if (lastLoginDate != null && (lastLoginDate.month != now.month || lastLoginDate.year != now.year || _kalanHak < 0)) {
          _kalanHak = AYLIK_FREE_LIMIT;
          await userDocRef.update({
            'kalanHak': _kalanHak,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          await userDocRef.update({'lastLogin': FieldValue.serverTimestamp()});
        }

        print("LOG: [UserService] Kullanıcı hakları: $_kalanHak, Premium: $_isPremium");
      } else {
        // Yeni Kullanıcı Kaydı (İlk giriş)
        await userDocRef.set({
          'kalanHak': AYLIK_FREE_LIMIT,
          'isPremium': false,
          'lastLogin': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        _kalanHak = AYLIK_FREE_LIMIT;
        _isPremium = false;
        print("LOG: [UserService] Yeni kullanıcı oluşturuldu.");
      }
    } catch (e, stack) {
      print("❌ HATA [UserService] Firestore Hak Çekme Hatası: $e");
      print("   Stack: $stack");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> decrementHak() async {
    if (currentUser != null && _kalanHak > 0 && !_isPremium) {
      _kalanHak--;
      try {
        await _firestore.collection(USERS_COLLECTION).doc(currentUser!.uid).update({
          'kalanHak': _kalanHak,
        });
        notifyListeners();
        print("LOG: [UserService] Hak azaltıldı: $_kalanHak");
      } catch (e) {
        print("❌ HATA [UserService] Hak azaltma hatası: $e");
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("LOG: [UserService] Kullanıcı çıkış yaptı.");
    } catch (e) {
      print("❌ HATA [UserService] Çıkış hatası: $e");
    }
  }

  // DÜZELTME: dispose'da subscription'ı iptal et
  @override
  void dispose() {
    print("LOG: [UserService] dispose() çağrıldı.");
    _authSubscription?.cancel();
    super.dispose();
  }
}
