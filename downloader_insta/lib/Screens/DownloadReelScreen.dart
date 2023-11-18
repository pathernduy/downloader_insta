import 'dart:math';
import 'dart:typed_data';

import 'package:applovin_max/applovin_max.dart';
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
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../Component Widgets/Drawer.dart';
import '../applovin_service/ads_service.dart';
import '../main.dart';
import '../model/InstaPost.dart';
import '../model/InstaStories.dart';
import '../rapidapi_service/illusion_story_api.dart';
import '../viewImage.dart';
import 'DownloadPostScreen.dart';

class DownloadReelScreen extends StatefulWidget {
  const DownloadReelScreen({super.key});

  @override
  State<DownloadReelScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadReelScreen> {
  // BannerAd? bannerAd;
  // bool isAdLoaded = false;
  // InterstitialAd? _interstitialAd;
  // RewardedAd? _rewardedAd;

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

  final MaxNativeAdViewController _nativeAdViewController =
  MaxNativeAdViewController();

  MaxAd? nativeAd1;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }


  @override
  void initState() {
    super.initState();

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
    super.dispose();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerForScreen(context),
      appBar: AppBar(
        title: const Text('Download Reel'),
      ),
      body: SingleChildScrollView(
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
                                        title: Text(' URL reel can\'t be found'),
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
              MaxAdView(
                  adUnitId: ApplovinService.mrecAdUnitScreen!,
                  adFormat: AdFormat.mrec,
                  listener: AdViewAdListener(
                      onAdLoadedCallback: (ad) {},
                      onAdLoadFailedCallback: (adUnitId, error) {},
                      onAdClickedCallback: (ad) {},
                      onAdExpandedCallback: (ad) {},
                      onAdCollapsedCallback: (ad) {})),

              pressed
                  ? showListData!.isEmpty
                    ? exceptionError != null
                      ? AlertDialog(
                title: const Text('Basic dialog title'),
                content: const Text(
                  "Please wait a few minutes before you try again.",
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle:
                      Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
                      : Container()
                    :
              (showListData!.length < 2)
                      ?
              (showListData![0].isVideo == true)
                        ? Container(
                      width:
                      MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width *16/9
                      // MediaQuery.of(context).size.height * 2 / 3 +
                      //     120
                ,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          // height: MediaQuery.of(context)
                          //     .size
                          //     .height,
                          // width: MediaQuery.of(context)
                          //     .size
                          //     .width,

                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children:  [
                                Container(
                                  height:
                                  MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.85,
                                  width:
                                  MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.85 *
                                      16 /
                                      9,
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
                                        child:  ExtendedImage.memory(
                                        showListData!.first
                                              .thumbnail!,
                                          // i,
                                          // clearMemoryCacheWhenDispose:
                                          //     true,
                                          // fit: BoxFit.cover,
                                        )
                                          ),
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

                                            (showListData!.first
                                                .isVideo ==
                                                true)
                                                ? downloadVideo(
                                                showListData!.first)
                                                : downloadImage(
                                                showListData!.first);
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
                                                          showListData!.first,webViewController,refreshController!)),
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
                        : Container()
              // Container(
              //         child: SingleChildScrollView(
              //           // physics: NeverScrollableScrollPhysics(),
              //           child: Column(
              //             children: (showListData!.isNotEmpty)
              //                 ? [
              //               Container(
              //                 height: MediaQuery.of(context)
              //                     .size
              //                     .height *
              //                     0.85,
              //                 width: MediaQuery.of(context)
              //                     .size
              //                     .height *
              //                     0.85 *
              //                     16 /
              //                     9,
              //                 child: ExtendedImage.network(
              //                   showListData![0].displayUrl!,
              //                   clearMemoryCacheWhenDispose:
              //                   true,
              //                   clearMemoryCacheIfFailed:
              //                   true,
              //                   // fit: BoxFit.,
              //                 ),
              //               ),
              //               Container(
              //                 height: MediaQuery.of(context)
              //                     .size
              //                     .height -
              //                     MediaQuery.of(context)
              //                         .size
              //                         .height *
              //                         0.95,
              //                 width: MediaQuery.of(context)
              //                     .size
              //                     .width *
              //                     0.5,
              //                 color: Color.fromARGB(
              //                     255, 2, 77, 139),
              //                 child: TextButton(
              //                     onPressed: () async {
              //                       var status =
              //                       await Permission
              //                           .storage
              //                           .request();
              //                       if (status.isGranted) {
              //                         downloadVideo(
              //                             showListData![0]);
              //                       }
              //                     },
              //                     child: Text(
              //                       "Download Image",
              //                       style: TextStyle(
              //                         color: Colors.white,
              //                       ),
              //                     )),
              //               )
              //             ]
              //                 : [],
              //           ),
              //         ),
              //       )
                      :
              SingleChildScrollView(
                    // physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      //chiều cao của khung gridview
                      //chiều cao của khung gridview
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
                      // MediaQuery.of(context).size.height * ((showListData!.length / 2 +1 )/3) + 20*3 +  MediaQuery.of(context).size.height * 0.12,
                      //chiều cao của khung gridview
                      //chiều cao của khung gridview
                      //chiều cao của khung gridview
                      //chiều cao của khung gridview

                      child: Card(
                        child: Container(
                          color: Colors.blueGrey,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
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
                                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                                    mainAxisSpacing: 20),
                                itemCount: showListData!.length,
                                // SliverGridDelegateWithMaxCrossAxisExtent(
                                //   maxCrossAxisExtent: maxCrossAxisExtent),
                                itemBuilder: (BuildContext context,
                                    int index) {

                                    return Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
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
                                                                    index],webViewController,refreshController!)),
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
                                          // Container(
                                          //       height:
                                          //           MediaQuery.of(context)
                                          //               .size
                                          //               .height *
                                          //               0.05,
                                          //       width:
                                          //       MediaQuery.of(context)
                                          //           .size
                                          //           .width *
                                          //           0.35,
                                          //       color: Color.fromARGB(
                                          //           255, 2, 77, 139),
                                          //       child: TextButton(
                                          //           onPressed: ()  {
                                          //             Future.delayed(const Duration(milliseconds: 1000), ()async {
                                          //               bool isReady = (await AppLovinMAX.isRewardedAdReady(ApplovinService.rewardedAdUnit!))!;
                                          //               if (isReady) {
                                          //                 AppLovinMAX.showRewardedAd(ApplovinService.rewardedAdUnit!);
                                          //               }
                                          //             });
                                          //
                                          //             (showListData![index]
                                          //               .isVideo ==
                                          //               true)
                                          //               ? downloadVideo(showListData![index])
                                          //               : downloadImage(
                                          //                 showListData![index]);},
                                          //           child: Text(
                                          //             "Download",
                                          //             style: TextStyle(
                                          //               color:
                                          //               Colors.white,
                                          //             ),
                                          //           )),
                                          //
                                          //   //  TextButton(
                                          //   //     onPressed: () => (i.isVideo == true)?
                                          //   //         downloadVideo(i) : downloadImage(i),
                                          //   //     child: i.listFeedImagesUrl!
                                          //   //             .isEmpty
                                          //   //         ? Text("Download")
                                          //   //         : Text(
                                          //   //             "Download All"))
                                          // )
                                        ],
                                      ),
                                    );

                                },
                              ),
                              // Container(
                              //   height:  MediaQuery.of(context)
                              //       .size
                              //       .height *
                              //       0.28,
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )

                  : Container(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: MaxAdView(
      //   adUnitId: ApplovinService.bannerAdUnitScreen!,
      //   adFormat: AdFormat.banner,
      //   isAutoRefreshEnabled: true,
      //   listener: AdViewAdListener(
      //       onAdLoadedCallback: (ad) {},
      //       onAdLoadFailedCallback: (adUnitId, error) {},
      //       onAdClickedCallback: (ad) {},
      //       onAdExpandedCallback: (ad) {},
      //       onAdCollapsedCallback: (ad) {})),
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
