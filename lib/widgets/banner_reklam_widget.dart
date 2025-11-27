// lib/widgets/banner_reklam_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_manager.dart';

class BannerReklamWidget extends StatefulWidget {
  const BannerReklamWidget({super.key});

  @override
  State<BannerReklamWidget> createState() => _BannerReklamWidgetState();
}

class _BannerReklamWidgetState extends State<BannerReklamWidget> {
  BannerAd? _bannerAd;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adManager = Provider.of<AdManager>(context, listen: false);

    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adManager.bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner reklam yüklenemedi: $error');
          ad.dispose();
          _isBannerReady = false;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBannerReady) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}