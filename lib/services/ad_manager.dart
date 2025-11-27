// lib/services/ad_manager.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager extends ChangeNotifier {
  static const int _maxFailedLoadAttempts = 3;
  int _interstitialLoadAttempts = 0;
  int _localUsageCounter = 0;
  static const int _adsAfterLocalUsage = 3;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  String get interstitialAdUnitId {
    // Hata ayıklama modunda Google'ın test kimliğini kullan
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else {
        return 'ca-app-pub-3940256099942544/1033173712';
      }
    }

    // YAYINLAMA (PRODUCTION) MODU
    if (Platform.isAndroid) {
      // ⚠️ GÜNCELLENDİ: Sizin Geçiş (Interstitial) Reklam Biriminiz
      return 'ca-app-pub-6890807918605748/4624325653';
    } else if (Platform.isIOS) {
      // (iOS için de gerçek kimliğinizi eklemelisiniz)
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      // Diğer platformlar için test kimliği
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }

  String get bannerAdUnitId {
    // Hata ayıklama modunda Google'ın test kimliğini kullan
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    }

    // YAYINLAMA (PRODUCTION) MODU
    if (Platform.isAndroid) {
      // ⚠️ GÜNCELLENDİ: Sizin Banner Reklam Biriminiz
      return 'ca-app-pub-6890807918605748/6368652160';
    } else if (Platform.isIOS) {
      // (iOS için de gerçek kimliğinizi eklemelisiniz)
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      // Diğer platformlar için test kimliği
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  bool get isInterstitialReady => _isInterstitialReady;
  bool get isBannerReady => _isBannerReady;
  int get localUsageCounter => _localUsageCounter;
  int get adsAfterLocalUsage => _adsAfterLocalUsage;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          _isInterstitialReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          _isInterstitialReady = false;
          _interstitialAd = null;
          notifyListeners();
          if (_interstitialLoadAttempts < _maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialReady) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {},
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _isInterstitialReady = false;
          loadInterstitialAd();
          notifyListeners();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _isInterstitialReady = false;
          loadInterstitialAd();
          notifyListeners();
        },
      );
      _interstitialAd?.show();
    } else {
      loadInterstitialAd();
    }
  }

  void showAdBasedOnUsage({required bool isPremium, required bool isApiCall}) {
    if (isPremium) {
      return;
    }
    if (isApiCall) {
      showInterstitialAd();
    } else {
      _localUsageCounter++;
      if (_localUsageCounter >= _adsAfterLocalUsage) {
        showInterstitialAd();
        _localUsageCounter = 0;
      }
      notifyListeners();
    }
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          // Logları temizledik, ancak hata olursa konsolda görmek yine de faydalı
          if (kDebugMode) {
            print('Banner reklam yüklenemedi: $error');
          }
          ad.dispose();
          _isBannerReady = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _bannerAd;

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}