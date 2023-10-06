import 'dart:typed_data';

import 'package:applovin_max/applovin_max.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:video_player/video_player.dart';

import 'applovin_service/ads_service.dart';

class ViewImage extends StatefulWidget {
  dynamic? i;
  ViewImage(this.i, {super.key});
  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {

  // void downloadData(dynamic inputData) async {
  //   var response = await Dio().get("${inputData.displayUrl}",
  //       options: Options(responseType: ResponseType.bytes));
  //   await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
  //       quality: 60, name: "${inputData.id}_${inputData.shortcode}");
  //   Fluttertoast.showToast(
  //       msg: "Succesfully Downloaded",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.grey,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  void downloadData(dynamic inputData) async {
    if(inputData.isVideo){
      FileDownloader.downloadFile(
          url: inputData.displayUrl!,
          name: "${inputData.id}_${inputData.shortcode}",
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
    }else{
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "${inputData.id}_${inputData.shortcode}.jpg");

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




  @override
  Widget build(BuildContext context) {
    int pageList = 0;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 300.w,
              height:500.h,
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
                    BorderRadius.circular(16),
                    child: (widget.i
                        .isVideo ==
                        true)
                        ? FlickVideoPlayer(
                      flickVideoWithControls:
                      FlickVideoWithControls(
                        controls:
                        FlickPortraitControls(
                          progressBarSettings:
                          FlickProgressBarSettings(
                            playedColor:
                            Colors.green,
                          ),
                        ),
                        videoFit:
                        BoxFit.scaleDown,
                      ),
                      flickManager:
                      FlickManager(
                          autoInitialize:
                          true,
                          // getPlayerControlsTimeout: ,
                          autoPlay: false,
                          videoPlayerController:
                          VideoPlayerController
                              .networkUrl(
                            Uri.parse(widget.i.displayUrl!,),
                          )),
                    )
                        : ExtendedImage.network(
                      widget.i.displayUrl!,
                      // i,
                      clearMemoryCacheWhenDispose:
                      true,
                      fit: BoxFit.cover,
                    )),
              ),
            ),

            // Container(
            //   child: widget.i.listFeedImagesUrl!.isEmpty
            //       ? ExtendedImage.network(
            //           widget.i.displayUrl!,
            //           // i,
            //           clearMemoryCacheWhenDispose: true,
            //           clearMemoryCacheIfFailed: true,
            //           fit: BoxFit.cover,
            //         )
            //       : ImageSlideshow(
            //           // width: 120,
            //           onPageChanged: (value) {
            //             pageList = value;
            //           },
            //           children: [
            //               // ignore: unused_local_variable
            //               // for (InstaImage y in widget.i.listFeedImagesUrl!)
            //               //   ExtendedImage.network(
            //               //     y.displayUrl!,
            //               //     // i,
            //               //     clearMemoryCacheWhenDispose: true,
            //               //     clearMemoryCacheIfFailed: true,
            //               //     fit: BoxFit.cover,
            //               //   )
            //             ]),
            //   width: MediaQuery.of(context).size.width * 0.8,
            //   height: MediaQuery.of(context).size.height * 0.75,
            // ),
            TextButton(
                onPressed: () => downloadData(widget.i),
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  "Download",
                  style: TextStyle(color: Colors.white),
                )),
          ],
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
}
