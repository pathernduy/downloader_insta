import 'dart:typed_data';


import 'package:dio/dio.dart';
import 'package:downloader_insta/helper_methods/helperMethods.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'admob_service/AdsMobService.dart';


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

  BannerAd? _bannerAd;
  bool isBannerAdLoaded = false;
  RewardedAd? _rewardedAd;
  bool isRewardedAdLoaded = false;

  String urlInitial ='';


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
                setState(() => _rewardedAd = null))) ;
  }

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    _createRewardedAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    urlInitial =
    // "https://scontent.cdninstagram.com/v/t50.2886-16/396540377_717167380318969_5695952730692669220_n.mp4?_nc_ht=instagram.fsgn2-9.fna.fbcdn.net&_nc_cat=101&_nc_ohc=Encz7C7jDzwAX_SKpKl&edm=AABBvjUBAAAA&ccb=7-5&oh=00_AfBXLXeKZnb8fGYbuuF-lPQ8Ulkas5oG2JbgrPYXnzl2jQ&oe=6559E08F&_nc_sid=4f4799.mp4";
        HelperMethods().convertUrlObjectToString(widget.i).toString();
    String replaceUrl ='';
    if(urlInitial.contains("instagram.flwo4-1.fna.fbcdn.net")){
      replaceUrl = urlInitial.replaceRange(8,39,"scontent.cdninstagram.com");
    }else{
      replaceUrl = urlInitial.replaceRange(8,39,"scontent.cdninstagram.com");
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
                  borderRadius: BorderRadius.circular!(16),
                  child: (widget.i.isVideo == true)
                      ?
                  InAppWebView(
                    onLoadStart: (controller, url) {

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


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              TextButton(
                  onPressed: () async {
                    (_rewardedAd != null) ?
                    _rewardedAd!.show(
                      onUserEarnedReward:
                          (AdWithoutView
                      ad,
                          RewardItem
                          rewardItem) {
                            HelperMethods().downloadData(widget.i);
                      })
                    :
                    HelperMethods().downloadData(widget.i);
                    },
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Download",
                    style: TextStyle(color: Colors.white),
                  )),

            ],)

          ],
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


}
