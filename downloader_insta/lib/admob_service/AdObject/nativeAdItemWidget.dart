import 'package:downloader_insta/admob_service/AdsMobService.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ItemNativeAd extends StatefulWidget {

  const ItemNativeAd({Key? key}) : super(key: key);

  @override
  State<ItemNativeAd> createState() => itemNativeAdState();
}

class itemNativeAdState extends State<ItemNativeAd> {

  NativeAd? _nativeAdItem;
  bool isNativeAdItemLoaded = false;

  @override
  void initState() {

    _nativeAdItem = NativeAd(

      // nativeAdOptions: ,
      factoryId: "nativeAdItem",
      adUnitId: AdsMobService.nativeAdItemUnit
      // AdsMobService.nativeAdUnit!
      ,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('_nativeAdItem loaded.');
          setState(() {
            isNativeAdItemLoaded = true;
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
    )
      ..load();
  }

  @override
  void dispose() {
    _nativeAdItem?.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {
    return  isNativeAdItemLoaded ?  Container(
      height: MediaQuery.of(context)
          .size
          .height *
          0.35,
      child: AdWidget(ad: _nativeAdItem!),
    ):  SizedBox(
      // height: 340.h,
      width: MediaQuery.of(context).size.width,
      child: Center(
          child: Container(
              // height: 280.h,
              // width: 280.h,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(
                          0, -3), // changes position of shadow
                    ),
                  ],
                  borderRadius:
                  BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Image.asset(
                  'assets/logo_512px_x_512px_-removebg.png',
                  // height: 150.w,
                  // width: 150.w,
                ),
              ))),
    );
  }
}


