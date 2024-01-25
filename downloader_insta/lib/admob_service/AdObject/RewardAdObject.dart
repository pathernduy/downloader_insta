//
// import 'package:downloader_insta/admob_service/AdsMobService.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import '../AdsMobTestId.dart';
//
// class RewardedAdObject {
//   RewardedAd? _rewardedAd;
//   bool isRewardedAdLoaded = false;
//
//   final String? _adUnitId = AdsMobService.rewardedAdUnit;
//   final String? _adUnitIdTest = AdsMobTestId.rewardedAdUnit;
//
//   /// Loads a rewarded ad.
//   void loadAd() {
//     RewardedAd.load(
//         adUnitId: _adUnitIdTest!,
//         request: const AdRequest(),
//         rewardedAdLoadCallback:  RewardedAdLoadCallback(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             debugPrint('$ad loaded.');
//             // Keep a reference to the ad so you can show it later.
//             _rewardedAd = ad;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (LoadAdError error) {
//             debugPrint('RewardedAd failed to load: $error');
//           },
//         ));
//   }
//
//   void _createRewardedAd() {
//     RewardedAd.load(
//         adUnitId: AdsMobService.rewardedAdUnit,
//         request: const AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//             onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
//             onAdFailedToLoad: (LoadAdError error) =>
//                 setState(() => _rewardedAd = null))) ;
//   }
//
//   // _rewardedAd!.show(onUserEarnedReward:(AdWithoutView ad, RewardItem rewardItem) {
//   // });
// }
