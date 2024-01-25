import 'package:downloader_insta/model/InstaStories.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../admob_service/AdObject/BannerAdObject.dart';
import '../../admob_service/AdObject/nativeAdItemWidget.dart';
import '../../helper_methods/helperMethods.dart';
import '../../main.dart';
import '../../model/InstaPost.dart';
import '../../viewImage.dart';

class GridViewItemList extends StatefulWidget {
  List<dynamic>? listItemAttaching = [];
  List<dynamic>? showListData = [];
  GridViewItemList(this.listItemAttaching,this.showListData,{Key? key}) : super(key: key);

  @override
  State<GridViewItemList> createState() => GridViewItemListState();
}

class GridViewItemListState extends State<GridViewItemList> {
  BannerAd? _bannerAd;
  bool isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdLoaded = false;
  RewardedAd? _rewardedAd;
  bool isRewardedAdLoaded = false;
  NativeAd? _nativeAd;
  bool isNativeAdLoaded = false;
  NativeAd? _nativeAdItem;
  bool isNativeAdItemLoaded = false;
  final double _adAspectRatioMedium = (370 / 355);
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool isRewardedInterstitialAdLoaded = false;


  final homePageKey = GlobalKey<HomePageState>();

  TabController? tabController;

  String? username, followers = " ", following, bio, website;

  List<String>? listFeedImages;
  bool pressed = false;
  bool downloading = false;

  String prefix = "https://www.instagram.com/p/";

  TextEditingController urlInputController = TextEditingController();

  // bool pressed = false;
  InstaPost instaPost = InstaPost();
  bool isLoadingAttaching = false;
  List<dynamic>? showListData = [];
  int? lengthItem = 0;


  static const double _kMediaViewAspectRatio = 16 / 9;
  double _mediaViewAspectRatio = _kMediaViewAspectRatio;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

  void getMoreData() async {
    if (!isLoadingAttaching) {
      setState(() {
        isLoadingAttaching = true;
      });
      // List<InstaPost>? widget.listItemAttaching = [];
      // List<InstaPost>? showListData = [];
      int firstIndex = 0;
      int lastIndex = 3;
      if(showListData!.isEmpty){
        if(widget.listItemAttaching!.first is InstaPost){
          showListData!.add(new InstaPost());
          showListData =showListData! + widget.listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        }else{
          showListData!.add(new InstaStories());
          showListData =showListData! + widget.listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        }

        print(showListData);
      }else{
        firstIndex = showListData!.length;
        lastIndex += firstIndex;
        if(lastIndex > widget.listItemAttaching!.length){
          lastIndex = widget.listItemAttaching!.length;
        }
        if(widget.listItemAttaching!.first is InstaPost){
          showListData!.insert(firstIndex , new InstaPost());
          showListData =  showListData! + widget.listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        }else{
          showListData!.insert(firstIndex , new InstaStories());
          showListData =  showListData! + widget.listItemAttaching!.getRange(firstIndex, lastIndex).toList();
        }

        print(showListData);

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

    super.initState();

    homePageKey.currentState!.initBannerAd();
    homePageKey.currentState!.createRewardedAd();
    homePageKey.currentState!.createInterstitialAd();
    homePageKey.currentState!.createRewardedInterstitialAd();
    homePageKey.currentState!.createNativeAd();
    homePageKey.currentState!.createNativeAdItem();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                (((widget.showListData!.length % 2) == 1)
                    ? ((widget.showListData!.length / 2)
                    .floor() +
                    1)
                    : ((widget.showListData!.length / 2)
                    .floor())) /
                widget.showListData!.length) *
            (((widget.showListData!.length % 2) == 1)
                ? ((widget.showListData!.length / 2).floor() + 1 + 0.15.h)
                : ((widget.showListData!.length / 2).floor())+ 0.15.h),
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
                  itemCount: widget.showListData!.length,
                  // SliverGridDelegateWithMaxCrossAxisExtent(
                  //   maxCrossAxisExtent: maxCrossAxisExtent),
                  itemBuilder:
                      (BuildContext context, int index) {

                    if(index % 4 == 0){
                      if(homePageKey!.currentState!.itemNativeAdKey != null){
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
                                      child: (widget.showListData![index]
                                          .isVideo ==
                                          true)
                                          ? ExtendedImage.memory(
                                        widget.showListData![index]
                                            .thumbnail!,

                                      )

                                          : ExtendedImage.network(
                                        widget.showListData![index]
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
                                                (_rewardedAd != null) ?
                                                _rewardedAd!.show(
                                                    onUserEarnedReward:
                                                        (AdWithoutView
                                                    ad,
                                                        RewardItem
                                                        rewardItem) {
                                                          HelperMethods().downloadData(widget.showListData![
                                                          index]);
                                                    })
                                                    : HelperMethods().downloadData(widget.showListData![
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

                                                homePageKey.currentState!.createInterstitialAd();
                                                _interstitialAd!.show();

                                                // _showInterstitialAd();
                                              });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ViewImage(
                                                    widget.showListData![
                                                    index],
                                                    webViewController,
                                                    refreshController)),
                                          );
                                        },
                                        child: Text(
                                          (widget.showListData![index]
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
                    }
                    else{
                      widget.showListData!.removeWhere((item) => item == null);
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
                                    child: (widget.showListData![index]
                                        .isVideo ==
                                        true)
                                        ? ExtendedImage.memory(
                                      widget.showListData![index]
                                          .thumbnail!,

                                    )

                                        : ExtendedImage.network(
                                      widget.showListData![index]
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
                                  color: const Color.fromARGB(
                                      255, 2, 77, 139),
                                  child: TextButton(
                                      onPressed: () {
                                        Future.delayed(
                                            const Duration(
                                                milliseconds:
                                                1000),
                                                () async {
                                              (_rewardedAd != null) ?
                                              _rewardedAd!.show(
                                                  onUserEarnedReward:
                                                      (AdWithoutView
                                                  ad,
                                                      RewardItem
                                                      rewardItem) {
                                                    HelperMethods().downloadData(widget.showListData![
                                                        index]);

                                                  })
                                                  :
                                              HelperMethods().downloadData(widget.showListData![
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
                                  color: const Color.fromARGB(
                                      255, 2, 77, 139),
                                  child: TextButton(
                                      onPressed: () {
                                        Future.delayed(
                                            const Duration(
                                                milliseconds:
                                                1000),
                                                () async {

                                                  homePageKey.currentState!.createInterstitialAd();
                                                  homePageKey.currentState!.interstitialAd!.show();

                                              // _showInterstitialAd();
                                            });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewImage(
                                                  widget.showListData![
                                                  index],
                                                  webViewController,
                                                  refreshController)),
                                        );
                                      },
                                      child: Text(
                                        (widget.showListData![index]
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
                    //               child: (widget.showListData![index]
                    //                           .isVideo ==
                    //                       true)
                    //                   ? ExtendedImage.memory(
                    //                       widget.showListData![index]
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
                    //                   //                   Uri.parse(widget.showListData![
                    //                   //                           index]
                    //                   //                       .displayUrl!),
                    //                   //                 )),
                    //                   //       )
                    //                   : ExtendedImage.network(
                    //                       widget.showListData![index]
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
                    //                       (widget.showListData![index]
                    //                                   .isVideo ==
                    //                               true)
                    //                           ? downloadVideo(
                    //                               widget.showListData![
                    //                                   index])
                    //                           : downloadImage(
                    //                               widget.showListData![
                    //                                   index]);
                    //                     })
                    //                        : (widget.showListData![index]
                    //                             .isVideo ==
                    //                         true)
                    //                         ? downloadVideo(
                    //                         widget.showListData![
                    //                         index])
                    //                             : downloadImage(
                    //                         widget.showListData![
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
                    //                             widget.showListData![
                    //                                 index],
                    //                             webViewController,
                    //                             refreshController)),
                    //                   );
                    //                 },
                    //                 child: Text(
                    //                   (widget.showListData![index]
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
                (widget.showListData!.length != widget.listItemAttaching!.length) 
                    ?
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
                                showListData = widget.listItemAttaching;
                              });

                              if (showListData!.isNotEmpty) {
                                for(int i = 0; i< showListData!.length; i++){
                                  if(i % 4 == 0){
                                    showListData!.insert(i , new InstaStories());
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
                              getMoreData();
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
                (showListData!.first != widget.listItemAttaching!.first)
                    ?
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
                                showListData = widget.listItemAttaching;
                              });

                              if (showListData!.isNotEmpty) {
                                for(int i = 0; i< showListData!.length; i++){
                                  if(i % 4 == 0){
                                    showListData!.insert(i , new InstaStories());
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
                              getMoreData();
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
    );
  }
}
