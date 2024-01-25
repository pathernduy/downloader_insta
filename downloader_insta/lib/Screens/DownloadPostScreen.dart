//
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:downloader_insta/admob_service/AdsMobTestId.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_player/video_player.dart';
//
// import '../Component Widgets/Drawer.dart';
// import '../admob_service/AdObject/BannerAdObject.dart';
// import '../admob_service/AdsMobTestId.dart';
// import '../main.dart';
// import '../model/InstaPost.dart';
// import '../model/InstaStories.dart';
// import '../viewImage.dart';
// import 'DownloadStoryScreen.dart';
//
// class DownloadPostScreen extends StatefulWidget {
//   const DownloadPostScreen({super.key});
//
//   @override
//   State<DownloadPostScreen> createState() => _DownloadVideoScreenState();
// }
//
// class _DownloadVideoScreenState extends State<DownloadPostScreen> {
//   TextEditingController postUrlController = TextEditingController();
//   bool pressed = false;
//   InstaStories instaStories = InstaStories();
//   List<InstaStories>? showListData = [];
//   dynamic exceptionError = null;
//
//   String prefix = "https://www.instagram.com/p/";
//   String urlVideo =
//       'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
//   //'https://instagram.fsgn2-6.fna.fbcdn.net/v/t50.2886-16/341814476_1378965939527362_2598972149677012566_n.mp4?_nc_ht=instagram.fsgn2-6.fna.fbcdn.net&_nc_cat=110&_nc_ohc=0qRcZkhg4AUAX9Z34mA&edm=AABBvjUBAAAA&ccb=7-5&oh=00_AfBNqt-OWdadhzw5rQl5tForcTCoqr9bOOgIrXBMW4M3NQ&oe=64418644&_nc_sid=83d603'
//
//   Dio dio = Dio();
//
//   late FlickManager flickManager = FlickManager(
//     videoPlayerController: VideoPlayerController.network(""
//         // "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m82/7D4FDF47415AE704D2D8CB62F61667A5_video_dashinit.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uNzIwLmNsaXBzLmJhc2VsaW5lIn0&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=1190291614973924_2860471228&_nc_vs=HBksFQIYT2lnX3hwdl9yZWVsc19wZXJtYW5lbnRfcHJvZC83RDRGREY0NzQxNUFFNzA0RDJEOENCNjJGNjE2NjdBNV92aWRlb19kYXNoaW5pdC5tcDQVAALIAQAVABgkR0thb1FBUFFVWF9XR2ZNRUFGZnhZNld3RkIwc2JwUjFBQUFGFQICyAEAKAAYABsAFQAAJrisyICP8tY%2FFQIoAkMzLBdALpmZmZmZmhgSZGFzaF9iYXNlbGluZV8xX3YxEQB1%2FgcA&_nc_rid=266f0ba924&ccb=9-4&oh=00_AfD48lZyVRpcVEDGkD-2nRRokKWWdaou1_MPo6GWhRK3OA&oe=64A95754&_nc_sid=4f4799"
//         ),
//   );
//
//   InAppWebViewController? webViewController;
//   PullToRefreshController? refreshController;
//
//   BannerAd? _bannerAd;
//   bool isBannerAdLoaded = false;
//   InterstitialAd? _interstitialAd;
//   bool isInterstitialAdLoaded = false;
//   RewardedAd? _rewardedAd;
//   bool isRewardedAdLoaded = false;
//   NativeAd? _nativeAd;
//   bool isNativeAdLoaded = false;
//
//   int _rewardedScore =0;
//
//   //start of flutter Google Admob Ad
//   void _createInterstitialAd() {
//     InterstitialAd.load(
//         adUnitId: AdsMobTestId.interstitialAdUnit!,
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//             onAdLoaded: (ad) => _interstitialAd = ad,
//             onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null));
//   }
//
//   void _showInterstitialAd() {
//     if (_interstitialAd != null) {
//       _interstitialAd!.fullScreenContentCallback =
//           FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
//         ad.dispose();
//         _createInterstitialAd();
//       }, onAdFailedToShowFullScreenContent: (ad, error) {
//         ad.dispose();
//         _createInterstitialAd();
//       });
//       _interstitialAd!.show();
//       _interstitialAd = null;
//     }
//   }
//
//   void _initBannerAd() {
//     _bannerAd = BannerAd(
//         size: AdSize.fullBanner,
//         adUnitId: AdsMobTestId.bannerAdUnit! // test ad id
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
//   void _createRewardedAd() {
//     RewardedAd.load(
//         adUnitId: AdsMobTestId.rewardedAdUnit,
//         request: const AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//             onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
//             onAdFailedToLoad: (LoadAdError error) =>
//                 setState(() => _rewardedAd = null)));
//   }
//
//   void _showRewardedAd() {
//     if (_rewardedAd != null) {
//       _rewardedAd!.fullScreenContentCallback =
//           FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
//         ad.dispose();
//         _createRewardedAd();
//       }, onAdFailedToShowFullScreenContent: (ad, error) {
//         ad.dispose();
//         _createRewardedAd();
//       });
//       _rewardedAd!.show(
//           onUserEarnedReward: (AdWithoutView ad, RewardItem reward) =>
//               setState(() => _rewardedScore++));
//       _rewardedAd = null;
//     }
//   }
//
//   //end of flutter Google Admob Ad
//
//   @override
//   void initState() {
//     super.initState();
//     _createInterstitialAd();
//     _createRewardedAd();
//     _initBannerAd();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     flickManager.dispose();
//     _bannerAd!.dispose();
//     _interstitialAd!.dispose();
//     _rewardedAd!.dispose();
//     _nativeAd!.dispose();
//   }
//
//   Future<void> _dialogBuilder(BuildContext context) {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Basic dialog title'),
//           content: const Text(
//             'A dialog is a type of modal window that\n'
//             'appears in front of app content to\n'
//             'provide critical information, or prompt\n'
//             'for a decision to be made.',
//           ),
//           actions: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(
//                 textStyle: Theme.of(context).textTheme.labelLarge,
//               ),
//               child: const Text('Disable'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 textStyle: Theme.of(context).textTheme.labelLarge,
//               ),
//               child: const Text('Enable'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context, designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height));
//
//     return Scaffold(
//       drawer: drawerForScreen(context),
//       appBar: AppBar(
//         title: const Text('Download Post'),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       decoration: InputDecoration(
//                         contentPadding: EdgeInsets.all(10),
//                         // labelText: 'Enter username',
//                         labelText: 'Enter post url',
//                       ),
//                       controller: postUrlController,
//                     ),
//                   ),
//                   Expanded(
//                     child: ElevatedButton(
//                       child: Text("Show Details"),
//                       onPressed: () async {
//                         await showListURL(postUrlController.text);
//                         Future.delayed(
//                           const Duration(seconds: 1),
//                               () {
//                             setState(() {
//                               if (postUrlController.text.contains(prefix)) {
//                                 pressed = true;
//                               } else {
//                                 showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         title: Text(' URL post can\'t be found'),
//                                         content: Text(
//                                             'We can\t found your post url. Please wait a few minutes before you try again and make sure you got right url.'),
//                                         actions: <Widget>[
//                                           TextButton(
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                               },
//                                               child: Text('ok')),
//                                         ],
//                                       );
//                                     });
//                               }
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: ElevatedButton(
//                       style:
//                       ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                       child: Text("Clear"),
//                       onPressed: () {
//                         setState(() {
//                           postUrlController.text = '';
//                           pressed = false;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               //Native ad
//               // Container(
//               //   margin: const EdgeInsets.all(8.0),
//               //   height: 300,
//               //   child: MaxNativeAdView(
//               //     adUnitId: ApplovinService.nativeAdMSmallUnit,
//               //     // ApplovinService.nativeAdMediumUnit,
//               //     controller: _nativeAdViewController,
//               //     listener: NativeAdListener(onAdLoadedCallback: (ad) {
//               //       print('Native ad loaded from ${ad.networkName}');
//               //
//               //       setState(() {
//               //         _nativeAdViewController.loadAd();
//               //         _mediaViewAspectRatio = ad.nativeAd?.mediaContentAspectRatio ?? _kMediaViewAspectRatio;
//               //       });
//               //     },
//               //         onAdLoadFailedCallback: (adUnitId, error) {
//               //       print('Native ad failed to load with error code ${error.code} and message: ${error.message}');
//               //     },
//               //         onAdClickedCallback: (ad) {
//               //       print('Native ad clicked');
//               //     },
//               //         onAdRevenuePaidCallback: (ad) {
//               //       print('Native ad revenue paid: ${ad.revenue}');
//               //     }),
//               //     child: Container(
//               //       color: const Color(0xffefefef),
//               //       padding: const EdgeInsets.all(8.0),
//               //       child: Column(
//               //         mainAxisSize: MainAxisSize.min,
//               //         children: [
//               //           Row(
//               //             mainAxisAlignment: MainAxisAlignment.center,
//               //             children: [
//               //               Container(
//               //                 padding: const EdgeInsets.all(4.0),
//               //                 child: const MaxNativeAdIconView(
//               //                   width: 48,
//               //                   height: 48,
//               //                 ),
//               //               ),
//               //               Flexible(
//               //                 child: Column(
//               //                   mainAxisAlignment: MainAxisAlignment.start,
//               //                   crossAxisAlignment: CrossAxisAlignment.start,
//               //                   children: [
//               //                     MaxNativeAdTitleView(
//               //                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               //                       maxLines: 1,
//               //                       overflow: TextOverflow.visible,
//               //                     ),
//               //                     MaxNativeAdAdvertiserView(
//               //                       style: TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
//               //                       maxLines: 1,
//               //                       overflow: TextOverflow.fade,
//               //                     ),
//               //                     MaxNativeAdStarRatingView(
//               //                       size: 10,
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ),
//               //               const MaxNativeAdOptionsView(
//               //                 width: 20,
//               //                 height: 20,
//               //               ),
//               //             ],
//               //           ),
//               //           Row(
//               //             mainAxisAlignment: MainAxisAlignment.start,
//               //             children: [
//               //               Flexible(
//               //                 child: MaxNativeAdBodyView(
//               //                   style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
//               //                   maxLines: 3,
//               //                   overflow: TextOverflow.ellipsis,
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //           const SizedBox(height: 8),
//               //           Expanded(
//               //             child: AspectRatio(
//               //               aspectRatio: _mediaViewAspectRatio,
//               //               child: const MaxNativeAdMediaView(),
//               //             ),
//               //           ),
//               //           const SizedBox(
//               //             width: double.infinity,
//               //             child: MaxNativeAdCallToActionView(
//               //               style: ButtonStyle(
//               //                 backgroundColor: MaterialStatePropertyAll<Color>(Color(0xff2d545e)),
//               //                 textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               //               ),
//               //             ),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // ),
//
//               // Container(
//               //   width: 300.w,
//               //   height: 500.h,
//               //   child:
//               //   ClipRRect(
//               //     borderRadius: BorderRadius.circular!(16),
//               //     child: InAppWebView(
//               //       onLoadStart: (controller, url) {
//               //         // var v = url.toString();
//               //         // setState(() {
//               //         //   urlController.text = v;
//               //         // });
//               //       },
//               //       onLoadStop: (controller, url) {
//               //         refreshController!.endRefreshing();
//               //       },
//               //       pullToRefreshController: refreshController,
//               //       onWebViewCreated: (controller) => webViewController = controller,
//               //       initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
//               //     ),
//               //   ),
//               // ),
//
//               pressed
//                   ? showListData!.isNotEmpty
//                   ? SingleChildScrollView(
//                 //show up keyboard after unfullscreen image
//                 keyboardDismissBehavior:
//                 ScrollViewKeyboardDismissBehavior.onDrag,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   //chiều cao của khung gridview
//                   //chiều cao của khung gridview
//                   //chiều cao của khung gridview
//                   height: (MediaQuery.of(context).size.height * 1 / 3 +
//                       120 *
//                           (((showListData!.length % 2) == 1)
//                               ? ((showListData!.length / 2)
//                               .floor() +
//                               1)
//                               : ((showListData!.length / 2)
//                               .floor())) /
//                           showListData!.length) *
//                       (((showListData!.length % 2) == 1)
//                           ? ((showListData!.length / 2).floor() + 1)
//                           : ((showListData!.length / 2).floor())),
//                   //chiều cao của khung gridview
//                   //chiều cao của khung gridview
//                   child: Card(
//                     child: Container(
//                       // margin: EdgeInsets.all(15),
//                       // color: Color.fromRGBO(128, 120, 145, 255),
//                       color: Colors.blueGrey,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.max,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           GridView.builder(
//                             // physics: AlwaysScrollableScrollPhysics(),
//                             physics: NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             scrollDirection: Axis.vertical,
//                             cacheExtent: 500,
//                             gridDelegate:
//                             SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio: 10 / 16,
//                                 crossAxisSpacing:
//                                 MediaQuery.of(context)
//                                     .size
//                                     .width *
//                                     0.03,
//                                 mainAxisSpacing: 20),
//                             itemCount: showListData!.length,
//                             // SliverGridDelegateWithMaxCrossAxisExtent(
//                             //   maxCrossAxisExtent: maxCrossAxisExtent),
//                             itemBuilder:
//                                 (BuildContext context, int index) {
//                               return Container(
//                                 child: Column(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     Container(
//                                       // height :210,
//                                       // height: MediaQuery.of(context).size.height * 2/7,
//                                       height: MediaQuery.of(context)
//                                           .size
//                                           .height *
//                                           1 /
//                                           4,
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
//                                             BorderRadius.circular!(
//                                                 16),
//                                             child: (showListData![index]
//                                                 .isVideo ==
//                                                 true)
//                                                 ? ExtendedImage.memory(
//                                               showListData![index]
//                                                   .thumbnail!,
//                                               // i,
//                                               // clearMemoryCacheWhenDispose:
//                                               //     true,
//                                               // fit: BoxFit.cover,
//                                             )
//
//
//                                                 : ExtendedImage.network(
//                                               showListData![index]
//                                                   .displayUrl!,
//                                               // i,
//                                               clearMemoryCacheWhenDispose:
//                                               true,
//                                               fit: BoxFit.cover,
//                                             )),
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         Container(
//                                           width: 80.w,
//                                           height: MediaQuery.of(context)
//                                               .size
//                                               .height *
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
//                                                         1000),
//                                                         () async {
//                                                       // bool isReady = (await AppLovinMAX
//                                                       //     .isRewardedAdReady(
//                                                       //     ApplovinService
//                                                       //         .rewardedAdUnit!))!;
//                                                       // if (isReady) {
//                                                       //   AppLovinMAX.showRewardedAd(
//                                                       //       ApplovinService
//                                                       //           .rewardedAdUnit!);
//                                                       // }
//                                                     });
//
//                                                 (showListData![index]
//                                                     .isVideo ==
//                                                     true)
//                                                     ? downloadVideo(
//                                                     showListData![
//                                                     index])
//                                                     : downloadImage(
//                                                     showListData![
//                                                     index]);
//                                               },
//                                               child: Text(
//                                                 "Download",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
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
//                                           height: MediaQuery.of(context)
//                                               .size
//                                               .height *
//                                               0.05,
//
//                                           color: Color.fromARGB(
//                                               255, 2, 77, 139),
//                                           child: TextButton(
//                                               onPressed: () {
//                                                 Future.delayed(
//                                                     const Duration(
//                                                         milliseconds:
//                                                         1000),
//                                                         () async {
//                                                       // bool isReady = (await AppLovinMAX
//                                                       //     .isInterstitialReady(
//                                                       //     ApplovinService
//                                                       //         .interstitialAdUnit!))!;
//                                                       // if (isReady) {
//                                                       //   AppLovinMAX.showInterstitial(
//                                                       //       ApplovinService
//                                                       //           .interstitialAdUnit!);
//                                                       // }
//                                                     });
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           ViewImage(
//                                                               showListData![
//                                                               index],webViewController,refreshController)),
//                                                 );
//                                               },
//                                               child: Text(
//                                                 (showListData![index]
//                                                     .isVideo ==
//                                                     true)
//                                                     ? "Watch Video"
//                                                     : "View Image",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 11.sp,
//                                                 ),
//                                               )),
//
//
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//                   : Container()
//                   : Container(),
//             ],
//           ),
//         ),
//
//       ),
//       bottomNavigationBar: AdWidget(ad: _bannerAd!),
//     );
//   }
//
//   FlickManager? updateOneUrlFlickManager(List<InstaStories> showListData) {
//     return FlickManager(
//       autoPlay: false,
//       videoPlayerController:
//           VideoPlayerController.network(showListData[0].displayUrl!),
//     );
//   }
//
//   void _saveNetworkImage(InstaStories inputData) async {
//     var response = await Dio().get(inputData.displayUrl!,
//         options: Options(responseType: ResponseType.bytes));
//     final result = await ImageGallerySaver.saveImage(
//         Uint8List.fromList(response.data),
//         quality: 60,
//         name: "${inputData.id}_${inputData.shortcode}");
//     print(result);
//   }
//
//   void downloadVideo(InstaStories inputData) async {
//     FileDownloader.downloadFile(
//         url: inputData.displayUrl!,
//         name: "${inputData.id}_${inputData.shortcode}.mp4",
//         onProgress: (String? fileName, double? progress) {
//           print('FILE fileName HAS PROGRESS $progress');
//         },
//         onDownloadCompleted: (String path) {
//           Fluttertoast.showToast(
//               msg: "Succesfully Downloaded",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.grey,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         },
//         onDownloadError: (String error) {
//           Fluttertoast.showToast(
//               msg: "Please try it again",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.grey,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         });
//   }
//
//   void downloadImage(dynamic inputData) async {
//     var response = await Dio().get("${inputData.displayUrl}",
//         options: Options(responseType: ResponseType.bytes));
//     await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
//         quality: 60, name: "${inputData.id}_${inputData.shortcode}.jpg");
//
//     Fluttertoast.showToast(
//         msg: "Succesfully Downloaded",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.grey,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }
//
//   //get data from api
//   Future showListURL(String urlPost) async {
//     exceptionError = await getPostAllData(urlPost);
//     if (exceptionError.isUndefinedOrNull)
//       showListData = (await getPostAllData(urlPost)).cast<InstaStories>();
//   }
// }
//
