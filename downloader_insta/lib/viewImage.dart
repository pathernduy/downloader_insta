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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'applovin_service/ads_service.dart';

class ViewImage extends StatefulWidget {
  dynamic? i;
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

  ViewImage(this.i, this.webViewController,this.refreshController,{super.key});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {


  late var url;
  double progress = 0;
  var urlController = TextEditingController();
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

  String urlInitial ='';


  void downloadData(dynamic inputData) async {
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
              print('FILE ${DateTime.now().millisecondsSinceEpoch} HAS PROGRESS $progress');
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
              print('FILE ${DateTime.now().millisecondsSinceEpoch} HAS PROGRESS $progress');
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

  String convertUrlObjectToString(dynamic paramObject){
    String url = paramObject.displayUrl!.toString();
    return url;
  }



  @override
  Widget build(BuildContext context) {
    urlInitial =
    // "https://scontent.cdninstagram.com/v/t50.2886-16/396540377_717167380318969_5695952730692669220_n.mp4?_nc_ht=instagram.fsgn2-9.fna.fbcdn.net&_nc_cat=101&_nc_ohc=Encz7C7jDzwAX_SKpKl&edm=AABBvjUBAAAA&ccb=7-5&oh=00_AfBXLXeKZnb8fGYbuuF-lPQ8Ulkas5oG2JbgrPYXnzl2jQ&oe=6559E08F&_nc_sid=4f4799.mp4";
        convertUrlObjectToString(widget.i).toString();

    String replaceUrl = urlInitial.replaceRange(8,39,"scontent.cdninstagram.com");
    @override
    void initState() {
      super.initState();
      // if(widget.webViewController?.isNull){
      //   // widget.webViewController.
      // }else{
      //   widget.refreshController = PullToRefreshController(
      //       onRefresh: () {
      //         widget.webViewController!.reload();
      //       },
      //       options: PullToRefreshOptions(
      //           color: Colors.white, backgroundColor: Colors.black87));
      // }

    }



    @override
    void dispose() {
      super.dispose();
    }

    return Scaffold(
      appBar: AppBar(
          // title:  Text(widget.i.displayUrl!),
          automaticallyImplyLeading: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 300.w,
              height: 500.h,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: (widget.i.isVideo == true)
                      ?
                  // WebViewWidget(controller: WebViewController()
                  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  //   ..setBackgroundColor(const Color(0x00000000))
                  //   ..setNavigationDelegate(
                  //     NavigationDelegate(
                  //       onProgress: (int progress) {
                  //         // Update loading bar.
                  //       },
                  //       onPageStarted: (String url) {},
                  //       onPageFinished: (String url) {},
                  //       onWebResourceError: (WebResourceError error) {},
                  //       onNavigationRequest: (NavigationRequest request) {
                  //         if (request.url.startsWith('https://www.google.com/')) {
                  //           return NavigationDecision.prevent;
                  //         }
                  //         return NavigationDecision.navigate;
                  //       },
                  //     ),
                  //   )
                  //   ..loadRequest(Uri.parse(
                  //       // urlInitial
                  //       "https://instagram.fsgn2-8.fna.fbcdn.net/o1/v/t16/f1/m69/GMDLoRc_ExR41Z0CAHLm2TWwC1pUbkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-8.fna.fbcdn.net&_nc_cat=102&vs=3168204693473839_2317145144&_nc_vs=HBksFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HTURMb1JjX0V4UjQxWjBDQUhMbTJUV3dDMXBVYmtZTEFBQUYVAALIAQAVAhg6cGFzc3Rocm91Z2hfZXZlcnN0b3JlL0dLMktxeGRaaWlnS3RpSURBRUdnczZveXJzUnZia1lMQUFBRhUCAsgBACgAGAAbAYgHdXNlX29pbAEwFQAAJqSB7u%2BUpcQ%2FFQIoAkMzLBdAIrtkWhysCBgSZGFzaF9iYXNlbGluZV8xX3YxEQB17gcA&_nc_rid=6a81edf6ea&ccb=9-4&oh=00_AfAN__njHdfRXPorzbK2PlzFwZaHeb2WzrII7xlYbO_vhQ&oe=655880FD&_nc_sid=4f4799"
                  //   ))
                  // )



                  InAppWebView(
                    onLoadStart: (controller, url) {
                      // var v = url.toString();
                      // setState(() {
                      //   urlController.text = widget.i.displayUrl!.toString();
                      // });
                    },
                    onLoadStop: (controller, url) {
                      widget.refreshController!.endRefreshing();
                    },
                    onLoadError: (controller, url, code, message) {
                      widget.refreshController!.endRefreshing();
                    },
                    pullToRefreshController:  widget.refreshController,
                    onWebViewCreated: (controller) => widget.webViewController = controller,
                    initialUrlRequest: URLRequest(url: Uri.parse(
                        // widget.i.displayUrl!
                        // "https://instagram.fsgn2-9.fna.fbcdn.net/o1/v/t16/f1/m69/GICWmABrFzu-Ax0DABFXYwcJHwg3bkYLAAAF.mp4?efg=eyJxZV9ncm91cHMiOiJbXCJpZ193ZWJfZGVsaXZlcnlfdnRzX290ZlwiXSIsInZlbmNvZGVfdGFnIjoidnRzX3ZvZF91cmxnZW4uY2Fyb3VzZWxfaXRlbS5jMi43MjAuYmFzZWxpbmUifQ&_nc_ht=instagram.fsgn2-9.fna.fbcdn.net&_nc_cat=109&vs=987154402357115_3229001429&_nc_vs=HBkcFQIYOnBhc3N0aHJvdWdoX2V2ZXJzdG9yZS9HSUNXbUFCckZ6dS1BeDBEQUJGWFl3Y0pId2czYmtZTEFBQUYVAALIAQAoABgAGwGIB3VzZV9vaWwBMBUAACbAnO6gz8eHQBUCKAJDMywXQEcmZmZmZmYYEmRhc2hfYmFzZWxpbmVfMV92MREAde4HAA%3D%3D&_nc_rid=6009a88c46&ccb=9-4&oh=00_AfBnujDF-rWte0CizBF8bY6T4KGJ67M_XeSEl9XByZHckg&oe=6559F6EF&_nc_sid=4f4799"
                        replaceUrl //(the right one)
                        // urlInitial
                    )
                    ),
                  )



                      :ExtendedImage.network(
                          widget.i.displayUrl!,
                          // i,
                          clearMemoryCacheWhenDispose: true,
                          fit: BoxFit.cover,
                        )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              TextButton(
                  onPressed: () => downloadData(widget.i),
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Download",
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  onPressed: () {
                    //
                    // setState(() {
                    //   widget.webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(
                    //       widget.i.displayUrl!)));
                    //   widget.webViewController!.reload();
                    // });

                    },
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Refresh",
                    style: TextStyle(color: Colors.white),
                  )),
            ],)

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
