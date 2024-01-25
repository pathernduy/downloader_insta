
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:video_player/video_player.dart';

import '../Component Widgets/Drawer.dart';

import '../Component Widgets/alert_error_widgets/ErrorExceptionWidget.dart';
import '../admob_service/AdsMobService.dart';
import '../model/InstaPost.dart';
import '../viewImage.dart';

class DownloadReelScreen extends StatefulWidget {
  const DownloadReelScreen({super.key});

  @override
  State<DownloadReelScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadReelScreen> {
  BannerAd? _bannerAd;
  bool isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;
  RewardedAd? _rewardedAd;
  bool isRewardedAdLoaded = false;
  NativeAd? _nativeAd;
  bool isNativeAdLoaded = false;
  final double _adAspectRatioMedium = (370 / 355);
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool isRewardedInterstitialAdLoaded = false;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool _flexibleUpdateAvailable = false;

  TextEditingController usernameController = TextEditingController();
  TabController? tabController;

  String? username, followers = " ", following, bio, website, profileimage;

  List<String>? listFeedImages;
  bool pressed = false;
  bool downloading = false;

  String prefix = "https://www.instagram.com/reel/";
  dynamic exceptionError = null;
  TextEditingController reelUrlController = TextEditingController();

  // bool pressed = false;
  InstaPost instaPost = InstaPost();
  List<InstaPost>? showListData = [];
  int? lengthItem = 0;
  late FlickManager flickManager = FlickManager(
    videoPlayerController: VideoPlayerController.networkUrl(Uri.parse("")
        // "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m82/7D4FDF47415AE704D2D8CB62F61667A5_video_dashinit.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uNzIwLmNsaXBzLmJhc2VsaW5lIn0&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=1190291614973924_2860471228&_nc_vs=HBksFQIYT2lnX3hwdl9yZWVsc19wZXJtYW5lbnRfcHJvZC83RDRGREY0NzQxNUFFNzA0RDJEOENCNjJGNjE2NjdBNV92aWRlb19kYXNoaW5pdC5tcDQVAALIAQAVABgkR0thb1FBUFFVWF9XR2ZNRUFGZnhZNld3RkIwc2JwUjFBQUFGFQICyAEAKAAYABsAFQAAJrisyICP8tY%2FFQIoAkMzLBdALpmZmZmZmhgSZGFzaF9iYXNlbGluZV8xX3YxEQB1%2FgcA&_nc_rid=266f0ba924&ccb=9-4&oh=00_AfD48lZyVRpcVEDGkD-2nRRokKWWdaou1_MPo6GWhRK3OA&oe=64A95754&_nc_sid=4f4799"
        ),
  );

  var _interstitialRetryAttempt = 0;
  var _rewardedAdRetryAttempt = 0;

  static const double _kMediaViewAspectRatio = 16 / 9;
  double _mediaViewAspectRatio = _kMediaViewAspectRatio;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  //start of flutter Google Admob Ad
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdsMobService.interstitialAdUnit!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _initBannerAd() {
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

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdsMobService.rewardedAdUnit,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
            onAdFailedToLoad: (LoadAdError error) =>
                setState(() => _rewardedAd = null)));
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd?.load(
        adUnitId: AdsMobService.interstitialRewardAdUnit!,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedInterstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
          },
        ));
  }

  void _createNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdsMobService.nativeAdUnit!,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            setState(() {
              isNativeAdLoaded = true;
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

  //end of flutter Google Admob Ad

  @override
  void initState() {
    super.initState();

    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black87));

    _initBannerAd();
    _createRewardedAd();
    _createInterstitialAd();
    _createNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerForScreen(context),
      appBar: AppBar(
        title: const Text('Download Reel'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        labelText: 'Enter reel url',
                      ),
                      controller: reelUrlController,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text("Show Detail"),
                      onPressed: () async {
                        if (reelUrlController.text.contains("/reel/")) {
                          await showListURL(reelUrlController.text);
                          Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              setState(() {
                                if (reelUrlController.text.contains(prefix)) {
                                  pressed = true;
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              Text(' URL reel can\'t be found'),
                                          content: Text(
                                              'We can\t found your reel url. Please wait a few minutes before you try again and make sure you got right url.'),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('ok')),
                                          ],
                                        );
                                      });
                                }
                              });
                            },
                          );
                        } else {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => ErrorExceptionWidget(
                                'Wrong url type',
                                'You must have the link like this: https://www.instagram.com/reel/shortcode/'),
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text("Clear"),
                      onPressed: () {
                        setState(() {
                          reelUrlController.text = '';
                          pressed = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              (isNativeAdLoaded && _nativeAd != null)
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width *
                          _adAspectRatioMedium,
                      width: MediaQuery.of(context).size.width,
                      child: AdWidget(ad: _nativeAd!))
                  : SizedBox(
                      height: 340.h,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                          child: Container(
                              height: 280.h,
                              width: 280.h,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(211, 211, 211, 200),
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
                                  height: 150.w,
                                  width: 150.w,
                                ),
                              ))),
                    ),
              pressed
                  ? showListData!.isNotEmpty
                      ? (showListData!.first.isPrivate)
                          ? ErrorExceptionWidget('URL IS PRIVATE',
                              "Please make sure the url you pasted is not private.")
                          : SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Container(
                                  child: SingleChildScrollView(
                                    physics: NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.85 *
                                              16 /
                                              9,
                                          child: GestureDetector(
                                            child: ClipRRect(
                                                borderRadius: BorderRadius
                                                    .circular!(16),
                                                child: ExtendedImage.memory(
                                                  showListData!
                                                      .first.thumbnail!,
                                                  // i,
                                                  // clearMemoryCacheWhenDispose:
                                                  //     true,
                                                  // fit: BoxFit.cover,
                                                )),
                                          ),

                                          //  BetterPlayer.network(i)
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: 80.w,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              // width: MediaQuery.of(context)
                                              //     .size
                                              //     .width *
                                              //     0.35,
                                              color: Color.fromARGB(
                                                  255, 2, 77, 139),
                                              child: TextButton(
                                                  onPressed: () {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds:
                                                                1000),
                                                        () async {
                                                      (_rewardedAd != null)
                                                          ? _rewardedAd!.show(
                                                              onUserEarnedReward:
                                                                  (AdWithoutView
                                                                          ad,
                                                                      RewardItem
                                                                          rewardItem) {
                                                              downloadVideo(
                                                                  showListData!
                                                                      .first);
                                                            })
                                                          : downloadVideo(
                                                              showListData!
                                                                  .first);
                                                    });
                                                    // downloadVideo(
                                                    //     showListData!.first);
                                                  },
                                                  child: Text(
                                                    "Download",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.sp,
                                                    ),
                                                  )),

                                              //  TextButton(
                                              //     onPressed: () => (i.isVideo == true)?
                                              //         downloadVideo(i) : downloadImage(i),
                                              //     child: i.listFeedImagesUrl!
                                              //             .isEmpty
                                              //         ? Text("Download")
                                              //         : Text(
                                              //             "Download All"))
                                            ),
                                            Container(
                                              width: 80.w,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              // width: MediaQuery.of(context)
                                              //     .size
                                              //     .width *
                                              //     0.35,
                                              color: Color.fromARGB(
                                                  255, 2, 77, 139),
                                              child: TextButton(
                                                  onPressed: () {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds:
                                                                1000),
                                                        () async {
                                                      _createInterstitialAd();
                                                      _interstitialAd!.show();
                                                    });
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ViewImage(
                                                                  showListData!
                                                                      .first,
                                                                  webViewController,
                                                                  refreshController!)),
                                                    );
                                                  },
                                                  child: Text(
                                                    "Watch Video",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.sp,
                                                    ),
                                                  )),

                                              //  TextButton(
                                              //     onPressed: () => (i.isVideo == true)?
                                              //         downloadVideo(i) : downloadImage(i),
                                              //     child: i.listFeedImagesUrl!
                                              //             .isEmpty
                                              //         ? Text("Download")
                                              //         : Text(
                                              //             "Download All"))
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : ErrorExceptionWidget('URL IS NOT FOUND',
                          "Please make sure the url you pasted is not available.")
                  : Container(),


              // pressed
              //     ? showListData!.isEmpty
              //         ? exceptionError != null
              //             ? AlertDialog(
              //                 title: const Text('Basic dialog title'),
              //                 content: const Text(
              //                   "Please wait a few minutes before you try again.",
              //                 ),
              //                 actions: <Widget>[
              //                   TextButton(
              //                     style: TextButton.styleFrom(
              //                       textStyle:
              //                           Theme.of(context).textTheme.labelLarge,
              //                     ),
              //                     child: const Text('Ok'),
              //                     onPressed: () {
              //                       Navigator.of(context).pop();
              //                     },
              //                   ),
              //                 ],
              //               )
              //             : Container()
              //         : (showListData!.length < 2)
              //             ? (showListData![0].isVideo == true)
              //                 ? SingleChildScrollView(
              //                     child: Container(
              //                       width:
              //                           MediaQuery.of(context).size.width * 0.7,
              //                       height: MediaQuery.of(context).size.width *
              //                           16 /
              //                           9
              //                       // MediaQuery.of(context).size.height * 2 / 3 +
              //                       //     120
              //                       ,
              //                       child: AspectRatio(
              //                         aspectRatio: 16 / 9,
              //                         child: Container(
              //                           // height: MediaQuery.of(context)
              //                           //     .size
              //                           //     .height,
              //                           // width: MediaQuery.of(context)
              //                           //     .size
              //                           //     .width,
              //
              //                           child: SingleChildScrollView(
              //                             child: Column(
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.spaceEvenly,
              //                               children: [
              //                                 Container(
              //                                   height: MediaQuery.of(context)
              //                                           .size
              //                                           .height *
              //                                       0.85,
              //                                   width: MediaQuery.of(context)
              //                                           .size
              //                                           .height *
              //                                       0.85 *
              //                                       16 /
              //                                       9,
              //                                   child: GestureDetector(
              //                                     // onTap: () => Navigator.push(
              //                                     //   context,
              //                                     //   MaterialPageRoute(
              //                                     //       builder: (context) =>
              //                                     //           ViewImage(i)
              //                                     //           ),
              //                                     // ),
              //                                     child: ClipRRect(
              //                                         borderRadius: BorderRadius
              //                                             .circular!(16),
              //                                         child:
              //                                             ExtendedImage.memory(
              //                                           showListData!
              //                                               .first.thumbnail!,
              //                                           // i,
              //                                           // clearMemoryCacheWhenDispose:
              //                                           //     true,
              //                                           // fit: BoxFit.cover,
              //                                         )),
              //                                   ),
              //
              //                                   //  BetterPlayer.network(i)
              //                                 ),
              //                                 Row(
              //                                   mainAxisAlignment:
              //                                       MainAxisAlignment
              //                                           .spaceEvenly,
              //                                   children: [
              //                                     Container(
              //                                       width: 80.w,
              //                                       height:
              //                                           MediaQuery.of(context)
              //                                                   .size
              //                                                   .height *
              //                                               0.05,
              //                                       // width: MediaQuery.of(context)
              //                                       //     .size
              //                                       //     .width *
              //                                       //     0.35,
              //                                       color: Color.fromARGB(
              //                                           255, 2, 77, 139),
              //                                       child: TextButton(
              //                                           onPressed: () {
              //                                             Future.delayed(
              //                                                 const Duration(
              //                                                     milliseconds:
              //                                                         1000),
              //                                                 () async {
              //                                               (_rewardedAd !=
              //                                                       null)
              //                                                   ? _rewardedAd!.show(onUserEarnedReward:
              //                                                       (AdWithoutView
              //                                                               ad,
              //                                                           RewardItem
              //                                                               rewardItem) {
              //                                                       downloadVideo(
              //                                                           showListData!
              //                                                               .first);
              //                                                     })
              //                                                   : downloadVideo(
              //                                                       showListData!
              //                                                           .first);
              //                                             });
              //                                             // downloadVideo(
              //                                             //     showListData!.first);
              //                                           },
              //                                           child: Text(
              //                                             "Download",
              //                                             style: TextStyle(
              //                                               color: Colors.white,
              //                                               fontSize: 11.sp,
              //                                             ),
              //                                           )),
              //
              //                                       //  TextButton(
              //                                       //     onPressed: () => (i.isVideo == true)?
              //                                       //         downloadVideo(i) : downloadImage(i),
              //                                       //     child: i.listFeedImagesUrl!
              //                                       //             .isEmpty
              //                                       //         ? Text("Download")
              //                                       //         : Text(
              //                                       //             "Download All"))
              //                                     ),
              //                                     Container(
              //                                       width: 80.w,
              //                                       height:
              //                                           MediaQuery.of(context)
              //                                                   .size
              //                                                   .height *
              //                                               0.05,
              //                                       // width: MediaQuery.of(context)
              //                                       //     .size
              //                                       //     .width *
              //                                       //     0.35,
              //                                       color: Color.fromARGB(
              //                                           255, 2, 77, 139),
              //                                       child: TextButton(
              //                                           onPressed: () {
              //                                             Future.delayed(
              //                                                 const Duration(
              //                                                     milliseconds:
              //                                                         1000),
              //                                                 () async {
              //                                               _createInterstitialAd();
              //                                               _interstitialAd!
              //                                                   .show();
              //                                             });
              //                                             Navigator.push(
              //                                               context,
              //                                               MaterialPageRoute(
              //                                                   builder: (context) => ViewImage(
              //                                                       showListData!
              //                                                           .first,
              //                                                       webViewController,
              //                                                       refreshController!)),
              //                                             );
              //                                           },
              //                                           child: Text(
              //                                             "Watch Video",
              //                                             style: TextStyle(
              //                                               color: Colors.white,
              //                                               fontSize: 11.sp,
              //                                             ),
              //                                           )),
              //
              //                                       //  TextButton(
              //                                       //     onPressed: () => (i.isVideo == true)?
              //                                       //         downloadVideo(i) : downloadImage(i),
              //                                       //     child: i.listFeedImagesUrl!
              //                                       //             .isEmpty
              //                                       //         ? Text("Download")
              //                                       //         : Text(
              //                                       //             "Download All"))
              //                                     )
              //                                   ],
              //                                 ),
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   )
              //                 : Container()
              //             : SingleChildScrollView(
              //                 physics: NeverScrollableScrollPhysics(),
              //                 child: Container(
              //                   width: MediaQuery.of(context).size.width,
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   height: (MediaQuery.of(context).size.height *
              //                               1 /
              //                               3 +
              //                           120 *
              //                               (((showListData!.length % 2) == 1)
              //                                   ? ((showListData!.length / 2)
              //                                           .floor() +
              //                                       1)
              //                                   : ((showListData!.length / 2)
              //                                       .floor())) /
              //                               showListData!.length) *
              //                       (((showListData!.length % 2) == 1)
              //                           ? ((showListData!.length / 2).floor() +
              //                               1)
              //                           : ((showListData!.length / 2).floor())),
              //                   // MediaQuery.of(context).size.height * ((showListData!.length / 2 +1 )/3) + 20*3 +  MediaQuery.of(context).size.height * 0.12,
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //                   //chiều cao của khung gridview
              //
              //                   child: Card(
              //                     child: Container(
              //                       color: Colors.blueGrey,
              //                       child: Column(
              //                         mainAxisSize: MainAxisSize.max,
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.start,
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.center,
              //                         children: [
              //                           GridView.builder(
              //                             // physics: AlwaysScrollableScrollPhysics(),
              //                             physics:
              //                                 NeverScrollableScrollPhysics(),
              //                             shrinkWrap: true,
              //                             scrollDirection: Axis.vertical,
              //                             cacheExtent: 500,
              //                             gridDelegate:
              //                                 SliverGridDelegateWithFixedCrossAxisCount(
              //                                     crossAxisCount: 2,
              //                                     childAspectRatio: 10 / 16,
              //                                     crossAxisSpacing:
              //                                         MediaQuery.of(context)
              //                                                 .size
              //                                                 .width *
              //                                             0.03,
              //                                     mainAxisSpacing: 20),
              //                             itemCount: showListData!.length,
              //                             // SliverGridDelegateWithMaxCrossAxisExtent(
              //                             //   maxCrossAxisExtent: maxCrossAxisExtent),
              //                             itemBuilder: (BuildContext context,
              //                                 int index) {
              //                               return Container(
              //                                 child: Column(
              //                                   mainAxisAlignment:
              //                                       MainAxisAlignment
              //                                           .spaceEvenly,
              //                                   children: [
              //                                     Container(
              //                                       height:
              //                                           MediaQuery.of(context)
              //                                                   .size
              //                                                   .height *
              //                                               1 /
              //                                               4,
              //                                       child: GestureDetector(
              //                                         // onTap: () => Navigator.push(
              //                                         //   context,
              //                                         //   MaterialPageRoute(
              //                                         //       builder: (context) =>
              //                                         //           ViewImage(i)
              //                                         //           ),
              //                                         // ),
              //                                         child: ClipRRect(
              //                                             borderRadius:
              //                                                 BorderRadius
              //                                                         .circular!(
              //                                                     16),
              //                                             child: (showListData![
              //                                                             index]
              //                                                         .isVideo ==
              //                                                     true)
              //                                                 ? ExtendedImage
              //                                                     .memory(
              //                                                     showListData![
              //                                                             index]
              //                                                         .thumbnail!,
              //                                                     // i,
              //                                                     // clearMemoryCacheWhenDispose:
              //                                                     //     true,
              //                                                     // fit: BoxFit.cover,
              //                                                   )
              //                                                 // FlickVideoPlayer(
              //                                                 //         flickVideoWithControls:
              //                                                 //             FlickVideoWithControls(
              //                                                 //           controls:
              //                                                 //               FlickPortraitControls(
              //                                                 //             progressBarSettings:
              //                                                 //                 FlickProgressBarSettings(
              //                                                 //               playedColor:
              //                                                 //                   Colors.green,
              //                                                 //             ),
              //                                                 //           ),
              //                                                 //           videoFit:
              //                                                 //               BoxFit.fitHeight,
              //                                                 //         ),
              //                                                 //         flickManager:
              //                                                 //             FlickManager(
              //                                                 //                 autoInitialize:
              //                                                 //                     true,
              //                                                 //                 // getPlayerControlsTimeout: ,
              //                                                 //                 autoPlay: false,
              //                                                 //                 videoPlayerController:
              //                                                 //                     VideoPlayerController
              //                                                 //                         .networkUrl(
              //                                                 //                   Uri.parse(showListData![
              //                                                 //                           index]
              //                                                 //                       .displayUrl!),
              //                                                 //                 )),
              //                                                 //       )
              //                                                 : ExtendedImage
              //                                                     .network(
              //                                                     showListData![
              //                                                             index]
              //                                                         .displayUrl!,
              //                                                     // i,
              //                                                     clearMemoryCacheWhenDispose:
              //                                                         true,
              //                                                     fit: BoxFit
              //                                                         .cover,
              //                                                   )),
              //                                       ),
              //                                     ),
              //                                     Row(
              //                                       mainAxisAlignment:
              //                                           MainAxisAlignment
              //                                               .spaceEvenly,
              //                                       children: [
              //                                         Container(
              //                                           width: 80.w,
              //                                           height: MediaQuery.of(
              //                                                       context)
              //                                                   .size
              //                                                   .height *
              //                                               0.05,
              //                                           // width: MediaQuery.of(context)
              //                                           //     .size
              //                                           //     .width *
              //                                           //     0.35,
              //                                           color: Color.fromARGB(
              //                                               255, 2, 77, 139),
              //                                           child: TextButton(
              //                                               onPressed: () {
              //                                                 Future.delayed(
              //                                                     const Duration(
              //                                                         milliseconds:
              //                                                             1000),
              //                                                     () async {
              //                                                   // bool isReady = (await AppLovinMAX
              //                                                   //     .isRewardedAdReady(
              //                                                   //     ApplovinService
              //                                                   //         .rewardedAdUnit!))!;
              //                                                   // if (isReady) {
              //                                                   //   AppLovinMAX.showRewardedAd(
              //                                                   //       ApplovinService
              //                                                   //           .rewardedAdUnit!);
              //                                                   // }
              //                                                 });
              //
              //                                                 downloadVideo(
              //                                                     showListData![
              //                                                         index]);
              //                                               },
              //                                               child: Text(
              //                                                 "Download",
              //                                                 style: TextStyle(
              //                                                   color: Colors
              //                                                       .white,
              //                                                   fontSize: 11.sp,
              //                                                 ),
              //                                               )),
              //
              //                                           //  TextButton(
              //                                           //     onPressed: () => (i.isVideo == true)?
              //                                           //         downloadVideo(i) : downloadImage(i),
              //                                           //     child: i.listFeedImagesUrl!
              //                                           //             .isEmpty
              //                                           //         ? Text("Download")
              //                                           //         : Text(
              //                                           //             "Download All"))
              //                                         ),
              //                                         Container(
              //                                           width: 80.w,
              //                                           height: MediaQuery.of(
              //                                                       context)
              //                                                   .size
              //                                                   .height *
              //                                               0.05,
              //                                           // width: MediaQuery.of(context)
              //                                           //     .size
              //                                           //     .width *
              //                                           //     0.35,
              //                                           color: Color.fromARGB(
              //                                               255, 2, 77, 139),
              //                                           child: TextButton(
              //                                               onPressed: () {
              //                                                 Future.delayed(
              //                                                     const Duration(
              //                                                         milliseconds:
              //                                                             1000),
              //                                                     () async {
              //                                                   _createInterstitialAd();
              //                                                   _interstitialAd!
              //                                                       .show();
              //                                                 });
              //                                                 Navigator.push(
              //                                                   context,
              //                                                   MaterialPageRoute(
              //                                                       builder: (context) => ViewImage(
              //                                                           showListData![
              //                                                               index],
              //                                                           webViewController,
              //                                                           refreshController!)),
              //                                                 );
              //                                               },
              //                                               child: Text(
              //                                                 (showListData![index]
              //                                                             .isVideo ==
              //                                                         true)
              //                                                     ? "Watch Video"
              //                                                     : "View Image",
              //                                                 style: TextStyle(
              //                                                   color: Colors
              //                                                       .white,
              //                                                   fontSize: 11.sp,
              //                                                 ),
              //                                               )),
              //                                         )
              //                                       ],
              //                                     ),
              //                                   ],
              //                                 ),
              //                               );
              //                             },
              //                           ),
              //                           // Container(
              //                           //   height:  MediaQuery.of(context)
              //                           //       .size
              //                           //       .height *
              //                           //       0.28,
              //                           // )
              //                         ],
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               )
              //     : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isBannerAdLoaded
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox(),
    );
  }

  //Download image and video on button click
  void downloadData(dynamic inputData) async {
    if (inputData.listFeedImagesUrl! == null ||
        inputData.listFeedImagesUrl! == []) {
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "${inputData.id}_${inputData.shortcode}");
      Fluttertoast.showToast(
          msg: "Succesfully Downloaded",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      for (var i in inputData.listFeedImagesUrl) {
        var response = await Dio().get("${i.displayUrl}",
            options: Options(responseType: ResponseType.bytes));
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
            quality: 60, name: "${i.id}_${i.shortcode}");
      }
      Fluttertoast.showToast(
          msg: "Succesfully Downloaded",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  //**start of post screen code
  FlickManager? updateOneUrlFlickManager(List<InstaPost> showListData) {
    return FlickManager(
        autoPlay: false,
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(showListData[0].displayUrl!),
        ));
  }

  void downloadVideo(InstaPost inputData) async {
    if (inputData.isVideo) {
      // final baseStorage = await getExternalStorageDirectory();
      if (inputData.id.toString().isEmpty &&
          inputData.shortcode.toString().isEmpty) {
        // int today = DateTime.now().
        FileDownloader.downloadFile(
            url: inputData.displayUrl!,
            name:
                "com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4",
            onProgress: (String? fileName, double? progress) {
              print('FILE fileName HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              Fluttertoast.showToast(
                  msg: "Succesfully Downloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onDownloadError: (String error) {
              Fluttertoast.showToast(
                  msg: "Please try it again",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
      } else {
        FileDownloader.downloadFile(
            url: inputData.displayUrl!,
            name:
                "com_helpfulapps_downloader_insta-${inputData.id}_${inputData.shortcode}",
            onProgress: (String? fileName, double? progress) {
              print('FILE fileName HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              Fluttertoast.showToast(
                  msg: "Succesfully Downloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onDownloadError: (String error) {
              Fluttertoast.showToast(
                  msg: "Please try it again",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
      }
    }
  }

  //get data from api
  Future showListURL(String urlPost) async {
    showListData = (await getPostAllData(urlPost)).cast<InstaPost>();
    if (showListData!.isNotEmpty) {
      lengthItem = showListData?.length;
    }
  }
//**end of post screen code
}
