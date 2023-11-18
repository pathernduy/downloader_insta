import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/uzapishop_api.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:extended_image/extended_image.dart';
import 'package:path_provider/path_provider.dart';

import '../rapidapi_service/SAIDAHROR_api.dart';
import '../rapidapi_service/maatootz_post_api.dart';
import '../rapidapi_service/mrngstar_api.dart'; // import http package for API calls

class InstaPost {
  String? _id, _shortcode, _displayUrl, _errorString;
  bool _isVideo = false,
      _listDisplay = false;
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

Future<List<dynamic>> getPostAllData(String postUrl) async {
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
    url = postUrl.substring(0, postUrl.indexOf("?igshid") );
  } else if (postUrl.contains("?img_index")) {
    url = postUrl.substring(0, postUrl.indexOf("?img_index") );
  } else {
    url = postUrl.substring(0, postUrl.lastIndexOf("/") );
  }
  /*Response ({"message":"Please wait a few minutes before you try again.","require_login":true,"status":"fail"})*/

  var res = await Dio().get("$url?__a=1&__d=dis",options: Options (
    validateStatus: (_) => true,
    contentType: Headers.jsonContentType,
    responseType:ResponseType.json,
  ));
  String prefixPattern = res.data.toString();
  // try{
  //   var res1 = await dio.get(
  //       "$url/?__a=1&__d=dis"); // adding /?__a=1&__d=dis at the end will return json data
  //   String prefixPattern1 = res1.data.toString();
  // }on DioException catch (e) {
  //   // The request was made and the server responded with a status code
  //   // that falls out of the range of 2xx and is also not 304.
  //   if (e.response != null) {
  //     print(e.response!.data);
  //     print(e.response!.headers);
  //     print(e.response!.requestOptions);
  //   } else {
  //     // Something happened in setting up or sending the request that triggered an Error
  //     print(e.requestOptions);
  //     print(e.message);
  //   }
  // }


  // xài while sau này
  while (allDataApi.isEmpty)
  // (res.statusCode != 200 || (res.statusCode == 200 && res.data.isEmpty ))
      {
    if (prefixPattern.contains("{message: Please wait a few minutes before you try again., require_login: true, status: fail}") && countCallRapidRequest == 1 || prefixPattern.contains("<!DOCTYPE html>")) {

      res = await uzapishopPostApiRequest(url);
      countCallRapidRequest++;
      // 0:"https://scontent.cdninstagram.com/v/t50.2886-16/377490711_175043198947964_587192338833431908_n.mp4?_nc_ht=scontent.cdninstagram.com&_nc_cat=108&_nc_ohc=DckoV_ndMEAAX8dR7sx&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfDsRRXV2Khk1MT3-8ldEIx5-5Dyr_Wah5GxswM1IpXuzg&oe=65153617&_nc_sid=10d13b"
      // 1:"https://scontent.cdninstagram.com/v/t50.2886-16/376841088_1520790485394605_2697396614198064867_n.mp4?_nc_ht=scontent.cdninstagram.com&_nc_cat=105&_nc_ohc=27Vf9tOjvNIAX_7cNuf&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfB3SyzAvESj_0blyzV8AIexpPd4bBthOea020uEOLO8Fg&oe=6515762E&_nc_sid=10d13b"
      // 2:"https://scontent.cdninstagram.com/v/t51.2885-15/376857140_1500057897410362_997120354491921715_n.jpg?stp=dst-jpg_e35_p1080x1080&_nc_ht=scontent.cdninstagram.com&_nc_cat=110&_nc_ohc=3A8ipUGwMKwAX8hBIA4&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfDEFmh8XZHdB3Qkieu1_FQZqR0QKWQYlW9rQbNview5QQ&oe=65197D5B&_nc_sid=10d13b"

      // 0:"https://snapxcdn.com/v2/?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJodHRwczovL3Njb250ZW50LmNkbmluc3RhZ3JhbS5jb20vdi90NTAuMjg4Ni0xNi8zNzc0OTA3MTFfMTc1MDQzMTk4OTQ3OTY0XzU4NzE5MjMzODgzMzQzMTkwOF9uLm1wND9fbmNfaHQ9c2NvbnRlbnQuY2RuaW5zdGFncmFtLmNvbSZfbmNfY2F0PTEwOCZfbmNfb2hjPThFdC1ZTkN2T1FvQVg5RFJFal8mZWRtPUFQczE3Q1VCQUFBQSZjY2I9Ny01Jm9oPTAwX0FmRGhvUUt6aklZaEJ0N01zU3lpNDc2bkdnNWwxbjVXR2YtWWpEamJUWTFkd2cmb2U9NjUxQzc2NTcmX25jX3NpZD0xMGQxM2IiLCJmaWxlbmFtZSI6IlNuYXBzYXZlLmFwcF8zNzc0OTA3MTFfMTc1MDQzMTk4OTQ3OTY0XzU4NzE5MjMzODgzMzQzMTkwOF9uLm1wNCJ9.Hp1xXClha2KiA7fgKHaQ_oAsFtHrUK6fD_LxGp10V_4&dl=1\\"
      // 1:"https://snapxcdn.com/v2/?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJodHRwczovL3Njb250ZW50LmNkbmluc3RhZ3JhbS5jb20vdi90NTAuMjg4Ni0xNi8zNzY4NDEwODhfMTUyMDc5MDQ4NTM5NDYwNV8yNjk3Mzk2NjE0MTk4MDY0ODY3X24ubXA0P19uY19odD1zY29udGVudC5jZG5pbnN0YWdyYW0uY29tJl9uY19jYXQ9MTA1Jl9uY19vaGM9ZWFFeUlBUlVxMjhBWF9EaUhYUCZlZG09QVBzMTdDVUJBQUFBJmNjYj03LTUmb2g9MDBfQWZDR0NHWHV3bUthWkF3YW9BcEpGZnNxWTlkOHE4eTBMQ21MSF9SRFFZbWhyUSZvZT02NTFDQjY2RSZfbmNfc2lkPTEwZDEzYiIsImZpbGVuYW1lIjoiU25hcHNhdmUuYXBwXzM3Njg0MTA4OF8xNTIwNzkwNDg1Mzk0NjA1XzI2OTczOTY2MTQxOTgwNjQ4Njdfbi5tcDQifQ.rO1-Wo5zMwlfvTpPJopNyuiRS84pVHhsCOyTfEF3Qe8&dl=1\\"
      // 2:"https://scontent.cdninstagram.com/v/t51.2885-15/376857140_1500057897410362_997120354491921715_n.jpg?stp=dst-jpg_e35_p1080x1080&_nc_ht=scontent.cdninstagram.com&_nc_cat=110&_nc_ohc=3A8ipUGwMKwAX8hBIA4&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfDEFmh8XZHdB3Qkieu1_FQZqR0QKWQYlW9rQbNview5QQ&oe=65197D5B&_nc_sid=10d13b"
      
      if (res.statusCode == 200 && res.data.toString().isNotEmpty && res.data != null) {
        var data = res.data;
        if(data.toString().contains("instagrap.app") || data.toString().contains("http://88.198.25.15:8088")){

          allDataApi.clear();
        }else{
          for (int i = 0; i < data.length; i++) {
            InstaPost instaObject = new InstaPost();
            if (data[i].toString().contains("scontent.cdninstagram.com")) {
              if (data[i].toString().contains(".mp4")) {
                instaObject._displayUrl = "${data[i].toString()}.mp4";
                instaObject._thumbnail = await VideoThumbnail.thumbnailData(
                  video: instaObject._displayUrl!,
                  imageFormat: ImageFormat.JPEG,
                  maxHeight: 0,
                  // maxWidth: ,
                  // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                  quality: 100,
                );
                instaObject._isVideo = true;
                allDataApi.add(instaObject);
              } else {
                instaObject._displayUrl = "${data[i].toString()}.jpg";
                allDataApi.add(instaObject);
              }

            } else if (data[i].toString().contains("snapxcdn.com")) {
              instaObject._displayUrl = "${data[i].toString()}.mp4";
              instaObject._thumbnail = await VideoThumbnail.thumbnailData(
                video: instaObject._displayUrl!,
                imageFormat: ImageFormat.JPEG,
                maxHeight: 0,
                // maxWidth: ,
                // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
                quality: 100,
              );
              instaObject._isVideo = true;
              allDataApi.add(instaObject);
            }
            // else if (data[i].toString().contains("instagrap.app") || data[i].toString().contains("http://88.198.25.15:8088")) {
            //   // res = await saidahrorPostApiRequest(url);
            //   countCallRapidRequest++;
            //   allDataApi.clear();
            // }
            else{
              print("\n"+data[i].toString());
              allDataApi.clear();
            }
        }


        }
      } else {
        allDataApi.clear();
      }

    }
    else if (prefixPattern.contains("{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&  countCallRapidRequest == 2){
      //saidahror api post
      res = await saidahrorPostApiRequest(url);
      countCallRapidRequest++;
      
      if (res.statusCode == 200 && res.data.toString().isNotEmpty && res.data != null && res.data != null) {
        var data = res.data;
        List<dynamic>? mediaList = data['media'];
        for (int i = 0; i < mediaList!.length; i++) {
          InstaPost instaObject = new InstaPost();

          if (mediaList[i]['type'].toString().contains('video')) {
            if(mediaList[i]['url'].toString().contains('&dl=1')){
              instaObject._displayUrl = "${mediaList[i]['url'].toString().substring(0,mediaList[i]['url'].toString().length-5)}.mp4";
            }else{
              instaObject._displayUrl = "${mediaList[i]['url'].toString()}.mp4";
            }
            instaObject._thumbnail = await VideoThumbnail.thumbnailData(
              video: instaObject._displayUrl!,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 0,
              // maxWidth: ,
              // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
              quality: 100,
            );
            allDataApi.add(instaObject);
            instaObject._isVideo = true;
          } else {
            instaObject._displayUrl = "${mediaList[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {

        allDataApi.clear();
      }
    }
    else if (prefixPattern.contains("{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&  countCallRapidRequest == 3){
      //maatootz api post
      res = await maatootzPostApiRequest(url);
      countCallRapidRequest++;
      
      if (res.statusCode == 200 && res.data.toString().isNotEmpty && res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaPost instaObject = new InstaPost();

            if (media_with_thumb[i]['Type'].toString().contains('Video')) {
              instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.mp4";
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
              instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
        }
      } else {

        allDataApi.clear();
      }
    }
    else if (prefixPattern.contains("{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&  countCallRapidRequest == 4){
      //mrngstar api post
      res = await mrngstarPostApiRequest(url);
      countCallRapidRequest++;
      
      if (res.statusCode == 200 && res.data.toString().isNotEmpty && res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaPost instaObject = new InstaPost();

          if (media_with_thumb[i]['Type'].toString().contains('Video')) {
            instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.mp4";
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
            instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {

        allDataApi.clear();
      }
    }
    else if (prefixPattern.contains("{message: Please wait a few minutes before you try again., require_login: true, status: fail}") &&  countCallRapidRequest == 5){
      //mrngstar api post
      res = await maatootzPostApiRequest(url);
      countCallRapidRequest++;
      
      if (res.statusCode == 200 && res.data.toString().isNotEmpty && res.data != null) {
        var data = res.data;
        List<dynamic>? media_with_thumb = data['media_with_thumb'];
        for (int i = 0; i < media_with_thumb!.length; i++) {
          InstaPost instaObject = new InstaPost();

          if (media_with_thumb[i]['Type'].toString().contains('Video')) {
            instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.mp4";
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
            instaObject._displayUrl = "${media_with_thumb[i]['media'].toString()}.jpg";
            allDataApi.add(instaObject);
          }
        }
      } else {
        allDataApi.clear();
      }
    }
    else if (prefixPattern.contains('graphql') ) {
      var data = res.data;
      print("data receiver: $data");
      Map items = data['graphql'];

      Map shortcodeMedia = items['shortcode_media'];

      if (shortcodeMedia.containsKey('edge_sidecar_to_children')) {
        List<dynamic>? _listPost =
        shortcodeMedia['edge_sidecar_to_children']['edges'];

        if (_listPost!.isNotEmpty)
          for (var i in _listPost) {
            InstaPost instaObject = new InstaPost();
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
        InstaPost instaObject = new InstaPost();
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
    }
    else if (prefixPattern.contains('items') ) {
      // var data = res.data;
      var data = res.data;
      print("data receiver: $data");
      // Map items = data['graphql'];

      var items = data['items'][0];

      if (items.containsKey('carousel_media')) {
        List<dynamic>? _listPost = items['carousel_media'];

        if (_listPost!.isNotEmpty)
          for (var i in _listPost) {
            InstaPost instaObject = new InstaPost();
            instaObject._id = i['id'];
            instaObject._shortcode = i['pk'];
            instaObject._displayUrl =
            i['image_versions2']['candidates'][0]['url'];
            allDataApi.add(instaObject);
          }
      } else {
        InstaPost instaObject = new InstaPost();
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
    }
    else if (countCallRapidRequest > 6){
      break;
    }
    else{
      countCallRapidRequest++;
      // allDataApi.add(res.data.toString());
      // allDataApi.add(res.data.toString());
      print(res.data.toString());
    }
  }


    //{"message":"Please wait a few minutes before you try again.","require_login":true,"status":"fail"}
    // if (prefixPattern.contains(
    //     "{message: Please wait a few minutes before you try again., require_login: true, status: fail}")) {
    //   // res = await uzapishopPostApiRequest(url);
    //
    //   res = await uzapishopPostApiRequest(url);
    //   // 0:"https://scontent.cdninstagram.com/v/t50.2886-16/377490711_175043198947964_587192338833431908_n.mp4?_nc_ht=scontent.cdninstagram.com&_nc_cat=108&_nc_ohc=DckoV_ndMEAAX8dR7sx&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfDsRRXV2Khk1MT3-8ldEIx5-5Dyr_Wah5GxswM1IpXuzg&oe=65153617&_nc_sid=10d13b"
    //   // 1:"https://scontent.cdninstagram.com/v/t50.2886-16/376841088_1520790485394605_2697396614198064867_n.mp4?_nc_ht=scontent.cdninstagram.com&_nc_cat=105&_nc_ohc=27Vf9tOjvNIAX_7cNuf&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfB3SyzAvESj_0blyzV8AIexpPd4bBthOea020uEOLO8Fg&oe=6515762E&_nc_sid=10d13b"
    //   // 2:"https://scontent.cdninstagram.com/v/t51.2885-15/376857140_1500057897410362_997120354491921715_n.jpg?stp=dst-jpg_e35_p1080x1080&_nc_ht=scontent.cdninstagram.com&_nc_cat=110&_nc_ohc=3A8ipUGwMKwAX8hBIA4&edm=APs17CUBAAAA&ccb=7-5&oh=00_AfDEFmh8XZHdB3Qkieu1_FQZqR0QKWQYlW9rQbNview5QQ&oe=65197D5B&_nc_sid=10d13b"
    //   var data = res.data;
    //   for (int i = 0; i < data.length; i++) {
    //     InstaPost instaObject = new InstaPost();
    //     if (data[i].toString().contains("scontent.cdninstagram.com")) {
    //       if (data[i].toString().contains(".mp4")) {
    //         instaObject._displayUrl = "${data[i].toString()}.mp4";
    //         // XFile thumbnailFile = await VideoThumbnail.thumbnailData(maxWidth: ,
    //         //   video: instaObject._displayUrl!,
    //         //   imageFormat: ImageFormat.JPEG,
    //         //   maxHeight: 0,
    //         //   // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //         //   quality: 100,
    //         // );
    //         instaObject._thumbnail = await VideoThumbnail.thumbnailData(
    //           video: instaObject._displayUrl!,
    //           imageFormat: ImageFormat.JPEG,
    //           maxHeight: 0,
    //           // maxWidth: ,
    //           // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //           quality: 100,
    //         );
    //         instaObject._isVideo = true;
    //       } else {
    //         instaObject._displayUrl = "${data[i].toString()}.jpg";
    //       }
    //     } else if (data[i].toString().contains("instagrap.app")) {
    //       res = await saidahrorPostApiRequest(url);
    //       countCallRapidRequest++;
    //       allDataApi.clear();
    //     }
    //
    //
    //     allDataApi.add(instaObject);
    //   }
    // }
    // else if (prefixPattern.contains('graphql')) {
    //   var data = res.data;
    //   print("data receiver: $data");
    //   Map items = data['graphql'];
    //
    //   Map shortcodeMedia = items['shortcode_media'];
    //
    //   if (shortcodeMedia.containsKey('edge_sidecar_to_children')) {
    //     List<dynamic>? _listPost =
    //     shortcodeMedia['edge_sidecar_to_children']['edges'];
    //
    //     if (_listPost!.isNotEmpty)
    //       for (var i in _listPost) {
    //         InstaPost instaObject = new InstaPost();
    //         if (i['node']['is_video'] == true) {
    //           instaObject._id = i['node']['id'];
    //           instaObject._shortcode = i['node']['shortcode'];
    //           instaObject._displayUrl = "${i['node']['video_url']}.mp4";
    //           instaObject._thumbnail = await VideoThumbnail.thumbnailData(
    //             video: instaObject._displayUrl!,
    //             imageFormat: ImageFormat.JPEG,
    //             maxHeight: 0,
    //             // maxWidth: ,
    //             // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //             quality: 100,
    //           );
    //           instaObject._isVideo = i['node']['is_video'];
    //         } else {
    //           instaObject._id = i['node']['id'];
    //           instaObject._shortcode = i['node']['shortcode'];
    //           instaObject._displayUrl = i['node']['display_url'];
    //         }
    //         allDataApi.add(instaObject);
    //       }
    //   } else {
    //     InstaPost instaObject = new InstaPost();
    //     if (shortcodeMedia['is_video'] == true) {
    //       if (shortcodeMedia['display_url'] != null) {
    //         instaObject._id = shortcodeMedia['id'];
    //         instaObject._shortcode = shortcodeMedia['shortcode'];
    //         instaObject._displayUrl = "${shortcodeMedia['video_url']}.mp4";
    //         instaObject._thumbnail = await VideoThumbnail.thumbnailData(
    //           video: instaObject._displayUrl!,
    //           imageFormat: ImageFormat.JPEG,
    //           maxHeight: 0,
    //           // maxWidth: ,
    //           // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //           quality: 100,
    //         );
    //         instaObject._isVideo = shortcodeMedia['is_video'];
    //       } else {
    //         instaObject._id = shortcodeMedia['id'];
    //         instaObject._shortcode = shortcodeMedia['shortcode'];
    //         instaObject._displayUrl = "${shortcodeMedia['video_url']}.mp4";
    //         instaObject._thumbnail = await VideoThumbnail.thumbnailData(
    //           video: instaObject._displayUrl!,
    //           imageFormat: ImageFormat.JPEG,
    //           maxHeight: 0,
    //           // maxWidth: ,
    //           // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //           quality: 100,
    //         );
    //         instaObject._isVideo = shortcodeMedia['is_video'];
    //       }
    //     } else {
    //       if (shortcodeMedia['image_versions2'] == null) {
    //         instaObject._id = shortcodeMedia['id'];
    //         instaObject._shortcode = shortcodeMedia['shortcode'];
    //         instaObject._displayUrl = shortcodeMedia['display_url'];
    //       } else {
    //         instaObject._id = shortcodeMedia['id'];
    //         instaObject._shortcode = shortcodeMedia['pk'];
    //         instaObject._displayUrl =
    //         shortcodeMedia['image_versions2']['candidates'][0]['url'];
    //       }
    //     }
    //
    //     allDataApi.add(instaObject);
    //   }
    // }
    // else if (prefixPattern.contains('items')) {
    //   // var data = res.data;
    //   var data = res.data;
    //   print("data receiver: $data");
    //   // Map items = data['graphql'];
    //
    //   var items = data['items'][0];
    //
    //   if (items.containsKey('carousel_media')) {
    //     List<dynamic>? _listPost = items['carousel_media'];
    //
    //     if (_listPost!.isNotEmpty)
    //       for (var i in _listPost) {
    //         InstaPost instaObject = new InstaPost();
    //         instaObject._id = i['id'];
    //         instaObject._shortcode = i['pk'];
    //         instaObject._displayUrl =
    //         i['image_versions2']['candidates'][0]['url'];
    //         allDataApi.add(instaObject);
    //       }
    //   } else {
    //     InstaPost instaObject = new InstaPost();
    //     if (items.containsKey('video_versions')) {
    //       var videoVersion = items['video_versions'];
    //       instaObject._id = videoVersion[0]['id'];
    //       instaObject._shortcode = items['pk'];
    //       instaObject._displayUrl = "${videoVersion[0]['url']}.mp4";
    //       instaObject._thumbnail = await VideoThumbnail.thumbnailData(
    //         video: instaObject._displayUrl!,
    //         imageFormat: ImageFormat.JPEG,
    //         maxHeight: 0,
    //         // maxWidth: ,
    //         // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //         quality: 100,
    //       );
    //       instaObject._isVideo = true;
    //     } else {
    //       instaObject._id = items['id'];
    //       instaObject._shortcode = items['pk'];
    //       instaObject._displayUrl =
    //       items['image_versions2']['candidates'][0]['url'];
    //     }
    //
    //     allDataApi.add(instaObject);
    //   }
    // }
    // else {
    //   // allDataApi.add(res.data.toString());
    //   // allDataApi.add(res.data.toString());
    //   print(res.data.toString());
    // }

    return allDataApi;
  }


