import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

import '../rapidapi_service/rapidAPI_post/50reqPerMon/maatootz_post_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/mrngstar_api.dart';

// import http package for API calls

class InstaReel {
  String? _id, _shortcode, _displayUrl, _errorString;
  bool _isVideo = false, _listDisplay = false;
  Uint8List? _thumbnail;

  // List of images from user feed

  List<dynamic>? _listFeedImagesUrl = [];

  String? get id => _id;

  String? get shortcode => _shortcode;

  String? get displayUrl => _displayUrl;

  Uint8List? get thumbnail => _thumbnail;

  String? get errorString => _errorString;

  bool get isVideo => _isVideo;

  bool get listDisplay => _listDisplay;

  List<dynamic>? get listFeedImagesUrl => _listFeedImagesUrl;
}

Future<List<dynamic>> getReelAllData(String postUrl) async {
  List<dynamic> allDataApi = [];

  final dio = Dio();
  // int indexOfPatternMobile = postUrl.indexOf("?igshid");
  // int indexOfPatternPC = postUrl.indexOf("?img_index");
  HttpClient httpClient = HttpClient();
  httpClient.userAgent;
  String url = '';
  int countCallRapidRequest = 0;
  // var responce = await dio.get(url,
  //   options: Options(
  //       headers: headers
  //   ),);
  // if(responce.statusCode == 200){
  //   print(responce.data.toString);
  // }

  if (postUrl.contains("?igshid")) {
    url = postUrl.substring(0, postUrl.indexOf("?igshid"));
  } else if (postUrl.contains("?img_index")) {
    url = postUrl.substring(0, postUrl.indexOf("?img_index"));
  } else {
    url = postUrl.substring(0, postUrl.lastIndexOf("/"));
  }
  /*Response ({"message":"Please wait a few minutes before you try again.","require_login":true,"status":"fail"})*/

  var res = await Dio().get("$url?__a=1&__d=dis",
      options: Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ));
  String prefixPattern = res.data.toString();



  while (allDataApi.isEmpty)
    // (res.statusCode != 200 || (res.statusCode == 200 && res.data.isEmpty ))
      {
    if (prefixPattern.contains(
        "{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&
        countCallRapidRequest == 1 ||
        prefixPattern.contains("<!DOCTYPE html>")) {
      //maatootz api post
      res = await maatootzPostApiRequest(url);
      countCallRapidRequest++;

      if (res.statusCode == 200 &&
          res.data.toString().isNotEmpty &&
          res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaReel instaObject = new InstaReel();

          if (media_with_thumb[i]['Type'].toString().contains('Video')) {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.mp4";
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            //"${media_with_thumb[i]['thumbnail'].toString()}.mp4";
            instaObject._isVideo = true;
            allDataApi.add(instaObject);
          } else {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {
        allDataApi.clear();
      }

    }
    else if (prefixPattern.contains(
        "{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&
        countCallRapidRequest == 2) {
      //mrngstar api post
      res = await mrngstarPostApiRequest(url);
      countCallRapidRequest++;

      if (res.statusCode == 200 &&
          res.data.toString().isNotEmpty &&
          res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaReel instaObject = new InstaReel();

          if (media_with_thumb[i]['Type'].toString().contains('Video')) {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.mp4";
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            //"${media_with_thumb[i]['thumbnail'].toString()}.mp4";
            instaObject._isVideo = true;
            allDataApi.add(instaObject);
          } else {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {
        allDataApi.clear();
      }
    } else if (prefixPattern.contains(
        "{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&
        countCallRapidRequest == 3) {
      //mrngstar api post
      res = await maatootzPostApiRequest(url);
      countCallRapidRequest++;

      if (res.statusCode == 200 &&
          res.data.toString().isNotEmpty &&
          res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaReel instaObject = new InstaReel();

          if (media_with_thumb[i]['Type'].toString().contains('Video')) {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.mp4";
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            //"${media_with_thumb[i]['thumbnail'].toString()}.mp4";
            instaObject._isVideo = true;
            allDataApi.add(instaObject);
          } else {
            instaObject._displayUrl =
            "${media_with_thumb[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {
        allDataApi.clear();
      }
    }
    // else if (prefixPattern.contains(
    //         "{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&
    //     countCallRapidRequest == 4) {
    // }
    else if (prefixPattern.contains('graphql')) {
      var data = res.data;
      print("data receiver: $data");
      Map items = data['graphql'];

      Map shortcodeMedia = items['shortcode_media'];

      if (shortcodeMedia.containsKey('edge_sidecar_to_children')) {
        List<dynamic>? _listPost =
        shortcodeMedia['edge_sidecar_to_children']['edges'];

        if (_listPost!.isNotEmpty)
          for (var i in _listPost) {
            InstaReel instaObject = new InstaReel();
            if (i['node']['is_video'] == true) {
              instaObject._id = i['node']['id'];
              instaObject._shortcode = i['node']['shortcode'];
              instaObject._displayUrl = "${i['node']['video_url']}.mp4";
              instaObject._thumbnail = await VideoThumbnail.thumbnailData(
                video: instaObject._displayUrl!,
                imageFormat: ImageFormat.JPEG,
                maxHeight: 0,
                // maxWidth: ,
                // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                quality: 100,
              );
              instaObject._isVideo = i['node']['is_video'];
            } else {
              instaObject._id = i['node']['id'];
              instaObject._shortcode = i['node']['shortcode'];
              instaObject._displayUrl = i['node']['display_url'];
            }
            allDataApi.add(instaObject);
          }
      } else {
        InstaReel instaObject = new InstaReel();
        if (shortcodeMedia['is_video'] == true) {
          if (shortcodeMedia['display_url'] != null) {
            instaObject._id = shortcodeMedia['id'];
            instaObject._shortcode = shortcodeMedia['shortcode'];
            instaObject._displayUrl = "${shortcodeMedia['video_url']}.mp4";
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            instaObject._isVideo = shortcodeMedia['is_video'];
          } else {
            instaObject._id = shortcodeMedia['id'];
            instaObject._shortcode = shortcodeMedia['shortcode'];
            instaObject._displayUrl = "${shortcodeMedia['video_url']}.mp4";
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            instaObject._isVideo = shortcodeMedia['is_video'];
          }
        } else {
          if (shortcodeMedia['image_versions2'] == null) {
            instaObject._id = shortcodeMedia['id'];
            instaObject._shortcode = shortcodeMedia['shortcode'];
            instaObject._displayUrl = shortcodeMedia['display_url'];
          } else {
            instaObject._id = shortcodeMedia['id'];
            instaObject._shortcode = shortcodeMedia['pk'];
            instaObject._displayUrl =
            shortcodeMedia['image_versions2']['candidates'][0]['url'];
          }
        }

        allDataApi.add(instaObject);
      }
    } else if (prefixPattern.contains('items')) {
      // var data = res.data;
      var data = res.data;
      print("data receiver: $data");
      // Map items = data['graphql'];

      var items = data['items'][0];

      if (items.containsKey('carousel_media')) {
        List<dynamic>? _listPost = items['carousel_media'];

        if (_listPost!.isNotEmpty)
          for (var i in _listPost) {
            InstaReel instaObject = new InstaReel();
            instaObject._id = i['id'];
            instaObject._shortcode = i['pk'];
            instaObject._displayUrl =
            i['image_versions2']['candidates'][0]['url'];
            allDataApi.add(instaObject);
          }
      } else {
        InstaReel instaObject = new InstaReel();
        if (items.containsKey('video_versions')) {
          var videoVersion = items['video_versions'];
          instaObject._id = videoVersion[0]['id'];
          instaObject._shortcode = items['pk'];
          instaObject._displayUrl = "${videoVersion[0]['url']}.mp4";
          instaObject._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaObject._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
          instaObject._isVideo = true;
        } else {
          instaObject._id = items['id'];
          instaObject._shortcode = items['pk'];
          instaObject._displayUrl =
          items['image_versions2']['candidates'][0]['url'];
        }

        allDataApi.add(instaObject);
      }
    } else if (countCallRapidRequest > 3) {
      break;
    } else {
      countCallRapidRequest++;
      // allDataApi.add(res.data.toString());
      // allDataApi.add(res.data.toString());
      print(res.data.toString());
    }
  }

  return allDataApi;
}
