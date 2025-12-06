// lib/services/user_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserRights(user.uid);
      } else {
        _kalanHak = 0;
        _isPremium = false;
        _isInitializing = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserRights(String uid) async {
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
      }
    } catch (e) {
      print("Firestore Hak Çekme Hatası: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> decrementHak() async {
    if (currentUser != null && _kalanHak > 0 && !_isPremium) {
      _kalanHak--;
      await _firestore.collection(USERS_COLLECTION).doc(currentUser!.uid).update({
        'kalanHak': _kalanHak,
      });
      notifyListeners();
    }
  }

  // ⬅️ YENİ EKLENDİ: Premium erişimi verme ve iptal etme metotları
  Future<void> grantPremiumAccess() async {
    if (currentUser != null) {
      _isPremium = true;
      _kalanHak = 9999; // Sınırsız sembolik hak
      await _firestore.collection(USERS_COLLECTION).doc(currentUser!.uid).update({
        'isPremium': true,
        'kalanHak': 9999,
      });
      notifyListeners();
      print("LOG: Kullanıcıya Premium erişimi VERİLDİ.");
    }
  }

  Future<void> revokePremiumAccess() async {
    if (currentUser != null) {
      _isPremium = false;
      _kalanHak = AYLIK_FREE_LIMIT;
      await _firestore.collection(USERS_COLLECTION).doc(currentUser!.uid).update({
        'isPremium': false,
        'kalanHak': AYLIK_FREE_LIMIT,
      });
      notifyListeners();
      print("LOG: Kullanıcının Premium erişimi İPTAL EDİLDİ.");
    }
  }
  // -------------------------------------------------------------

  Future<void> signOut() async {
    await _auth.signOut();
  }
}