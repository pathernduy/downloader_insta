import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsMobService {
  static String? get bannerAdUnit {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('ad opened'),
  );

  static String? get interstitialAdUnit {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get rewardedAdUnit {
    return 'ca-app-pub-3940256099942544/5224354917';
  }
}
