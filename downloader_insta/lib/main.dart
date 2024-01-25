import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:downloader_insta/admob_service/AdsMobService.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:extended_image/extended_image.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:video_player/video_player.dart';

import 'Component Widgets/Drawer.dart';
import 'Component Widgets/textfieldButton.dart';
import 'admob_service/AdObject/nativeAdItemWidget.dart';
import 'model/InstaPost.dart';
import 'viewImage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.updateRequestConfiguration(
  //     RequestConfiguration(testDeviceIds: ['0A93006097F15BE1434D7057D0484CF9']));
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

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
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  InterstitialAd? interstitialAd;
  bool isInterstitialAdLoaded = false;
  RewardedAd? rewardedAd;
  bool isRewardedAdLoaded = false;
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;
  NativeAd? nativeAdItem;
  bool isNativeAdItemLoaded = false;
  final double _adAspectRatioMedium = (370 / 355);
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool isRewardedInterstitialAdLoaded = false;


  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final itemNativeAdKey = GlobalKey<itemNativeAdState>();
  // final textfieldButtonKey = GlobalKey<TextfieldButtonState>();

  // FlutterInsta flutterInsta =
  //     FlutterInsta(); // create instance of FlutterInsta class
  TextEditingController usernameController = TextEditingController();
  TabController? tabController;

  String? username, followers = " ", following, bio, website;

  List<String>? listFeedImages;
  bool pressed = false;
  bool downloading = false;

  String prefix = "https://www.instagram.com/p/";

  TextEditingController postUrlController = TextEditingController();

  // bool pressed = false;
  InstaPost instaPost = InstaPost();
  bool isLoadingAttaching = false;
  List<InstaPost>? listItemAttaching = [];
  List<InstaPost>? showListData = [];
  int? lengthItem = 0;
  late FlickManager flickManager = FlickManager(
    videoPlayerController: VideoPlayerController.networkUrl(Uri.parse("")
        // "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m82/7D4FDF47415AE704D2D8CB62F61667A5_video_dashinit.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uNzIwLmNsaXBzLmJhc2VsaW5lIn0&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=1190291614973924_2860471228&_nc_vs=HBksFQIYT2lnX3hwdl9yZWVsc19wZXJtYW5lbnRfcHJvZC83RDRGREY0NzQxNUFFNzA0RDJEOENCNjJGNjE2NjdBNV92aWRlb19kYXNoaW5pdC5tcDQVAALIAQAVABgkR0thb1FBUFFVWF9XR2ZNRUFGZnhZNld3RkIwc2JwUjFBQUFGFQICyAEAKAAYABsAFQAAJrisyICP8tY%2FFQIoAkMzLBdALpmZmZmZmhgSZGFzaF9iYXNlbGluZV8xX3YxEQB1%2FgcA&_nc_rid=266f0ba924&ccb=9-4&oh=00_AfD48lZyVRpcVEDGkD-2nRRokKWWdaou1_MPo6GWhRK3OA&oe=64A95754&_nc_sid=4f4799"
        ),
  );


  static const double _kMediaViewAspectRatio = 16 / 9;
  double _mediaViewAspectRatio = _kMediaViewAspectRatio;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  double progress = 0;
  var urlController = TextEditingController();

  // var initialUrl = "https://www.google.com/";

  String initialUrl =
      // "https://instagram.fsgn2-10.fna.fbcdn.net/o1/v/t16/f1/m69/GICWmABrFzu-Ax0DABFXYwcJHwg3bkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-10.fna.fbcdn.net&_nc_cat=109&vs=987154402357115_3229001429&_nc_vs=HBkcFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HSUNXbUFCckZ6dS1BeDBEQUJGWFl3Y0pId2czYmtZTEFBQUYVAALIAQAoABgAGwGIB3VzZV9vaWwBMBUAACbAnO6gz8eHQBUCKAJDMywXQEcmZmZmZmYYEmRhc2hfYmFzZWxpbmVfMV92MREAde4HAA%3D%3D&_nc_rid=9def2335ed&ccb=9-4&oh=00_AfC7tV1mO7vo_zyjdYVMcOO0BpElfA_IUngF2Hlz40aHlQ&oe=6558A56F&_nc_sid=4f4799"
      "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m69/GMDLoRc_ExR41Z0CAHLm2TWwC1pUbkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=3168204693473839_2317145144&_nc_vs=HBksFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HTURMb1JjX0V4UjQxWjBDQUhMbTJUV3dDMXBVYmtZTEFBQUYVAALIAQAVAhg6cGFzc3Rocm91Z2hfZXZlcnN0b3JlL0dLMktxeGRaaWlnS3RpSURBRUdnczZveXJzUnZia1lMQUFBRhUCAsgBACgAGAAbAYgHdXNlX29pbAEwFQAAJqSB7u%2BUpcQ%2FFQIoAkMzLBdAIrtkWhysCBgSZGFzaF9iYXNlbGluZV8xX3YxEQB17gcA&_nc_rid=6a81edf6ea&ccb=9-4&oh=00_AfAN__njHdfRXPorzbK2PlzFwZaHeb2WzrII7xlYbO_vhQ&oe=655880FD&_nc_sid=4f4799";

  Future<void> checkForUpdate() async {
    print('checking for Update');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          print('update available');
          update();
        }
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void update() async {
    print('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      print(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  void loadAllItems(List<InstaPost>? listItemAttaching, List<InstaPost>? showListData) async {
    showListData!.clear();
      setState(() {
        showListData = listItemAttaching;
      });


  }

  void _getMoreData() async {
    if (!isLoadingAttaching) {
      setState(() {
        isLoadingAttaching = true;
      });
      // List<InstaPost>? listItemAttaching = [];
      // List<InstaPost>? showListData = [];
      int firstIndex = 0;
      int lastIndex = 3;
      if(showListData!.isEmpty){
        showListData!.add(new InstaPost());
        showListData =showListData! + listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        print(showListData);
      }else{
        if(showListData!.length == listItemAttaching!.length){
          firstIndex = showListData!.length - 1;
          lastIndex += firstIndex;
          if(lastIndex > listItemAttaching!.length){
            lastIndex = listItemAttaching!.length;
          }
          showListData!.insert(lastIndex , new InstaPost());
          showListData =  showListData! + listItemAttaching!.getRange(firstIndex, lastIndex).toList();
          print(showListData);
        }else{
          firstIndex = showListData!.length;
          lastIndex += firstIndex;
          if(lastIndex > listItemAttaching!.length){
            lastIndex = listItemAttaching!.length;
          }
          showListData!.insert(firstIndex , new InstaPost());
          showListData =  showListData! + listItemAttaching!.getRange(firstIndex, lastIndex).toList();
          print(showListData);
        }

        // firstIndex = showListData!.length;
        // lastIndex += firstIndex;
        // if(lastIndex > listItemAttaching!.length){
        //   lastIndex = listItemAttaching!.length;
        // }
        // showListData!.insert(firstIndex , new InstaPost());
        // showListData =  showListData! + listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        // print(showListData);

      }

      setState(() {
        isLoadingAttaching = false;
      });
    }
  }

  //start of flutter Google Admob Ad
  void createInterstitialAd() {
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
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  void initBannerAd() {
    bannerAd = BannerAd(
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

  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdsMobService.rewardedAdUnit,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) => setState(() => rewardedAd = ad),
            onAdFailedToLoad: (LoadAdError error) =>
                setState(() => rewardedAd = null))) ;
  }

  void createRewardedInterstitialAd() {
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

  void createNativeAd() {
    nativeAd = NativeAd(
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
                size: 16.0))
    )
      ..load();
  }

  void createNativeAdItem() {
    nativeAdItem = NativeAd(

      // nativeAdOptions: ,
      factoryId: "nativeAdItem",
      adUnitId: AdsMobService.nativeAdItemUnit
      // AdsMobService.nativeAdUnit!
      ,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('nativeAdItem loaded.');
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
  //end of flutter Google Admob Ad



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate();

    });

    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black87));

    super.initState();

    initBannerAd();
    createRewardedAd();
    createInterstitialAd();
    createRewardedInterstitialAd();
    createNativeAd();
    createNativeAdItem();
  }

  @override
  void dispose() {
    nativeAdItem?.dispose();
    nativeAd?.dispose();
    rewardedAd?.dispose();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height));

    return Scaffold(

      key: _scaffoldKey,
      drawer: drawerForScreen(context),
      appBar: AppBar(
        // title: const Text('User\'s Details'),
        title: const Text('Download Post'),
      ),
      body: downloadPostScreen(),
      bottomNavigationBar: isBannerAdLoaded
          ? SizedBox(
              height: bannerAd!.size.height.toDouble(),
              width: bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          : const SizedBox(),
    );
  }


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
                      if(postUrlController.text.contains("/p/")){
                        if(showListData!.isEmpty && listItemAttaching!.isEmpty){
                          await showListURL(postUrlController.text);
                          Future.delayed(Duration(seconds: 1), ()
                          {
                            setState(() {
                              pressed = true;

                              // _betterPlayerController =
                              //     updateOneUrlBetterPlayer(showListData);
                            });
                          });
                        }
                        else{
                          showListData!.clear();
                          listItemAttaching!.clear();
                          await showListURL(postUrlController.text);
                          Future.delayed(Duration(seconds: 1), ()
                          {
                            setState(() {
                              pressed = true;

                              // _betterPlayerController =
                              //     updateOneUrlBetterPlayer(showListData);
                            });
                          });
                        }
                      }
                      else{
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Wrong url type'),
                            content: const Text('You must have the link like this: https://www.instagram.com/p/shortcode/'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }


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
            // TextfieldButton("post",pressed,key: textfieldButtonKey),
            (isNativeAdLoaded && nativeAd != null)
                ? SizedBox(
                    height: MediaQuery.of(context).size.width *
                        _adAspectRatioMedium,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: nativeAd!))
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
            ),


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
                                  ? ((showListData!.length / 2).floor() + 1 + 0.15.h)
                                  : ((showListData!.length / 2).floor())+ 0.15.h),
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

                                      if(index % 4 == 0){
                                        if(itemNativeAdKey != null){
                                          return const ItemNativeAd();
                                        }else{
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
                                                        borderRadius: BorderRadius
                                                            .circular!(16),
                                                        child: (showListData![index]
                                                            .isVideo ==
                                                            true)
                                                            ? ExtendedImage.memory(
                                                          showListData![index]
                                                              .thumbnail!,

                                                        )

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
                                                                  (rewardedAd != null) ?
                                                                  rewardedAd!.show(
                                                                      onUserEarnedReward:
                                                                          (AdWithoutView
                                                                      ad,
                                                                          RewardItem
                                                                          rewardItem) {
                                                                        (showListData![index]
                                                                            .isVideo ==
                                                                            true)
                                                                            ? downloadVideo(
                                                                            showListData![
                                                                            index])
                                                                            : downloadImage(
                                                                            showListData![
                                                                            index]);
                                                                      })
                                                                      : (showListData![index]
                                                                      .isVideo ==
                                                                      true)
                                                                      ? downloadVideo(
                                                                      showListData![
                                                                      index])
                                                                      : downloadImage(
                                                                      showListData![
                                                                      index]);
                                                                });

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

                                                                  createInterstitialAd();
                                                                  interstitialAd!.show();

                                                                  // _showInterstitialAd();
                                                                });
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ViewImage(
                                                                      showListData![
                                                                      index],
                                                                      webViewController,
                                                                      refreshController)),
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
                                                    )
                                                  ],
                                                ),

                                              ],
                                            ),
                                          );
                                        }
                                      }else{
                                        showListData!.removeWhere((item) => item == null);
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
                                                      borderRadius: BorderRadius
                                                          .circular!(16),
                                                      child: (showListData![index]
                                                          .isVideo ==
                                                          true)
                                                          ? ExtendedImage.memory(
                                                        showListData![index]
                                                            .thumbnail!,

                                                      )

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
                                                                (rewardedAd != null) ?
                                                                rewardedAd!.show(
                                                                    onUserEarnedReward:
                                                                        (AdWithoutView
                                                                    ad,
                                                                        RewardItem
                                                                        rewardItem) {
                                                                      (showListData![index]
                                                                          .isVideo ==
                                                                          true)
                                                                          ? downloadVideo(
                                                                          showListData![
                                                                          index])
                                                                          : downloadImage(
                                                                          showListData![
                                                                          index]);
                                                                    })
                                                                    : (showListData![index]
                                                                    .isVideo ==
                                                                    true)
                                                                    ? downloadVideo(
                                                                    showListData![
                                                                    index])
                                                                    : downloadImage(
                                                                    showListData![
                                                                    index]);
                                                              });

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

                                                                createInterstitialAd();
                                                                interstitialAd!.show();

                                                                // _showInterstitialAd();
                                                              });
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ViewImage(
                                                                    showListData![
                                                                    index],
                                                                    webViewController,
                                                                    refreshController)),
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
                                                  )
                                                ],
                                              ),

                                            ],
                                          ),
                                        );
                                      }

                                      // return ((index + 1) % 4 == 0)
                                      //
                                      //     ?
                                      // const ItemNativeAd()
                                      //     :
                                      //   Container(
                                      //   child: Column(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceEvenly,
                                      //     children: [
                                      //       Container(
                                      //         // height :210,
                                      //         // height: MediaQuery.of(context).size.height * 2/7,
                                      //         height: MediaQuery.of(context)
                                      //                 .size
                                      //                 .height *
                                      //             1 /
                                      //             4,
                                      //         child: GestureDetector(
                                      //           // onTap: () => Navigator.push(
                                      //           //   context,
                                      //           //   MaterialPageRoute(
                                      //           //       builder: (context) =>
                                      //           //           ViewImage(i)
                                      //           //           ),
                                      //           // ),
                                      //           child: ClipRRect(
                                      //               borderRadius: BorderRadius
                                      //                   .circular!(16),
                                      //               child: (showListData![index]
                                      //                           .isVideo ==
                                      //                       true)
                                      //                   ? ExtendedImage.memory(
                                      //                       showListData![index]
                                      //                           .thumbnail!,
                                      //                       // i,
                                      //                       // clearMemoryCacheWhenDispose:
                                      //                       //     true,
                                      //                       // fit: BoxFit.cover,
                                      //                     )
                                      //                   // FlickVideoPlayer(
                                      //                   //         flickVideoWithControls:
                                      //                   //             FlickVideoWithControls(
                                      //                   //           controls:
                                      //                   //               FlickPortraitControls(
                                      //                   //             progressBarSettings:
                                      //                   //                 FlickProgressBarSettings(
                                      //                   //               playedColor:
                                      //                   //                   Colors.green,
                                      //                   //             ),
                                      //                   //           ),
                                      //                   //           videoFit:
                                      //                   //               BoxFit.fitHeight,
                                      //                   //         ),
                                      //                   //         flickManager:
                                      //                   //             FlickManager(
                                      //                   //                 autoInitialize:
                                      //                   //                     true,
                                      //                   //                 // getPlayerControlsTimeout: ,
                                      //                   //                 autoPlay: false,
                                      //                   //                 videoPlayerController:
                                      //                   //                     VideoPlayerController
                                      //                   //                         .networkUrl(
                                      //                   //                   Uri.parse(showListData![
                                      //                   //                           index]
                                      //                   //                       .displayUrl!),
                                      //                   //                 )),
                                      //                   //       )
                                      //                   : ExtendedImage.network(
                                      //                       showListData![index]
                                      //                           .displayUrl!,
                                      //                       // i,
                                      //                       clearMemoryCacheWhenDispose:
                                      //                           true,
                                      //                       fit: BoxFit.cover,
                                      //                     )),
                                      //         ),
                                      //       ),
                                      //       Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.spaceEvenly,
                                      //         children: [
                                      //           Container(
                                      //             width: 80.w,
                                      //             height: MediaQuery.of(context)
                                      //                     .size
                                      //                     .height *
                                      //                 0.05,
                                      //             // width: MediaQuery.of(context)
                                      //             //     .size
                                      //             //     .width *
                                      //             //     0.35,
                                      //             color: Color.fromARGB(
                                      //                 255, 2, 77, 139),
                                      //             child: TextButton(
                                      //                 onPressed: () {
                                      //                   Future.delayed(
                                      //                       const Duration(
                                      //                           milliseconds:
                                      //                               1000),
                                      //                       () async {
                                      //                         (rewardedAd != null) ?
                                      //                     rewardedAd!.show(
                                      //                         onUserEarnedReward:
                                      //                             (AdWithoutView
                                      //                                     ad,
                                      //                                 RewardItem
                                      //                                     rewardItem) {
                                      //                       (showListData![index]
                                      //                                   .isVideo ==
                                      //                               true)
                                      //                           ? downloadVideo(
                                      //                               showListData![
                                      //                                   index])
                                      //                           : downloadImage(
                                      //                               showListData![
                                      //                                   index]);
                                      //                     })
                                      //                        : (showListData![index]
                                      //                             .isVideo ==
                                      //                         true)
                                      //                         ? downloadVideo(
                                      //                         showListData![
                                      //                         index])
                                      //                             : downloadImage(
                                      //                         showListData![
                                      //                         index]);
                                      //                   });
                                      //
                                      //                 },
                                      //                 child: Text(
                                      //                   "Download",
                                      //                   style: TextStyle(
                                      //                     color: Colors.white,
                                      //                     fontSize: 11.sp,
                                      //                   ),
                                      //                 )),
                                      //
                                      //             //  TextButton(
                                      //             //     onPressed: () => (i.isVideo == true)?
                                      //             //         downloadVideo(i) : downloadImage(i),
                                      //             //     child: i.listFeedImagesUrl!
                                      //             //             .isEmpty
                                      //             //         ? Text("Download")
                                      //             //         : Text(
                                      //             //             "Download All"))
                                      //           ),
                                      //           Container(
                                      //             width: 80.w,
                                      //             height: MediaQuery.of(context)
                                      //                     .size
                                      //                     .height *
                                      //                 0.05,
                                      //             // width: MediaQuery.of(context)
                                      //             //     .size
                                      //             //     .width *
                                      //             //     0.35,
                                      //             color: Color.fromARGB(
                                      //                 255, 2, 77, 139),
                                      //             child: TextButton(
                                      //                 onPressed: () {
                                      //                   Future.delayed(
                                      //                       const Duration(
                                      //                           milliseconds:
                                      //                               1000),
                                      //                       () async {
                                      //
                                      //                         createInterstitialAd();
                                      //                         interstitialAd!.show();
                                      //
                                      //                         // _showInterstitialAd();
                                      //                   });
                                      //                   Navigator.push(
                                      //                     context,
                                      //                     MaterialPageRoute(
                                      //                         builder: (context) => ViewImage(
                                      //                             showListData![
                                      //                                 index],
                                      //                             webViewController,
                                      //                             refreshController)),
                                      //                   );
                                      //                 },
                                      //                 child: Text(
                                      //                   (showListData![index]
                                      //                               .isVideo ==
                                      //                           true)
                                      //                       ? "Watch Video"
                                      //                       : "View Image",
                                      //                   style: TextStyle(
                                      //                     color: Colors.white,
                                      //                     fontSize: 11.sp,
                                      //                   ),
                                      //                 )),
                                      //           )
                                      //         ],
                                      //       ),
                                      //
                                      //     ],
                                      //   ),
                                      // );
                                    },
                                  ),
                                  (showListData!.length <= listItemAttaching!.length && showListData!.first != listItemAttaching!.first) ?
                                  Container(
                                    width: 250.w,
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.05,
                                    // width: MediaQuery.of(context)
                                    //     .size
                                    //     .width *
                                    //     0.35,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          color: Colors.green,
                                          width: 100.w,
                                          child: TextButton(
                                              onPressed: () {
                                                showListData!.clear();
                                               setState(() {
                                                 showListData = listItemAttaching;
                                               });

                                                if (showListData!.isNotEmpty) {
                                                  for(int i = 0; i< showListData!.length; i++){
                                                    if(i % 4 == 0){
                                                      showListData!.insert(i , new InstaPost());
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text("Load All",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.sp,
                                                ),
                                              )),
                                        ),
                                        Container(
                                          child: TextButton(
                                              onPressed: () {
                                                _getMoreData();
                                              },
                                              child: Text("Load more",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.sp,
                                                ),
                                              )),
                                          color: Colors.lightGreen,
                                          width: 100.w,
                                        ),
                                      ],
                                    ),
                                  )
                                      :
                                    Container()

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


  //**start of post screen code


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
          quality: 60,
          name:
              "com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.jpg");

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
          quality: 60,
          name:
              "com_helpfulapps_downloader_insta-${inputData.id}_${inputData.shortcode}.jpg");

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
    listItemAttaching = (await getPostAllData(urlPost)).cast<InstaPost>();
    // showListData = (await getPostAllData(urlPost)).cast<InstaPost>();
    _getMoreData();
    // if (showListData!.isNotEmpty) {
    //   lengthItem = showListData?.length;
    //   for(int i = 0; i< showListData!.length; i++){
    //     if(i % 4 == 3 && i != 0){
    //       showListData!.insert(i , new InstaPost());
    //     }
    //   }
    // }
  }
//**end of post screen code
}


