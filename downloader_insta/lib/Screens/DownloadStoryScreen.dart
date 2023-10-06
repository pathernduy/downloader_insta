import 'dart:math';
import 'dart:typed_data';

import 'package:applovin_max/applovin_max.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../applovin_service/ads_service.dart';
import '../main.dart';
import '../model/InstaStories.dart';
import '../rapidapi_service/illusion_story_api.dart';
import '../viewImage.dart';
import 'DownloadPostScreen.dart';

class DownloadStoryScreen extends StatefulWidget {
  const DownloadStoryScreen({super.key});

  @override
  State<DownloadStoryScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadStoryScreen> {
  TextEditingController postUrlController = TextEditingController();
  bool pressed = false;
  InstaStories instaStories = InstaStories();
  List<InstaStories>? showListData = [];
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
    videoPlayerController: VideoPlayerController.networkUrl( Uri.parse(""),
      // "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m82/7D4FDF47415AE704D2D8CB62F61667A5_video_dashinit.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uNzIwLmNsaXBzLmJhc2VsaW5lIn0&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=1190291614973924_2860471228&_nc_vs=HBksFQIYT2lnX3hwdl9yZWVsc19wZXJtYW5lbnRfcHJvZC83RDRGREY0NzQxNUFFNzA0RDJEOENCNjJGNjE2NjdBNV92aWRlb19kYXNoaW5pdC5tcDQVAALIAQAVABgkR0thb1FBUFFVWF9XR2ZNRUFGZnhZNld3RkIwc2JwUjFBQUFGFQICyAEAKAAYABsAFQAAJrisyICP8tY%2FFQIoAkMzLBdALpmZmZmZmhgSZGFzaF9iYXNlbGluZV8xX3YxEQB1%2FgcA&_nc_rid=266f0ba924&ccb=9-4&oh=00_AfD48lZyVRpcVEDGkD-2nRRokKWWdaou1_MPo6GWhRK3OA&oe=64A95754&_nc_sid=4f4799"
    ),
  );

  @override
  void initState() {
    super.initState();
    initializeRewardedAd();
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
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: const Text(
            'A dialog is a type of modal window that\n'
                'appears in front of app content to\n'
                'provide critical information, or prompt\n'
                'for a decision to be made.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void initializeRewardedAd() {
    AppLovinMAX.loadRewardedAd(ApplovinService.rewardedAdUnit!);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(child: Text('Ins Downloader')),
            ),
            // ListTile(
            //   title: const Text('Collection'),
            //   onTap: () => Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => HomePage()),
            //   ),
            // ),
            ListTile(
              title: const Text('Download Post'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ),
            ),
            ListTile(
              title: const Text('Download Stories'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DownloadStoryScreen()),
              ),
            ),
          ],
        ),
      ),
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
                        await showListURL(postUrlController.text);

                        Future.delayed(Duration(seconds: 1), () {
                          flickManager =
                          updateOneUrlFlickManager(showListData!)!;
                          setState(() {
                            pressed = true;

                            // _betterPlayerController =
                            //     updateOneUrlBetterPlayer(showListData);
                          });
                        });
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
                  : (showListData!.length < 2)
                  ? (showListData![0].isVideo == true)
                  ? Container(
                width:
                MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width *
                    0.7 *
                    16 /
                    9,
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
                      // physics: NeverScrollableScrollPhysics(),
                      child: Column(
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
                            child: FlickVideoPlayer(
                                flickManager:
                                flickManager),

                            //  BetterPlayer.network(i)
                          ),
                          Container(
                            height: MediaQuery.of(
                                context)
                                .size
                                .height -
                                MediaQuery.of(context)
                                    .size
                                    .height *
                                    0.95,
                            width:
                            MediaQuery.of(context)
                                .size
                                .width *
                                0.5,
                            color: Color.fromARGB(
                                255, 2, 77, 139),
                            child: TextButton(
                                onPressed: () async {
                                  var status =
                                  await Permission
                                      .storage
                                      .request();
                                  if (status
                                      .isGranted) {
                                    downloadVideo(
                                        showListData![
                                        0]);
                                  }
                                },
                                child: Text(
                                  "Download Video",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  : Container(
                child: SingleChildScrollView(
                  // physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: (showListData!.isNotEmpty)
                        ? [
                      Container(
                        height: MediaQuery.of(context)
                            .size
                            .height *
                            0.85,
                        width: MediaQuery.of(context)
                            .size
                            .height *
                            0.85 *
                            16 /
                            9,
                        child: ExtendedImage.network(
                          showListData![0].displayUrl!,
                          clearMemoryCacheWhenDispose:
                          true,
                          clearMemoryCacheIfFailed:
                          true,
                          // fit: BoxFit.,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context)
                            .size
                            .height -
                            MediaQuery.of(context)
                                .size
                                .height *
                                0.95,
                        width: MediaQuery.of(context)
                            .size
                            .width *
                            0.5,
                        color: Color.fromARGB(
                            255, 2, 77, 139),
                        child: TextButton(
                            onPressed: () async {
                              var status =
                              await Permission
                                  .storage
                                  .request();
                              if (status.isGranted) {
                                downloadVideo(
                                    showListData![0]);
                              }
                            },
                            child: Text(
                              "Download Image",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      )
                    ]
                        : [],
                  ),
                ),
              )
                  : SingleChildScrollView(
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
                                              BorderRadius
                                                  .circular(
                                                  16),
                                              child: (showListData![index].isVideo ==
                                                  true)
                                                  ? FlickVideoPlayer(
                                                flickVideoWithControls:
                                                FlickVideoWithControls(
                                                  controls:
                                                  FlickPortraitControls(
                                                    progressBarSettings:
                                                    FlickProgressBarSettings(playedColor: Colors.green,),
                                                  ),
                                                  videoFit:
                                                  BoxFit
                                                      .fitHeight,
                                                ),
                                                flickManager:
                                                 FlickManager(
                                                     autoInitialize: true,
                                                     // getPlayerControlsTimeout: ,
                                                    autoPlay:
                                                    false,
                                                    videoPlayerController:
                                                    VideoPlayerController.networkUrl(
                                                      Uri.parse(showListData![index].displayUrl!) ,
                                                    )),
                                              )
                                                  : ExtendedImage
                                                  .network(
                                                showListData![index].displayUrl!,
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
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
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
                                                                index])),
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
      bottomNavigationBar: MaxAdView(
        adUnitId: ApplovinService.bannerAdUnitScreen!,
        adFormat: AdFormat.banner,
        isAutoRefreshEnabled: true,
        listener: AdViewAdListener(
            onAdLoadedCallback: (ad) {},
            onAdLoadFailedCallback: (adUnitId, error) {},
            onAdClickedCallback: (ad) {},
            onAdExpandedCallback: (ad) {},
            onAdCollapsedCallback: (ad) {})),
    );
  }

  FlickManager? updateOneUrlFlickManager(List<InstaStories>? showListData) {
    return FlickManager(
      autoPlay: false,
      videoPlayerController:VideoPlayerController.networkUrl(
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
    if(inputData.id == null && inputData.shortcode== null){
      FileDownloader.downloadFile(
          url: inputData.displayUrl!,
          name:
          "com.helpfulapps.downloader_insta_${DateTime.now().millisecondsSinceEpoch}.mp4"
          ,
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
      else{
    FileDownloader.downloadFile(
        url: inputData.displayUrl!,
        name:
        "${inputData.id}_${inputData.shortcode}.mp4"
        ,
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
        });}
  }

  void downloadImage(dynamic inputData) async {
    if(inputData.id == null && inputData.shortcode == null) {
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "com.helpfulapps.downloader_insta_${DateTime.now().millisecondsSinceEpoch}.jpg");
    }
    else{
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
      showListData = (await getStoriesAllData(urlPost)).cast<InstaStories>();
  }
}
