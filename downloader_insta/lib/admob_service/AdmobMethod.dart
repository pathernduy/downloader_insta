// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import 'AdsMobService.dart';
//
// class AdmobMethods{
//   void createInterstitialAd(InterstitialAd? interstitialAd) {
//     InterstitialAd.load(
//
//         adUnitId: AdsMobService.interstitialAdUnit!,
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             ad.fullScreenContentCallback = FullScreenContentCallback(
//               // Called when the ad showed the full screen content.
//                 onAdShowedFullScreenContent: (ad) {},
//                 // Called when an impression occurs on the ad.
//                 onAdImpression: (ad) {},
//                 // Called when the ad failed to show full screen content.
//                 onAdFailedToShowFullScreenContent: (ad, err) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when the ad dismissed full screen content.
//                 onAdDismissedFullScreenContent: (ad) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when a click is recorded for an ad.
//                 onAdClicked: (ad) {});
//
//             debugPrint('$ad loaded.');
//             // Keep a reference to the ad so you can show it later.
//             interstitialAd = ad;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (LoadAdError error) {
//             debugPrint('InterstitialAd failed to load: $error');
//           },
//         ));
//   }
//
//   void showInterstitialAd(InterstitialAd? interstitialAd) {
//     if (interstitialAd == null) {
//       print('Warning: attempt to show interstitial before loaded.');
//       return;
//     }
//     interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (InterstitialAd ad) =>
//           print('ad onAdShowedFullScreenContent.'),
//       onAdDismissedFullScreenContent: (InterstitialAd ad) {
//         print('$ad onAdDismissedFullScreenContent.');
//         ad.dispose();
//         createInterstitialAd(interstitialAd);
//       },
//       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         ad.dispose();
//         createInterstitialAd(interstitialAd);
//       },
//     );
//     interstitialAd!.show();
//     interstitialAd = null;
//   }
//
//   void initBannerAd(BannerAd? bannerAd,bool isBannerAdLoaded) {
//     bannerAd = BannerAd(
//         size: AdSize.fullBanner,
//         adUnitId: AdsMobService.bannerAdUnit! // test ad id
//         // 'ca-app-pub-4759549056554403/3979113467'
//         ,
//         listener: BannerAdListener(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             debugPrint('$ad loaded.');
//             setState(() {
//               isBannerAdLoaded = true;
//             });
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (ad, err) {
//             debugPrint('BannerAd failed to load: $err');
//             // Dispose the ad here to free resources.
//             ad.dispose();
//           },
//         ),
//         request: const AdRequest())
//       ..load();
//   }
//
//   void createRewardedAd(RewardedAd? rewardedAd) {
//     RewardedAd.load(
//         adUnitId: AdsMobService.rewardedAdUnit,
//         request: const AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//             onAdLoaded: (ad) => setState(() => rewardedAd = ad),
//             onAdFailedToLoad: (LoadAdError error) =>
//                 setState(() => rewardedAd = null))) ;
//   }
//
//   void createRewardedInterstitialAd(RewardedInterstitialAd? rewardedInterstitialAd) {
//     RewardedInterstitialAd?.load(
//         adUnitId: AdsMobService.interstitialRewardAdUnit!,
//         request: const AdRequest(),
//         rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             ad.fullScreenContentCallback = FullScreenContentCallback(
//               // Called when the ad showed the full screen content.
//                 onAdShowedFullScreenContent: (ad) {},
//                 // Called when an impression occurs on the ad.
//                 onAdImpression: (ad) {},
//                 // Called when the ad failed to show full screen content.
//                 onAdFailedToShowFullScreenContent: (ad, err) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when the ad dismissed full screen content.
//                 onAdDismissedFullScreenContent: (ad) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when a click is recorded for an ad.
//                 onAdClicked: (ad) {});
//
//             debugPrint('$ad loaded.');
//             // Keep a reference to the ad so you can show it later.
//             rewardedInterstitialAd = ad;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (LoadAdError error) {
//             print('RewardedInterstitialAd failed to load: $error');
//           },
//         ));
//   }
//
//   void createNativeAd(NativeAd? nativeAd, bool isNativeAdLoaded) {
//     nativeAd = NativeAd(
//         adUnitId: AdsMobService.nativeAdUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             print('$NativeAd loaded.');
//             setState(() {
//               isNativeAdLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             // Dispose the ad here to free resources.
//             print('$NativeAd failedToLoad: $error');
//             ad.dispose();
//           },
//           // Called when a click is recorded for a NativeAd.
//           onAdClicked: (ad) {},
//           // Called when an impression occurs on the ad.
//           onAdImpression: (ad) {},
//           // Called when an ad removes an overlay that covers the screen.
//           onAdClosed: (ad) {},
//           // Called when an ad opens an overlay that covers the screen.
//           onAdOpened: (ad) {},
//           // For iOS only. Called before dismissing a full screen view
//           onAdWillDismissScreen: (ad) {},
//           // Called when an ad receives revenue value.
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         // Styling
//         nativeTemplateStyle: NativeTemplateStyle(
//           // Required: Choose a template.
//             templateType: TemplateType.medium,
//             // Optional: Customize the ad's style.
//             mainBackgroundColor: Colors.purple,
//             cornerRadius: 10.0,
//             callToActionTextStyle: NativeTemplateTextStyle(
//                 textColor: Colors.cyan,
//                 backgroundColor: Colors.red,
//                 style: NativeTemplateFontStyle.monospace,
//                 size: 16.0),
//             primaryTextStyle: NativeTemplateTextStyle(
//                 textColor: Colors.red,
//                 backgroundColor: Colors.cyan,
//                 style: NativeTemplateFontStyle.italic,
//                 size: 16.0),
//             secondaryTextStyle: NativeTemplateTextStyle(
//                 textColor: Colors.green,
//                 backgroundColor: Colors.black,
//                 style: NativeTemplateFontStyle.bold,
//                 size: 16.0),
//             tertiaryTextStyle: NativeTemplateTextStyle(
//                 textColor: Colors.brown,
//                 backgroundColor: Colors.amber,
//                 style: NativeTemplateFontStyle.normal,
//                 size: 16.0))
//     )
//       ..load();
//   }
//
//   void createNativeAdItem(NativeAd? nativeAdItem, bool isNativeAdItemLoaded) {
//     nativeAdItem = NativeAd(
//
//       // nativeAdOptions: ,
//       factoryId: "nativeAdItem",
//       adUnitId: AdsMobService.nativeAdItemUnit
//       // AdsMobService.nativeAdUnit!
//       ,
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           print('nativeAdItem loaded.');
//           setState(() {
//             isNativeAdItemLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           // Dispose the ad here to free resources.
//           print('$NativeAd failedToLoad: $error');
//           ad.dispose();
//         },
//         // Called when a click is recorded for a NativeAd.
//         onAdClicked: (ad) {},
//         // Called when an impression occurs on the ad.
//         onAdImpression: (ad) {},
//         // Called when an ad removes an overlay that covers the screen.
//         onAdClosed: (ad) {},
//         // Called when an ad opens an overlay that covers the screen.
//         onAdOpened: (ad) {},
//         // For iOS only. Called before dismissing a full screen view
//         onAdWillDismissScreen: (ad) {},
//         // Called when an ad receives revenue value.
//         onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//       ),
//       request: const AdRequest(),
//     )
//       ..load();
//   }
// }