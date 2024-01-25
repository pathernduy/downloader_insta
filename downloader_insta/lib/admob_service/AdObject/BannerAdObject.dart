import 'package:downloader_insta/admob_service/AdsMobService.dart';
import 'package:downloader_insta/admob_service/AdsMobTestId.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => BannerWidgetState();
}

class BannerWidgetState extends State<BannerWidget> {
  BannerAd? _bannerAd;
  bool isBannerAdLoaded = false;

  final String? _adUnitId = AdsMobService.bannerAdUnit;
  final String? _adUnitIdTest = AdsMobTestId.bannerAdUnit;

  void _loadAd() async {
    BannerAd(
      adUnitId: _adUnitIdTest!,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  void initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdsMobService.bannerAdUnit! // test ad id
        // 'ca-app-pub-4759549056554403/3979113467'
        ,
        listener: BannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            setState(() {
              isBannerAdLoaded = true;
            });
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (ad, err) {
            debugPrint('BannerAd failed to load: $err');
            // Dispose the ad here to free resources.
            ad.dispose();
          },
        ),
        request: const AdRequest())
      ..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return isBannerAdLoaded
        ? SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    )
        : const SizedBox();
  }
}
