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
import '../Component Widgets/gridview_list/gridviewItem.dart';
import '../admob_service/AdObject/nativeAdItemWidget.dart';
import '../admob_service/AdsMobService.dart';
import '../main.dart';
import '../model/InstaStories.dart';
import '../viewImage.dart';

class DownloadStoryScreen extends StatefulWidget {
  const DownloadStoryScreen({super.key});

  @override
  State<DownloadStoryScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadStoryScreen> {
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

  TextEditingController postUrlController = TextEditingController();
  bool pressed = false;
  InstaStories instaStories = InstaStories();
  List<InstaStories>? listItemAttaching = [];
  List<InstaStories>? showListData = [];
  bool isLoadingAttaching = false;
  final homePageKey = GlobalKey<HomePageState>();
  final itemNativeAdKey = GlobalKey<itemNativeAdState>();

  dynamic exceptionError = null;
  var _rewardedAdRetryAttempt = 0;

  String urlVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  //'https://instagram.fsgn2-6.fna.fbcdn.net/v/t50.2886-16/341814476_1378965939527362_2598972149677012566_n.mp4?_nc_ht=instagram.fsgn2-6.fna.fbcdn.net&_nc_cat=110&_nc_ohc=0qRcZkhg4AUAX9Z34mA&edm=AABBvjUBAAAA&ccb=7-5&oh=00_AfBNqt-OWdadhzw5rQl5tForcTCoqr9bOOgIrXBMW4M3NQ&oe=64418644&_nc_sid=83d603'

  // BetterPlayer _betterPlayer = BetterPlayer.network(
  //   'https://instagram.fsgn2-3.fna.fbcdn.net/v/t50.2886-16/341756410_1206678273315307_7315864248123451947_n.mp4?_nc_ht=instagram.fsgn2-3.fna.fbcdn.net&_nc_cat=107&_nc_ohc=uWQirb4tmZ4AX9hILYW&edm=APfKNqwBAAAA&ccb=7-5&oh=00_AfCAroLco9NXAWn763wJvwpO273NMl5rJ4QMZjzizzvUNA&oe=643EBD6E&_nc_sid=74f7ba',
  //   betterPlayerConfiguration: BetterPlayerConfiguration(aspectRatio: 16 / 9),
  // );
  Dio dio = Dio();

  late FlickManager flickManager = FlickManager(
    videoPlayerController: VideoPlayerController.networkUrl(
      Uri.parse(""),
      // "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m82/7D4FDF47415AE704D2D8CB62F61667A5_video_dashinit.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uNzIwLmNsaXBzLmJhc2VsaW5lIn0&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=1190291614973924_2860471228&_nc_vs=HBksFQIYT2lnX3hwdl9yZWVsc19wZXJtYW5lbnRfcHJvZC83RDRGREY0NzQxNUFFNzA0RDJEOENCNjJGNjE2NjdBNV92aWRlb19kYXNoaW5pdC5tcDQVAALIAQAVABgkR0thb1FBUFFVWF9XR2ZNRUFGZnhZNld3RkIwc2JwUjFBQUFGFQICyAEAKAAYABsAFQAAJrisyICP8tY%2FFQIoAkMzLBdALpmZmZmZmhgSZGFzaF9iYXNlbGluZV8xX3YxEQB1%2FgcA&_nc_rid=266f0ba924&ccb=9-4&oh=00_AfD48lZyVRpcVEDGkD-2nRRokKWWdaou1_MPo6GWhRK3OA&oe=64A95754&_nc_sid=4f4799"
    ),
  );

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

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

  void _getMoreData() async {
    if (!isLoadingAttaching) {
      setState(() {
        isLoadingAttaching = true;
      });
      // List<InstaStories>? listItemAttaching = [];
      // List<InstaStories>? showListData = [];
      int firstIndex = 0;
      int lastIndex = 3;
      if (showListData!.isEmpty) {
        showListData!.add(new InstaStories());
        showListData = showListData! +
            listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        print(showListData);
      } else {
        if (showListData!.length == listItemAttaching!.length) {
          firstIndex = showListData!.length - 1;
          lastIndex += firstIndex;
          if (lastIndex > listItemAttaching!.length) {
            lastIndex = listItemAttaching!.length;
          }
          showListData!.insert(lastIndex, new InstaStories());
          showListData = showListData! +
              listItemAttaching!.getRange(firstIndex, lastIndex).toList();
          print(showListData);
        } else {
          firstIndex = showListData!.length;
          lastIndex += firstIndex;
          if (lastIndex > listItemAttaching!.length) {
            lastIndex = listItemAttaching!.length;
          }
          showListData!.insert(firstIndex, new InstaStories());
          showListData = showListData! +
              listItemAttaching!.getRange(firstIndex, lastIndex).toList();
          print(showListData);
        }

        // firstIndex = showListData!.length;
        // lastIndex += firstIndex;
        // if(lastIndex > listItemAttaching!.length){
        //   lastIndex = listItemAttaching!.length;
        // }
        // showListData!.insert(firstIndex , new InstaStories());
        // showListData =  showListData! + listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        // print(showListData);
      }

      setState(() {
        isLoadingAttaching = false;
      });
    }
  }

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
    super.dispose();
    flickManager.dispose();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ErrorExceptionWidget('Basic dialog title','A dialog is a type of modal window that\n'
            'appears in front of app content to\n'
            'provide critical information, or prompt\n'
            'for a decision to be made.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerForScreen(context),
      appBar: AppBar(
        title: const Text('Download Story'),
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
                        labelText: 'Enter story url',
                      ),
                      controller: postUrlController,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text("Show Detail"),
                      onPressed: () async {
                        if (postUrlController.text.contains("/stories/")) {
                          if (showListData!.isEmpty &&
                              listItemAttaching!.isEmpty) {
                            await showListURL(postUrlController.text);
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                pressed = true;

                                // _betterPlayerController =
                                //     updateOneUrlBetterPlayer(showListData);
                              });
                            });
                          } else {
                            showListData!.clear();
                            listItemAttaching!.clear();
                            await showListURL(postUrlController.text);
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                pressed = true;

                                // _betterPlayerController =
                                //     updateOneUrlBetterPlayer(showListData);
                              });
                            });
                          }
                        } else {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                            ErrorExceptionWidget('Wrong url type','You must have the link like this: https://www.instagram.com/stories/username/story-id/'),
                          );}
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
                          postUrlController.text = '';
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
                          ? ErrorExceptionWidget('URL IS PRIVATE',"Please make sure the url you pasted is not private.")
                          : SingleChildScrollView(
                              //show up keyboard after unfullscreen image
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                //chiều cao của khung gridview
                                //chiều cao của khung gridview
                                //chiều cao của khung gridview
                                height: (MediaQuery.of(context).size.height *
                                            1 /
                                            3 +
                                        120 *
                                            (((showListData!.length % 2) == 1)
                                                ? ((showListData!.length / 2)
                                                        .floor() +
                                                    1)
                                                : ((showListData!.length / 2)
                                                    .floor())) /
                                            showListData!.length) *
                                    (((showListData!.length % 2) == 1)
                                        ? ((showListData!.length / 2).floor() +
                                            1 +
                                            0.15.h)
                                        : ((showListData!.length / 2).floor()) +
                                            0.15.h),
                                //chiều cao của khung gridview
                                //chiều cao của khung gridview
                                child: Card(
                                  child: Container(
                                    // margin: EdgeInsets.all(15),
                                    // color: Color.fromRGBO(128, 120, 145, 255),
                                    color: Colors.blueGrey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
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
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (index % 4 == 0) {
                                              if (itemNativeAdKey != null) {
                                                return const ItemNativeAd();
                                              } else {
                                                return Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        // height :210,
                                                        // height: MediaQuery.of(context).size.height * 2/7,
                                                        height: MediaQuery.of(
                                                                    context)
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
                                                                  BorderRadius
                                                                          .circular!(
                                                                      16),
                                                              child: (showListData![index]
                                                                          .isVideo ==
                                                                      true)
                                                                  ? ExtendedImage
                                                                      .memory(
                                                                      showListData![
                                                                              index]
                                                                          .thumbnail!,
                                                                    )
                                                                  : ExtendedImage
                                                                      .network(
                                                                      showListData![
                                                                              index]
                                                                          .displayUrl!,
                                                                      // i,
                                                                      clearMemoryCacheWhenDispose:
                                                                          true,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Container(
                                                            width: 80.w,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.05,
                                                            // width: MediaQuery.of(context)
                                                            //     .size
                                                            //     .width *
                                                            //     0.35,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    2,
                                                                    77,
                                                                    139),
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              1000),
                                                                      () async {
                                                                    (_rewardedAd !=
                                                                            null)
                                                                        ? _rewardedAd!.show(onUserEarnedReward: (AdWithoutView
                                                                                ad,
                                                                            RewardItem
                                                                                rewardItem) {
                                                                            (showListData![index].isVideo == true)
                                                                                ? downloadVideo(showListData![index])
                                                                                : downloadImage(showListData![index]);
                                                                          })
                                                                        : (showListData![index].isVideo ==
                                                                                true)
                                                                            ? downloadVideo(showListData![index])
                                                                            : downloadImage(showListData![index]);
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Download",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        11.sp,
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
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.05,
                                                            // width: MediaQuery.of(context)
                                                            //     .size
                                                            //     .width *
                                                            //     0.35,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    2,
                                                                    77,
                                                                    139),
                                                            child: TextButton(
                                                                onPressed: () {
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              1000),
                                                                      () async {
                                                                    _createInterstitialAd();
                                                                    _interstitialAd!
                                                                        .show();

                                                                    // _showInterstitialAd();
                                                                  });
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => ViewImage(
                                                                            showListData![index],
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
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        11.sp,
                                                                  ),
                                                                )),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            } else {
                                              showListData!.removeWhere(
                                                  (item) => item == null);
                                              return Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Container(
                                                      // height :210,
                                                      // height: MediaQuery.of(context).size.height * 2/7,
                                                      height:
                                                          MediaQuery.of(context)
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
                                                                BorderRadius
                                                                        .circular!(
                                                                    16),
                                                            child: (showListData![
                                                                            index]
                                                                        .isVideo ==
                                                                    true)
                                                                ? ExtendedImage
                                                                    .memory(
                                                                    showListData![
                                                                            index]
                                                                        .thumbnail!,
                                                                  )
                                                                : ExtendedImage
                                                                    .network(
                                                                    showListData![
                                                                            index]
                                                                        .displayUrl!,
                                                                    // i,
                                                                    clearMemoryCacheWhenDispose:
                                                                        true,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Container(
                                                          width: 80.w,
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                                  (_rewardedAd !=
                                                                          null)
                                                                      ? _rewardedAd!.show(onUserEarnedReward: (AdWithoutView
                                                                              ad,
                                                                          RewardItem
                                                                              rewardItem) {
                                                                          (showListData![index].isVideo == true)
                                                                              ? downloadVideo(showListData![index])
                                                                              : downloadImage(showListData![index]);
                                                                        })
                                                                      : (showListData![index].isVideo ==
                                                                              true)
                                                                          ? downloadVideo(showListData![
                                                                              index])
                                                                          : downloadImage(
                                                                              showListData![index]);
                                                                });
                                                              },
                                                              child: Text(
                                                                "Download",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      11.sp,
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
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                                  _interstitialAd!
                                                                      .show();

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
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      11.sp,
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
                                            //                         (_rewardedAd != null) ?
                                            //                     _rewardedAd!.show(
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
                                            //                         _createInterstitialAd();
                                            //                         _interstitialAd!.show();
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
                                        (showListData!.length <=
                                                    listItemAttaching!.length &&
                                                showListData!.first !=
                                                    listItemAttaching!.first)
                                            ? Container(
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      color: Colors.green,
                                                      width: 100.w,
                                                      child: TextButton(
                                                          onPressed: () {
                                                            showListData!
                                                                .clear();
                                                            setState(() {
                                                              showListData =
                                                                  listItemAttaching;
                                                            });

                                                            if (showListData!
                                                                .isNotEmpty) {
                                                              for (int i = 0;
                                                                  i <
                                                                      showListData!
                                                                          .length;
                                                                  i++) {
                                                                if (i % 4 ==
                                                                    0) {
                                                                  showListData!
                                                                      .insert(i,
                                                                          new InstaStories());
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child: Text(
                                                            "Load All",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11.sp,
                                                            ),
                                                          )),
                                                    ),
                                                    Container(
                                                      child: TextButton(
                                                          onPressed: () {
                                                            _getMoreData();
                                                          },
                                                          child: Text(
                                                            "Load more",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11.sp,
                                                            ),
                                                          )),
                                                      color: Colors.lightGreen,
                                                      width: 100.w,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : ErrorExceptionWidget('URL IS NOT FOUND',"Please make sure the url you pasted is not available.")
                  : Container(),
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

  FlickManager? updateOneUrlFlickManager(List<InstaStories>? showListData) {
    return FlickManager(
        autoPlay: false,
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(showListData!.first.displayUrl!),
        ));
  }

  void _saveNetworkImage(InstaStories inputData) async {
    var response = await Dio().get(inputData.displayUrl!,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "${inputData.id}_${inputData.shortcode}");
    print(result);
  }

  void downloadVideo(InstaStories inputData) async {
    if (inputData.id == null && inputData.shortcode == null) {
      FileDownloader.downloadFile(
          url: inputData.displayUrl!,
          name:
              "com.helpfulapps.downloader_insta_${DateTime.now().millisecondsSinceEpoch}.mp4",
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
          name: "${inputData.id}_${inputData.shortcode}.mp4",
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

  void downloadImage(dynamic inputData) async {
    if (inputData.id == null && inputData.shortcode == null) {
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60,
          name:
              "com.helpfulapps.downloader_insta_${DateTime.now().millisecondsSinceEpoch}.jpg");
    } else {
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "${inputData.id}_${inputData.shortcode}.jpg");
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

  //get data from api
  Future showListURL(String urlPost) async {
    // exceptionError = await getPostAllData(urlPost);
    // if (exceptionError.isUndefinedOrNull)
    listItemAttaching = (await getStoriesAllData(urlPost)).cast<InstaStories>();
    _getMoreData();
  }
}
