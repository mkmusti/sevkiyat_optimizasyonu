// lib/services/in_app_purchase_service.dart (FINAL Hali)
import 'dart:async';
import 'package:flutter/material.dart'; // ⬅️ EKLENDİ: BuildContext için
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'user_service.dart';

const Set<String> _kProductIds = {'premium_subscription_monthly'};

class InAppPurchaseService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  // ⬅️ YENİ EKLENDİ: Satın alma akışını başlatmak için context'e ihtiyaç var
  BuildContext? _appContext;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  InAppPurchaseService() {
    _initialize();
  }

  // ⬅️ YENİ METOT: main.dart'tan veya Splash'ten çağrılmalı
  void setContext(BuildContext context) {
    _appContext = context;
  }

  void _initialize() async {
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      // ... (hata yönetimi)
      notifyListeners();
      return;
    }

    // Satın alma akışını dinlemeye başla
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print("IAP Stream Error: $error");
    });

    await loadProducts();
    notifyListeners();
  }

  Future<void> loadProducts() async {
    // ... (metot içeriği aynı) ...
    if (!_isAvailable) return;

    final response = await _iap.queryProductDetails(_kProductIds);
    if (response.error != null) {
      _queryProductError = response.error!.message;
      _products = [];
      print("IAP Ürün Yükleme Hatası: $_queryProductError");
    } else {
      _queryProductError = null;
      _products = response.productDetails;
      print("IAP Ürünleri Başarıyla Yüklendi: ${_products.length} adet.");
    }
    notifyListeners();
  }

  void buySubscription(ProductDetails productDetails) {
    if (!_isAvailable) return;
    if (_appContext == null) {
      print("IAP HATA: Context ayarlanmamış.");
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _purchasePending = true;
    notifyListeners();

    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        notifyListeners();
      } else {
        _purchasePending = false;
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("IAP Hata: ${purchaseDetails.error?.message}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndGrantSubscription(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
    notifyListeners();
  }

  void _verifyAndGrantSubscription(PurchaseDetails purchaseDetails) {
    if (_appContext == null) {
      print("IAP HATA: Satın alma doğrulandı ancak context ayarlı değil. Premium erişimi verilemedi.");
      return;
    }

    // ⚠️ KRİTİK: Bu kısım, sunucuda yapılmalıdır.
    final isVerified = true;

    if (isVerified) {
      // UserService'i bul ve Premium erişimi ver
      final userService = Provider.of<UserService>(_appContext!, listen: false);
      userService.grantPremiumAccess();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}