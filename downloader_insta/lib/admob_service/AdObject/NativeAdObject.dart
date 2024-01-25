import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../AdsMobService.dart';
import '../AdsMobTestId.dart';

class NativeAdObject extends StatefulWidget {
  const NativeAdObject({Key? key}) : super(key: key);

  @override
  State<NativeAdObject> createState() => _NativeAdObjectState();
}

class _NativeAdObjectState extends State<NativeAdObject> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  final double _adAspectRatioMedium = (370 / 355);

  // TODO: replace this test ad unit with your own ad unit.
  final String? _adUnitId = AdsMobService.rewardedAdUnit;
  final String? _adUnitIdTest = AdsMobTestId.rewardedAdUnit;

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  /// Loads a native ad.
  void loadAd() {
    _nativeAd = NativeAd(
        adUnitId: _adUnitIdTest!,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            print('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
          // Called when a click is recorded for a NativeAd.
          onAdClicked: (ad) {},
          // Called when an impression occurs on the ad.
          onAdImpression: (ad) {},
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (ad) {},
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (ad) {},
          // For iOS only. Called before dismissing a full screen view
          onAdWillDismissScreen: (ad) {},
          // Called when an ad receives revenue value.
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    return (_nativeAdIsLoaded && _nativeAd != null)
        ? SizedBox(
        height: MediaQuery.of(context).size.width *
            _adAspectRatioMedium,
        width: MediaQuery.of(context).size.width,
        child: AdWidget(ad: _nativeAd!))
        :
    SizedBox(
      height: 340.h,
      width: MediaQuery.of(context).size.width,
      child: Center(
          child: Container(
              height: 280.h ,
              width: 280.h,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(211, 211, 211, 200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset:
                      Offset(0, -3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Image.asset(
                  'assets/logo_512px_x_512px_-removebg.png',
                  height: 150.w,
                  width: 150.w,
                ),
              ))),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     // Small template
//     final smallTemplateAd = ConstrainedBox(
//       constraints: const BoxConstraints(
//         minWidth: 320, // minimum recommended width
//         minHeight: 90, // minimum recommended height
//         maxWidth: 400,
//         maxHeight: 200,
//       ),
//       child: AdWidget(ad: _nativeAd!),
//     );
//
// // Medium template
//     final mediumTemplateAd = ConstrainedBox(
//       constraints: const BoxConstraints(
//         minWidth: 320, // minimum recommended width
//         minHeight: 320, // minimum recommended height
//         maxWidth: 400,
//         maxHeight: 400,
//       ),
//       child: AdWidget(ad: _nativeAd!),
//     );
//     if (_nativeAdIsLoaded && _nativeAd != null)
//       return SizedBox(
//           height: MediaQuery
//               .of(context)
//               .size
//               .width *
//               _adAspectRatioMedium,
//           width: MediaQuery
//               .of(context)
//               .size
//               .width,
//           child: AdWidget(ad: _nativeAd!));
//     else
//       return SizedBox(
//         height: MediaQuery
//             .of(context)
//             .size
//             .width *
//             _adAspectRatioMedium,
//         width: MediaQuery
//             .of(context)
//             .size
//             .width,
//       );
//   }
}
