import 'dart:typed_data';

import 'package:applovin_max/applovin_max.dart';
import 'package:dio/dio.dart';
import 'package:downloader_insta/admob_service/ads_service.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:fluttertoast/fluttertoast.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:extended_image/extended_image.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:video_player/video_player.dart';

import 'Component Widgets/Drawer.dart';
import 'Screens/DownloadPostScreen.dart';
import 'Screens/DownloadStoryScreen.dart';
import 'applovin_service/ads_service.dart';
import 'model/InstaPost.dart';
import 'model/instaApi.dart';
import 'model/InstaImage.dart';
import 'viewImage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:io' show Platform;
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await MobileAds.instance.initialize();
  await ScreenUtil.ensureScreenSize();
  Map? sdkConfiguration = await AppLovinMAX.initialize(
      'sZnb_XyqJrTNWyI_HEqiurTGU8G0uZTCM2hohx1h0T13mqvObuVIFCasx1AGRuHPrB906gn03zDRai8itwFhbo');
  runApp(MyApp());
}

const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // BannerAd? bannerAd;
  // bool isAdLoaded = false;
  // InterstitialAd? _interstitialAd;
  // RewardedAd? _rewardedAd;

  AppUpdateInfo? _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool _flexibleUpdateAvailable = false;


  FlutterInsta flutterInsta =
      FlutterInsta(); // create instance of FlutterInsta class
  TextEditingController usernameController = TextEditingController();
  TabController? tabController;

  String? username, followers = " ", following, bio, website, profileimage;

  List<String>? listFeedImages;
  bool pressed = false;
  bool downloading = false;

  String prefix = "https://www.instagram.com/p/";

  TextEditingController postUrlController = TextEditingController();

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

  final MaxNativeAdViewController _nativeAdViewController =
      MaxNativeAdViewController();

  MaxAd? nativeAd1;


  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  double progress = 0;
  var urlController = TextEditingController();
  // var initialUrl = "https://www.google.com/";

  String initialUrl =
      // "https://instagram.fsgn2-10.fna.fbcdn.net/o1/v/t16/f1/m69/GICWmABrFzu-Ax0DABFXYwcJHwg3bkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-10.fna.fbcdn.net&_nc_cat=109&vs=987154402357115_3229001429&_nc_vs=HBkcFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HSUNXbUFCckZ6dS1BeDBEQUJGWFl3Y0pId2czYmtZTEFBQUYVAALIAQAoABgAGwGIB3VzZV9vaWwBMBUAACbAnO6gz8eHQBUCKAJDMywXQEcmZmZmZmYYEmRhc2hfYmFzZWxpbmVfMV92MREAde4HAA%3D%3D&_nc_rid=9def2335ed&ccb=9-4&oh=00_AfC7tV1mO7vo_zyjdYVMcOO0BpElfA_IUngF2Hlz40aHlQ&oe=6558A56F&_nc_sid=4f4799"
  "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m69/GMDLoRc_ExR41Z0CAHLm2TWwC1pUbkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=3168204693473839_2317145144&_nc_vs=HBksFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HTURMb1JjX0V4UjQxWjBDQUhMbTJUV3dDMXBVYmtZTEFBQUYVAALIAQAVAhg6cGFzc3Rocm91Z2hfZXZlcnN0b3JlL0dLMktxeGRaaWlnS3RpSURBRUdnczZveXJzUnZia1lMQUFBRhUCAsgBACgAGAAbAYgHdXNlX29pbAEwFQAAJqSB7u%2BUpcQ%2FFQIoAkMzLBdAIrtkWhysCBgSZGFzaF9iYXNlbGluZV8xX3YxEQB17gcA&_nc_rid=6a81edf6ea&ccb=9-4&oh=00_AfAN__njHdfRXPorzbK2PlzFwZaHeb2WzrII7xlYbO_vhQ&oe=655880FD&_nc_sid=4f4799"

  ;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      checkForUpdate();
    });

    refreshController = PullToRefreshController(
        onRefresh: () {
       webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black87));

    // _initBannerAd();
    // _createRewardedAd();
    // _createInterstitialAd();

    // initializeBannerAds();
    // initializeMRecAds();
    _nativeAdViewController.loadAd();
    initializeInterstitialAds();
    initializeRewardedAd();
  }

  @override
  void dispose() {
    // super.dispose();
    // _interstitialAd?.dispose();
    // _rewardedAd?.dispose();
    // _rewardedInterstitialAd?.dispose();
  }

  //start of flutter Applovin Ad
  void initializeNativeAds() {
    _nativeAdViewController.loadAd();
  }

  void initializeBannerAds() {
    // Banners are automatically sized to 320x50 on phones and 728x90 on tablets
    AppLovinMAX.createBanner(
        ApplovinService.bannerAdUnitScreen!, AdViewPosition.bottomCenter);
  }

  void initializeMRecAds() {
    // MRECs are sized to 300x250 on phones and tablets
    AppLovinMAX.createMRec(
        ApplovinService.mrecAdUnitScreen!, AdViewPosition.centered);
  }

  void initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ' + ad.networkName);

        // Reset retry attempt
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        int retryDelay = pow(2, min(6, _interstitialRetryAttempt)).toInt();

        print('Interstitial ad failed to load with code ' +
            error.code.toString() +
            ' - retrying in ' +
            retryDelay.toString() +
            's');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial("e5b9327c1c3d7cb6");
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    ));

    // Load the first interstitial
    Future.delayed(Duration(milliseconds: 1000), () {
      AppLovinMAX.loadInterstitial("e5b9327c1c3d7cb6");
    });
  }

  void initializeRewardedAd() {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
          print('Rewarded ad loaded from ' + ad.networkName);

          // Reset retry attempt
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;

          int retryDelay = pow(2, min(6, _rewardedAdRetryAttempt)).toInt();
          print('Rewarded ad failed to load with code ' +
              error.code.toString() +
              ' - retrying in ' +
              retryDelay.toString() +
              's');

          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(ApplovinService.rewardedAdUnit!);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
        onAdReceivedRewardCallback: (ad, reward) {}));
  }

  void loadRewardedAd() {
    AppLovinMAX.loadRewardedAd(ApplovinService.rewardedAdUnit!);
  }

  //end of flutter Applovin Ad

  // //start of flutter Google Admob Ad
  // void _createInterstitialAd() {
  //   InterstitialAd.load(
  //       adUnitId: AdsMobService.interstitialAdUnit!,
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //           onAdLoaded: (ad) => _interstitialAd = ad,
  //           onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null));
  // }
  //
  // void _showInterstitialAd() {
  //   if (_interstitialAd != null) {
  //     _interstitialAd!.fullScreenContentCallback =
  //         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //       ad.dispose();
  //       _createInterstitialAd();
  //     }, onAdFailedToShowFullScreenContent: (ad, error) {
  //       ad.dispose();
  //       _createInterstitialAd();
  //     });
  //     _interstitialAd!.show();
  //     _interstitialAd = null;
  //   }
  // }
  //
  // void _initBannerAd() {
  //   bannerAd = BannerAd(
  //       size: AdSize.fluid,
  //       adUnitId: AdsMobService.bannerAdUnit! // test ad id
  //       // 'ca-app-pub-4759549056554403/3979113467'
  //       ,
  //       listener: AdsMobService.bannerAdListener,
  //       request: const AdRequest())
  //     ..load();
  // }
  //
  // void _createRewardedAd() {
  //   RewardedAd.load(
  //       adUnitId: AdsMobService.rewardedAdUnit,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //           onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
  //           onAdFailedToLoad: (LoadAdError error) =>
  //               setState(() => _rewardedAd = null)));
  // }
  //
  // void _showRewardedAd() {
  //   if (_rewardedAd != null) {
  //     _rewardedAd!.fullScreenContentCallback =
  //         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //       ad.dispose();
  //       _createRewardedAd();
  //     }, onAdFailedToShowFullScreenContent: (ad, error) {
  //       ad.dispose();
  //       _createRewardedAd();
  //     });
  //     _rewardedAd!.show(
  //         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) =>
  //             setState(() => _rewardedScore++));
  //     _rewardedAd = null;
  //   }
  // }

  //end of flutter Google Admob Ad

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize:  Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height));

    return Scaffold(
      // bottomNavigationBar: bannerAd != null
      //     ? SizedBox(
      //         height: bannerAd!.size.height.toDouble(),
      //         width: bannerAd!.size.width.toDouble(),
      //         child: AdWidget(ad: bannerAd!),
      //       )
      //     : const SizedBox(),
      key:_scaffoldKey,
      drawer: drawerForScreen(context),
      appBar: AppBar(
        // title: const Text('User\'s Details'),
        title: const Text('Download Post'),
      ),
      body: downloadPostScreen(),
      bottomNavigationBar: MaxAdView(
          adUnitId: ApplovinService.bannerAdUnitScreen!,
          adFormat: AdFormat.banner,
          isAutoRefreshEnabled: true,
          listener: AdViewAdListener(
              onAdLoadedCallback: (ad) {},
              onAdLoadFailedCallback: (adUnitId, error) {},
              onAdClickedCallback: (ad) {},
              onAdExpandedCallback: (ad) {},
              onAdCollapsedCallback: (ad) {}))
      // isAdLoaded
      //     ? SizedBox(
      //         height: bannerAd!.size.height.toDouble(),
      //         width: bannerAd!.size.width.toDouble(),
      //         child: AdWidget(ad: bannerAd!),
      //       )
      //     : const SizedBox()
      ,
    );
  }

//get data from api
  // Future printDetails(String username) async {
  //   showListData = await getAllData(username);
  //   await flutterInsta.getProfileData(username);
  //   setState(() {
  //     this.username = flutterInsta.username; //username
  //     this.followers = flutterInsta.followers; //number of followers
  //     this.following = flutterInsta.following; // number of following
  //     this.website = flutterInsta.website; // bio link
  //     this.bio = flutterInsta.bio; // Bio
  //     this.profileimage = flutterInsta.imgurl; // Profile picture URL
  //     this.listFeedImages = flutterInsta.feedImagesUrl;
  //     // print(followers);
  //   });
  // }

  Widget downloadPostScreen() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      // labelText: 'Enter username',
                      labelText: 'Enter post url',
                    ),
                    controller: postUrlController,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Text("Show Details"),
                    onPressed: () async {
                      await showListURL(postUrlController.text);
                      Future.delayed(
                        const Duration(seconds: 1),
                        () {
                          setState(() {
                            if (postUrlController.text.contains(prefix)) {
                              pressed = true;
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(' URL post can\'t be found'),
                                      content: Text(
                                          'We can\t found your post url. Please wait a few minutes before you try again and make sure you got right url.'),
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
                    },
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Clear"),
                    onPressed: () {
                      setState(() {
                        postUrlController.text = '';
                        pressed = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            //Native ad
            // Container(
            //   margin: const EdgeInsets.all(8.0),
            //   height: 300,
            //   child: MaxNativeAdView(
            //     adUnitId: ApplovinService.nativeAdMSmallUnit,
            //     // ApplovinService.nativeAdMediumUnit,
            //     controller: _nativeAdViewController,
            //     listener: NativeAdListener(onAdLoadedCallback: (ad) {
            //       print('Native ad loaded from ${ad.networkName}');
            //
            //       setState(() {
            //         _nativeAdViewController.loadAd();
            //         _mediaViewAspectRatio = ad.nativeAd?.mediaContentAspectRatio ?? _kMediaViewAspectRatio;
            //       });
            //     },
            //         onAdLoadFailedCallback: (adUnitId, error) {
            //       print('Native ad failed to load with error code ${error.code} and message: ${error.message}');
            //     },
            //         onAdClickedCallback: (ad) {
            //       print('Native ad clicked');
            //     },
            //         onAdRevenuePaidCallback: (ad) {
            //       print('Native ad revenue paid: ${ad.revenue}');
            //     }),
            //     child: Container(
            //       color: const Color(0xffefefef),
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Container(
            //                 padding: const EdgeInsets.all(4.0),
            //                 child: const MaxNativeAdIconView(
            //                   width: 48,
            //                   height: 48,
            //                 ),
            //               ),
            //               Flexible(
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     MaxNativeAdTitleView(
            //                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            //                       maxLines: 1,
            //                       overflow: TextOverflow.visible,
            //                     ),
            //                     MaxNativeAdAdvertiserView(
            //                       style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
            //                       maxLines: 1,
            //                       overflow: TextOverflow.fade,
            //                     ),
            //                     MaxNativeAdStarRatingView(
            //                       size: 10,
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               const MaxNativeAdOptionsView(
            //                 width: 20,
            //                 height: 20,
            //               ),
            //             ],
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             children: [
            //               Flexible(
            //                 child: MaxNativeAdBodyView(
            //                   style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            //                   maxLines: 3,
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           const SizedBox(height: 8),
            //           Expanded(
            //             child: AspectRatio(
            //               aspectRatio: _mediaViewAspectRatio,
            //               child: const MaxNativeAdMediaView(),
            //             ),
            //           ),
            //           const SizedBox(
            //             width: double.infinity,
            //             child: MaxNativeAdCallToActionView(
            //               style: ButtonStyle(
            //                 backgroundColor: MaterialStatePropertyAll<Color>(Color(0xff2d545e)),
            //                 textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //MREC ad
            MaxAdView(
                adUnitId: ApplovinService.mrecAdUnitScreen!,
                adFormat: AdFormat.mrec,
                listener: AdViewAdListener(
                    onAdLoadedCallback: (ad) {},
                    onAdLoadFailedCallback: (adUnitId, error) {},
                    onAdClickedCallback: (ad) {},
                    onAdExpandedCallback: (ad) {},
                    onAdCollapsedCallback: (ad) {})),
            // Container(
            //   width: 300.w,
            //   height: 500.h,
            //   child:
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(16),
            //     child: InAppWebView(
            //       onLoadStart: (controller, url) {
            //         // var v = url.toString();
            //         // setState(() {
            //         //   urlController.text = v;
            //         // });
            //       },
            //       onLoadStop: (controller, url) {
            //         refreshController!.endRefreshing();
            //       },
            //       pullToRefreshController: refreshController,
            //       onWebViewCreated: (controller) => webViewController = controller,
            //       initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
            //     ),
            //   ),
            // ),

            pressed
                ? showListData!.isNotEmpty
                    ? SingleChildScrollView(
                        //show up keyboard after unfullscreen image
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          //chiều cao của khung gridview
                          //chiều cao của khung gridview
                          //chiều cao của khung gridview
                          height: (MediaQuery.of(context).size.height * 1 / 3 +
                                  120 *
                                      (((showListData!.length % 2) == 1)
                                          ? ((showListData!.length / 2)
                                                  .floor() +
                                              1)
                                          : ((showListData!.length / 2)
                                              .floor())) /
                                      showListData!.length) *
                              (((showListData!.length % 2) == 1)
                                  ? ((showListData!.length / 2).floor() + 1)
                                  : ((showListData!.length / 2).floor())),
                          //chiều cao của khung gridview
                          //chiều cao của khung gridview
                          child: Card(
                            child: Container(
                              // margin: EdgeInsets.all(15),
                              // color: Color.fromRGBO(128, 120, 145, 255),
                              color: Colors.blueGrey,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GridView.builder(
                                    // physics: AlwaysScrollableScrollPhysics(),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    cacheExtent: 500,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 10 / 16,
                                            crossAxisSpacing:
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                            mainAxisSpacing: 20),
                                    itemCount: showListData!.length,
                                    // SliverGridDelegateWithMaxCrossAxisExtent(
                                    //   maxCrossAxisExtent: maxCrossAxisExtent),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              // height :210,
                                              // height: MediaQuery.of(context).size.height * 2/7,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  1 /
                                                  4,
                                              child: GestureDetector(
                                                // onTap: () => Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //       builder: (context) =>
                                                //           ViewImage(i)
                                                //           ),
                                                // ),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: (showListData![index]
                                                                .isVideo ==
                                                            true)
                                                        ? ExtendedImage.memory(
                                                            showListData![index]
                                                                .thumbnail!,
                                                            // i,
                                                            // clearMemoryCacheWhenDispose:
                                                            //     true,
                                                            // fit: BoxFit.cover,
                                                          )
                                                        // FlickVideoPlayer(
                                                        //         flickVideoWithControls:
                                                        //             FlickVideoWithControls(
                                                        //           controls:
                                                        //               FlickPortraitControls(
                                                        //             progressBarSettings:
                                                        //                 FlickProgressBarSettings(
                                                        //               playedColor:
                                                        //                   Colors.green,
                                                        //             ),
                                                        //           ),
                                                        //           videoFit:
                                                        //               BoxFit.fitHeight,
                                                        //         ),
                                                        //         flickManager:
                                                        //             FlickManager(
                                                        //                 autoInitialize:
                                                        //                     true,
                                                        //                 // getPlayerControlsTimeout: ,
                                                        //                 autoPlay: false,
                                                        //                 videoPlayerController:
                                                        //                     VideoPlayerController
                                                        //                         .networkUrl(
                                                        //                   Uri.parse(showListData![
                                                        //                           index]
                                                        //                       .displayUrl!),
                                                        //                 )),
                                                        //       )
                                                        : ExtendedImage.network(
                                                            showListData![index]
                                                                .displayUrl!,
                                                            // i,
                                                            clearMemoryCacheWhenDispose:
                                                                true,
                                                            fit: BoxFit.cover,
                                                          )),
                                              ),
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
                                                          bool isReady = (await AppLovinMAX
                                                              .isRewardedAdReady(
                                                                  ApplovinService
                                                                      .rewardedAdUnit!))!;
                                                          if (isReady) {
                                                            AppLovinMAX.showRewardedAd(
                                                                ApplovinService
                                                                    .rewardedAdUnit!);
                                                          }
                                                        });

                                                        (showListData![index]
                                                                    .isVideo ==
                                                                true)
                                                            ? downloadVideo(
                                                                showListData![
                                                                    index])
                                                            : downloadImage(
                                                                showListData![
                                                                    index]);
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
                                                          bool isReady = (await AppLovinMAX
                                                              .isInterstitialReady(
                                                                  ApplovinService
                                                                      .interstitialAdUnit!))!;
                                                          if (isReady) {
                                                            AppLovinMAX.showInterstitial(
                                                                ApplovinService
                                                                    .interstitialAdUnit!);
                                                          }
                                                        });
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewImage(
                                                                      showListData![
                                                                          index],webViewController,refreshController)),
                                                        );
                                                      },
                                                      child: Text(
                                                        (showListData![index]
                                                                    .isVideo ==
                                                                true)
                                                            ? "Watch Video"
                                                            : "View Image",
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
                                      );
                                    },
                                  ),
                                  // Expanded(
                                  //   child: GridView.count(
                                  //     // cacheExtent: 150,
                                  //     // primary: false,
                                  //     physics: ScrollPhysics(),
                                  //     keyboardDismissBehavior:
                                  //         ScrollViewKeyboardDismissBehavior.onDrag,
                                  //     crossAxisSpacing: 10,
                                  //     mainAxisSpacing: 10,
                                  //     crossAxisCount: 2,
                                  //     children: <Widget>[
                                  //       if (showListData!.isNotEmpty)
                                  //         for (InstaPost i in showListData!)
                                  //           Container(
                                  //             child: Column(
                                  //               children: [
                                  //                 Container(
                                  //                   height: 135,
                                  //                   child: GestureDetector(
                                  //                     // onTap: () => Navigator.push(
                                  //                     //   context,
                                  //                     //   MaterialPageRoute(
                                  //                     //       builder: (context) =>
                                  //                     //           ViewImage(i)
                                  //                     //           ),
                                  //                     // ),
                                  //                     child: ClipRRect(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(
                                  //                                 16),
                                  //                         child: (i.isVideo == true)
                                  //                             ? FlickVideoPlayer(
                                  //                                 flickVideoWithControls:
                                  //                                     FlickVideoWithControls(
                                  //                                   controls:
                                  //                                       FlickPortraitControls(
                                  //                                     progressBarSettings:
                                  //                                         FlickProgressBarSettings(
                                  //                                             playedColor:
                                  //                                                 Colors.green),
                                  //                                   ),
                                  //                                   videoFit: BoxFit
                                  //                                       .fitHeight,
                                  //                                 ),
                                  //                                 flickManager:
                                  //                                     FlickManager(
                                  //                                         autoPlay:
                                  //                                             false,
                                  //                                         videoPlayerController:
                                  //                                             VideoPlayerController
                                  //                                                 .networkUrl(
                                  //                                           Uri.parse(
                                  //                                               i.displayUrl!),
                                  //                                         )),
                                  //                               )
                                  //                             : ExtendedImage
                                  //                                 .network(
                                  //                                 i.displayUrl!,
                                  //                                 // i,
                                  //                                 clearMemoryCacheWhenDispose:
                                  //                                     true,
                                  //                                 clearMemoryCacheIfFailed:
                                  //                                     true,
                                  //                                 fit: BoxFit.cover,
                                  //                               )
                                  //                         // : ImageSlideshow(
                                  //                         //     // width: 120,
                                  //                         //     children: [
                                  //                         //         // ignore: unused_local_variable
                                  //                         //         for (InstaPost y
                                  //                         //             in i
                                  //                         //                 .listFeedImagesUrl!)
                                  //                         //           ExtendedImage
                                  //                         //               .network(
                                  //                         //             y.displayUrl!,
                                  //                         //             // i,
                                  //                         //             clearMemoryCacheWhenDispose:
                                  //                         //                 true,
                                  //                         //             clearMemoryCacheIfFailed:
                                  //                         //                 true,
                                  //                         //             fit: BoxFit
                                  //                         //                 .cover,
                                  //                         //           )
                                  //                         //       ]),
                                  //                         ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                     child: Container(
                                  //                   height: MediaQuery.of(context)
                                  //                           .size
                                  //                           .height -
                                  //                       MediaQuery.of(context)
                                  //                               .size
                                  //                               .height *
                                  //                           0.015,
                                  //                   width: MediaQuery.of(context)
                                  //                           .size
                                  //                           .width *
                                  //                       0.35,
                                  //                   color: Color.fromARGB(
                                  //                       255, 2, 77, 139),
                                  //                   child: TextButton(
                                  //                       onPressed: () {
                                  //                         // _showRewardedAd();
                                  //                         Future.delayed(
                                  //                             const Duration(
                                  //                                 milliseconds:
                                  //                                     1000),
                                  //                             () async {
                                  //                           bool isReady = (await AppLovinMAX
                                  //                               .isRewardedAdReady(
                                  //                                   ApplovinService
                                  //                                       .rewardedAdUnit!))!;
                                  //                           if (isReady) {
                                  //                             AppLovinMAX.showRewardedAd(
                                  //                                 ApplovinService
                                  //                                     .rewardedAdUnit!);
                                  //                           }
                                  //                         });
                                  //                         (i.isVideo == true)
                                  //                             ? downloadVideo(i)
                                  //                             : downloadImage(i);
                                  //                       },
                                  //                       child: Text(
                                  //                         "Download",
                                  //                         style: TextStyle(
                                  //                           color: Colors.white,
                                  //                         ),
                                  //                       )),
                                  //                 ))
                                  //
                                  //                 // Expanded(
                                  //                 //     child: TextButton(
                                  //                 //         onPressed: () => (i
                                  //                 //                     .isVideo ==
                                  //                 //                 true)
                                  //                 //             ? downloadVideo(i)
                                  //                 //             : downloadImage(i),
                                  //                 //         child: i.listFeedImagesUrl!
                                  //                 //                 .isEmpty
                                  //                 //             ? Text("Download")
                                  //                 //             : Text(
                                  //                 //                 "Download All")))
                                  //               ],
                                  //             ),
                                  //           ),
                                  //     ],
                                  //   ),
                                  // ),

                                  // Container(
                                  //   // color: Colors.blueGrey[200],
                                  //   height:
                                  //       MediaQuery.of(context).size.height * 0.28,
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container()
                : Container(),
          ],
        ),
      ),
    );
  }

  // Widget downloadPostScreen() {
  //   return SingleChildScrollView(
  //     child: Center(
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   decoration: InputDecoration(
  //                     contentPadding: EdgeInsets.all(10),
  //                     labelText: 'Enter post url',
  //                   ),
  //                   controller: postUrlController,
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   child: Text("Show Post"),
  //                   onPressed: () async {
  //                     await showListURL(postUrlController.text);

  //                     Future.delayed(Duration(seconds: 1), () {
  //                       flickManager = updateOneUrlFlickManager(showListData!)!;
  //                       setState(() {
  //                         pressed = true;

  //                         // _betterPlayerController =
  //                         //     updateOneUrlBetterPlayer(showListData);
  //                       });
  //                     });
  //                   },
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   style:
  //                       ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //                   child: const Text("Clear"),
  //                   onPressed: () {
  //                     setState(() {
  //                       postUrlController.text = '';
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //           pressed
  //               ? showListData!.isEmpty
  //                   ? Container()
  //                   : (showListData!.length < 2)
  //                       ? (showListData![0].isVideo == true)
  //                           ? Container(
  //                               width: MediaQuery.of(context).size.width * 0.7,
  //                               height: MediaQuery.of(context).size.width *
  //                                   0.7 *
  //                                   16 /
  //                                   9,
  //                               child: AspectRatio(
  //                                 aspectRatio: 16 / 9,
  //                                 child: Container(
  //                                   // height: MediaQuery.of(context)
  //                                   //     .size
  //                                   //     .height,
  //                                   // width: MediaQuery.of(context)
  //                                   //     .size
  //                                   //     .width,

  //                                   child: SingleChildScrollView(
  //                                     child: Column(
  //                                       children: (showListData!.isNotEmpty)
  //                                           ? [
  //                                               Container(
  //                                                 height: MediaQuery.of(context)
  //                                                         .size
  //                                                         .height *
  //                                                     0.85,
  //                                                 width: MediaQuery.of(context)
  //                                                         .size
  //                                                         .height *
  //                                                     0.85 *
  //                                                     16 /
  //                                                     9,
  //                                                 child: FlickVideoPlayer(
  //                                                     flickManager:
  //                                                         flickManager),

  //                                                 //  BetterPlayer.network(i)
  //                                               ),
  //                                               Container(
  //                                                 height: MediaQuery.of(context)
  //                                                         .size
  //                                                         .height -
  //                                                     MediaQuery.of(context)
  //                                                             .size
  //                                                             .height *
  //                                                         0.95,
  //                                                 width: MediaQuery.of(context)
  //                                                         .size
  //                                                         .width *
  //                                                     0.5,
  //                                                 color: Color.fromARGB(
  //                                                     255, 2, 77, 139),
  //                                                 child: TextButton(
  //                                                     onPressed: () async {
  //                                                       var status =
  //                                                           await Permission
  //                                                               .storage
  //                                                               .request();
  //                                                       if (status.isGranted) {
  //                                                         downloadVideo(
  //                                                             showListData![0]);
  //                                                       }
  //                                                     },
  //                                                     child: Text(
  //                                                       "Download Video",
  //                                                       style: TextStyle(
  //                                                         color: Colors.white,
  //                                                       ),
  //                                                     )),
  //                                               ),
  //                                             ]
  //                                           : [],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             )
  //                           : Container(
  //                               child: SingleChildScrollView(
  //                                 child: Column(
  //                                   children: (showListData!.isNotEmpty)
  //                                       ? [
  //                                           Container(
  //                                             height: MediaQuery.of(context)
  //                                                     .size
  //                                                     .height *
  //                                                 0.85,
  //                                             width: MediaQuery.of(context)
  //                                                     .size
  //                                                     .height *
  //                                                 0.85 *
  //                                                 16 /
  //                                                 9,
  //                                             child: ExtendedImage.network(
  //                                               showListData![0].displayUrl!,
  //                                               clearMemoryCacheWhenDispose:
  //                                                   true,
  //                                               clearMemoryCacheIfFailed: true,
  //                                               // fit: BoxFit.,
  //                                             ),
  //                                           ),
  //                                           Container(
  //                                             height: MediaQuery.of(context)
  //                                                     .size
  //                                                     .height -
  //                                                 MediaQuery.of(context)
  //                                                         .size
  //                                                         .height *
  //                                                     0.95,
  //                                             width: MediaQuery.of(context)
  //                                                     .size
  //                                                     .width *
  //                                                 0.5,
  //                                             color: Color.fromARGB(
  //                                                 255, 2, 77, 139),
  //                                             child: TextButton(
  //                                                 onPressed: () async {
  //                                                   var status =
  //                                                       await Permission.storage
  //                                                           .request();
  //                                                   if (status.isGranted) {
  //                                                     downloadVideo(
  //                                                         showListData![0]);
  //                                                   }
  //                                                 },
  //                                                 child: Text(
  //                                                   "Download Image",
  //                                                   style: TextStyle(
  //                                                     color: Colors.white,
  //                                                   ),
  //                                                 )),
  //                                           )
  //                                         ]
  //                                       : [],
  //                                 ),
  //                               ),
  //                             )
  //                       : SingleChildScrollView(
  //                           //show up keyboard after unfullscreen image
  //                           keyboardDismissBehavior:
  //                               ScrollViewKeyboardDismissBehavior.onDrag,
  //                           child: Container(
  //                             width: MediaQuery.of(context).size.width,
  //                             height: MediaQuery.of(context).size.height,
  //                             child: Card(
  //                               child: Container(
  //                                 // margin: EdgeInsets.all(15),
  //                                 child: Column(
  //                                   mainAxisSize: MainAxisSize.max,
  //                                   mainAxisAlignment: MainAxisAlignment.start,
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: [
  //                                     Expanded(
  //                                       child: GridView.count(
  //                                         // cacheExtent: 150,
  //                                         // primary: false,
  //                                         physics: ScrollPhysics(),
  //                                         keyboardDismissBehavior:
  //                                             ScrollViewKeyboardDismissBehavior
  //                                                 .onDrag,
  //                                         crossAxisSpacing: 10,
  //                                         mainAxisSpacing: 10,
  //                                         crossAxisCount: 2,
  //                                         children: <Widget>[
  //                                           if (showListData!.isNotEmpty)
  //                                             for (InstaPost i in showListData!)
  //                                               Container(
  //                                                 child: Column(
  //                                                   children: [
  //                                                     Container(
  //                                                       height: 135,
  //                                                       child: GestureDetector(
  //                                                         // onTap: () => Navigator.push(
  //                                                         //   context,
  //                                                         //   MaterialPageRoute(
  //                                                         //       builder: (context) =>
  //                                                         //           ViewImage(i)
  //                                                         //           ),
  //                                                         // ),
  //                                                         child: ClipRRect(
  //                                                             borderRadius:
  //                                                                 BorderRadius
  //                                                                     .circular(
  //                                                                         16),
  //                                                             child: (i.isVideo ==
  //                                                                     true)
  //                                                                 ? FlickVideoPlayer(
  //                                                                     flickVideoWithControls:
  //                                                                         FlickVideoWithControls(
  //                                                                       controls:
  //                                                                           FlickPortraitControls(
  //                                                                         progressBarSettings:
  //                                                                             FlickProgressBarSettings(playedColor: Colors.green),
  //                                                                       ),
  //                                                                       videoFit:
  //                                                                           BoxFit.fitHeight,
  //                                                                     ),
  //                                                                     flickManager: FlickManager(
  //                                                                         autoPlay: false,
  //                                                                         videoPlayerController: VideoPlayerController.network(
  //                                                                           i.displayUrl!,
  //                                                                         )),
  //                                                                   )
  //                                                                 : ExtendedImage
  //                                                                     .network(
  //                                                                     i.displayUrl!,
  //                                                                     // i,
  //                                                                     clearMemoryCacheWhenDispose:
  //                                                                         true,
  //                                                                     clearMemoryCacheIfFailed:
  //                                                                         true,
  //                                                                     fit: BoxFit
  //                                                                         .cover,
  //                                                                   )),
  //                                                       ),
  //                                                     ),
  //                                                     Expanded(
  //                                                         child: Container(
  //                                                       height: MediaQuery.of(
  //                                                                   context)
  //                                                               .size
  //                                                               .height -
  //                                                           MediaQuery.of(
  //                                                                       context)
  //                                                                   .size
  //                                                                   .height *
  //                                                               0.015,
  //                                                       width: MediaQuery.of(
  //                                                                   context)
  //                                                               .size
  //                                                               .width *
  //                                                           0.35,
  //                                                       color: Color.fromARGB(
  //                                                           255, 2, 77, 139),
  //                                                       child: TextButton(
  //                                                           onPressed: () async => (i
  //                                                                       .isVideo ==
  //                                                                   true)
  //                                                               ? downloadVideo(
  //                                                                   i)
  //                                                               : downloadImage(
  //                                                                   i),
  //                                                           child: Text(
  //                                                             "Download",
  //                                                             style: TextStyle(
  //                                                               color: Colors
  //                                                                   .white,
  //                                                             ),
  //                                                           )),
  //                                                     )
  //                                                         //  TextButton(
  //                                                         //     onPressed: () => (i.isVideo == true)?
  //                                                         //         downloadVideo(i) : downloadImage(i),
  //                                                         //     child: i.listFeedImagesUrl!
  //                                                         //             .isEmpty
  //                                                         //         ? Text("Download")
  //                                                         //         : Text(
  //                                                         //             "Download All"))
  //                                                         )
  //                                                   ],
  //                                                 ),
  //                                               ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     // Container(
  //                                     //   color: Colors.blueGrey[200],
  //                                     //   height:
  //                                     //       MediaQuery.of(context).size.height *
  //                                     //           0.28,
  //                                     // )
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         )
  //               : Container(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget homePage() {
  //   return SingleChildScrollView(
  //     child: Center(
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   decoration: InputDecoration(
  //                     contentPadding: EdgeInsets.all(10),
  //                     labelText: 'Enter username',
  //                   ),
  //                   controller: usernameController,
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   child: Text("Show Details"),
  //                   onPressed: () {
  //                     Future.delayed(
  //                       const Duration(seconds: 1),
  //                       () => setState(() {
  //                         pressed = true;
  //                         printDetails(usernameController.text); //get Data
  //                       }),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ElevatedButton(
  //                   style:
  //                       ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //                   child: Text("Clear"),
  //                   onPressed: () {
  //                     setState(() {
  //                       usernameController.text = '';
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //           pressed
  //               ? SingleChildScrollView(
  //                   //show up keyboard after unfullscreen image
  //                   keyboardDismissBehavior:
  //                       ScrollViewKeyboardDismissBehavior.onDrag,
  //                   child: Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     height: MediaQuery.of(context).size.height,
  //                     child: Card(
  //                       child: Container(
  //                         // margin: EdgeInsets.all(15),
  //                         child: Column(
  //                           mainAxisSize: MainAxisSize.max,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             // Container(
  //                             //   child: Row(
  //                             //       mainAxisAlignment:
  //                             //           MainAxisAlignment.spaceEvenly,
  //                             //       crossAxisAlignment: CrossAxisAlignment.end,
  //                             //       children: [
  //                             //         Column(
  //                             //           children: [
  //                             //             ClipRRect(
  //                             //               borderRadius:
  //                             //                   BorderRadius.circular(100),
  //                             //               child: Image.network(
  //                             //                 "$profileimage",
  //                             //                 width: 73,
  //                             //               ),
  //                             //             ),
  //                             //             Text(
  //                             //               "$username",
  //                             //               style: TextStyle(
  //                             //                 fontWeight: FontWeight.bold,
  //                             //                 fontSize: 18,
  //                             //               ),
  //                             //             ),
  //                             //           ],
  //                             //         ),
  //                             //         SizedBox(
  //                             //           width: 10,
  //                             //         ),
  //                             //         Expanded(
  //                             //           child: Column(
  //                             //             crossAxisAlignment:
  //                             //                 CrossAxisAlignment.stretch,
  //                             //             // mainAxisAlignment:
  //                             //             //     MainAxisAlignment.spaceAround,
  //                             //             children: [
  //                             //               Row(
  //                             //                 mainAxisAlignment:
  //                             //                     MainAxisAlignment.spaceEvenly,
  //                             //                 children: [
  //                             //                   Text(
  //                             //                     "Followers\n$followers",
  //                             //                     style: TextStyle(
  //                             //                       fontSize: 15,
  //                             //                     ),
  //                             //                   ),
  //                             //                   Text(
  //                             //                     "Following\n$following",
  //                             //                     style: TextStyle(
  //                             //                       fontSize: 15,
  //                             //                     ),
  //                             //                   ),
  //                             //                 ],
  //                             //               ),
  //                             //               Text(
  //                             //                 "${bio ?? ''}",
  //                             //                 style: TextStyle(
  //                             //                   fontSize: 15,
  //                             //                 ),
  //                             //               ),
  //                             //               Text(
  //                             //                 "${website ?? ''}",
  //                             //                 style: TextStyle(
  //                             //                   fontSize: 15,
  //                             //                 ),
  //                             //               ),
  //                             //             ],
  //                             //           ),
  //                             //         ),
  //                             //       ]),
  //                             // ),

  //                             Expanded(
  //                               child: GridView.count(
  //                                 // cacheExtent: 150,
  //                                 // primary: false,
  //                                 physics: ScrollPhysics(),
  //                                 keyboardDismissBehavior:
  //                                     ScrollViewKeyboardDismissBehavior.onDrag,
  //                                 crossAxisSpacing: 10,
  //                                 mainAxisSpacing: 10,
  //                                 crossAxisCount: 2,
  //                                 children: <Widget>[
  //                                   if (showListData!.isNotEmpty)
  //                                     for (InstaImage i in showListData!)
  //                                       Container(
  //                                         child: Column(
  //                                           children: [
  //                                             Container(
  //                                               height: 135,
  //                                               child: GestureDetector(
  //                                                 onTap: () => Navigator.push(
  //                                                   context,
  //                                                   MaterialPageRoute(
  //                                                       builder: (context) =>
  //                                                           ViewImage(i)),
  //                                                 ),
  //                                                 child: ClipRRect(
  //                                                   borderRadius:
  //                                                       BorderRadius.circular(
  //                                                           16),
  //                                                   child: i.listFeedImagesUrl!
  //                                                           .isEmpty
  //                                                       ? ExtendedImage.network(
  //                                                           i.displayUrl!,
  //                                                           // i,
  //                                                           clearMemoryCacheWhenDispose:
  //                                                               true,
  //                                                           clearMemoryCacheIfFailed:
  //                                                               true,
  //                                                           fit: BoxFit.cover,
  //                                                         )
  //                                                       : ImageSlideshow(
  //                                                           // width: 120,
  //                                                           children: [
  //                                                               // ignore: unused_local_variable
  //                                                               for (InstaImage y
  //                                                                   in i
  //                                                                       .listFeedImagesUrl!)
  //                                                                 ExtendedImage
  //                                                                     .network(
  //                                                                   y.displayUrl!,
  //                                                                   // i,
  //                                                                   clearMemoryCacheWhenDispose:
  //                                                                       true,
  //                                                                   clearMemoryCacheIfFailed:
  //                                                                       true,
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 )
  //                                                             ]),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             Expanded(
  //                                                 child: TextButton(
  //                                                     onPressed: () =>
  //                                                         downloadData(i),
  //                                                     child: i.listFeedImagesUrl!
  //                                                             .isEmpty
  //                                                         ? Text("Download")
  //                                                         : Text(
  //                                                             "Download All")))
  //                                           ],
  //                                         ),
  //                                       ),
  //                                 ],
  //                               ),
  //                             ),
  //                             // Container(
  //                             //   color: Colors.blueGrey[200],
  //                             //   height:
  //                             //       MediaQuery.of(context).size.height * 0.28,
  //                             // )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 )
  //               : Container(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget checkInfoNull(String inpuInfo) {
  //   if (inpuInfo.isEmpty || inpuInfo == null)
  //     return Text(
  //       "",
  //       style: TextStyle(
  //         fontSize: 15,
  //       ),
  //     );
  //   else
  //     return Text(
  //       "",
  //       style: TextStyle(
  //         fontSize: 15,
  //       ),
  //     );
  // }

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

  void _saveNetworkImage(InstaPost inputData) async {
    var response = await Dio().get(inputData.displayUrl!,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "${inputData.id}_${inputData.shortcode}");
    print(result);
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

  void downloadImage(dynamic inputData) async {
    if (inputData.id.toString().isEmpty &&
        inputData.shortcode.toString().isEmpty) {
      //com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.jpg");

      Fluttertoast.showToast(
          msg: "Succesfully Downloaded",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      //com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "com_helpfulapps_downloader_insta-${inputData.id}_${inputData.shortcode}.jpg");

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

  //get data from api
  Future showListURL(String urlPost) async {
    showListData = (await getPostAllData(urlPost)).cast<InstaPost>();
    if (showListData!.isNotEmpty) {
      lengthItem = showListData?.length;
    }
  }
//**end of post screen code
}
