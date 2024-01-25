import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:downloader_insta/error&exception/errorException.dart';
import 'package:downloader_insta/model/userInfo.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

import '../rapidapi_service/rapidAPI_post/1000reqPerDay/shahzodomonboyev0_api.dart';
import '../rapidapi_service/rapidAPI_post/100reqPerMon/illusion_api.dart';
import '../rapidapi_service/rapidAPI_post/100reqPerMon/maxcukerbergs007_api.dart';
import '../rapidapi_service/rapidAPI_post/100reqPerMon/mohammadtahapourabbas_api.dart';
import '../rapidapi_service/rapidAPI_post/100reqPerMon/mrnewton_api1.dart';
import '../rapidapi_service/rapidAPI_post/100reqPerMon/neotank_api.dart';
import '../rapidapi_service/rapidAPI_post/10reqPerDay/jotucker_api.dart';
import '../rapidapi_service/rapidAPI_post/10reqPerDay/matabt_api.dart';
import '../rapidapi_service/rapidAPI_post/10reqPerDay/yuananf_api.dart';
import '../rapidapi_service/rapidAPI_post/150reqPerMon/thekirtan_api.dart';
import '../rapidapi_service/rapidAPI_post/200reqPerMon/omarmhaimdat_api.dart';
import '../rapidapi_service/rapidAPI_post/250reqPerMon/nikansara_api.dart';
import '../rapidapi_service/rapidAPI_post/500reqPerMon/netogamikk_api.dart';
import '../rapidapi_service/rapidAPI_post/500reqPerMon/social_api1_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/JustMobi_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/capungGGWP_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/glavier_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/instagapicom_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/maatootz_post_api.dart';
import '../rapidapi_service/rapidAPI_post/50reqPerMon/mrngstar_api.dart';
import '../rapidapi_service/rapidAPI_userInfo/1000reqPerDay/thekirtan_api.dart';

// import http package for API calls

class InstaPost {
  String? _id, _shortcode, _displayUrl, _errorString;
  bool _isVideo = false, _listDisplay = false, _isPrivate = false;
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

  bool get isPrivate => _isPrivate;

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
  String paramShortcode = '';

  var responseUserInfo = null;
  UserInfo userInfo = new UserInfo();
  // var responce = await dio.get(url,
  //   options: Options(
  //       headers: headers
  //   ),);
  // if(responce.statusCode == 200){
  //   print(responce.data.toString);
  // }

  if (postUrl.contains("?igshid")) {
    url = postUrl.substring(0, postUrl.indexOf("?igshid"));
    paramShortcode = url.substring(28, url.length - 1);
  } else if (postUrl.contains("?img_index") ) {
    url = postUrl.substring(0, postUrl.indexOf("?igsh"));
    paramShortcode = url.substring(28, url.length - 1);
  } else if (postUrl.contains("?igsh") ) {
    url = postUrl.substring(0, postUrl.indexOf("?igsh"));

  } else {
    url = postUrl;
  }
  /*Response ({"message":"Please wait a few minutes before you try again.","require_login":true,"status":"fail"})*/

  var res = await Dio().get("$url?__a=1&__d=dis",
      options: Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ));
  String prefixPattern = res.data.toString();

  paramShortcode = url.substring(28, url.length - 1);

  try {
    responseUserInfo = await thekirtanUserInfoApiRequest(url);
  } catch (e) {
    print(e);
  }

  if (responseUserInfo != null && responseUserInfo.statusCode == 200) {
    var data = responseUserInfo.data;
    var item = data[0];
    userInfo.id = item['pk'];
    userInfo.username = item['username'];
    userInfo.isPrivate = item['is_private'];
  }

  if (userInfo.isPrivate == true) {
    allDataApi.add(userInfo);
    return allDataApi;
  }
  else{
    while (allDataApi.isEmpty)
      // (res.statusCode != 200 || (res.statusCode == 200 && res.data.isEmpty ))
        {
      if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 1 ||
          prefixPattern.contains("<!DOCTYPE html>")) {
        try {
          res = await shahzodomonboyev0PostApiRequest(url);
        } on DioException catch (e) {
          print(e.response?.statusCode);
        }

        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var detail = data['detail'];
          List<dynamic>? items = detail['items'];

          for (int i = 0; i < items!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (items[i]['urls'][0]['extension'].toString().contains('mp4')) {
              String urlDownloader = items[i]['urls'][0]['url'];
              String undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.indexOf("%26dl%3D1"));
              instaObject._displayUrl = "${Uri.decodeComponent(undecodeUrl)}.mp4";
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
              String urlDownloader = items[i]['urls'][0]['url'];
              String undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.indexOf("%26dl%3D1"));
              instaObject._displayUrl = "${Uri.decodeComponent(undecodeUrl)}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }



        //add these codes below the ones above
        // try {
        //   res = await jotuckerPostApiRequest(paramShortcode);
        // } on DioException catch (e) {
        //   print(e.response?.statusCode);
        // }
        //
        // countCallRapidRequest++;
        //
        // if (errorException().checkException(res.toString()) &&
        //     res != null &&
        //     res.statusCode == 200) {
        //   var data = res.data;
        //   var items = data['items'][0];
        //   List<dynamic>? carousel_media = items['carousel_media'];
        //
        //   for (int i = 0; i < carousel_media!.length; i++) {
        //     InstaPost instaObject = new InstaPost();
        //
        //     if (carousel_media[i].toString().contains('video_versions')) {
        //       instaObject._displayUrl =
        //           "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
        //       instaObject._thumbnail = await VideoThumbnail.thumbnailData(
        //         video: instaObject._displayUrl!,
        //         imageFormat: ImageFormat.JPEG,
        //         maxHeight: 0,
        //         // maxWidth: ,
        //         // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        //         quality: 100,
        //       );
        //       //"${media_with_thumb[i]['thumbnail'].toString()}.mp4";
        //       instaObject._isVideo = true;
        //       allDataApi.add(instaObject);
        //     } else {
        //       instaObject._displayUrl =
        //           "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
        //       allDataApi.add(instaObject);
        //     }
        //   }
        // } else {
        //   allDataApi.clear();
        // }

      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 2) {
        //mrngstar api post 50req/month
        res = await mrngstarPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var item = data['data'];
          var edge_sidecar_to_children = item['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 3) {
        res = await matabtPostApiRequest(url);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data[0];
          List<dynamic>? carousel_media = items['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 4) {
        //maatootz api post 50req/month
        res = await yuananfPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data['items'][0];
          List<dynamic>? carousel_media = items['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 5) {
        res = await netogamikkPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data['data'];
          var graphql = data['graphql'];
          var shortcode_media = graphql['shortcode_media'];
          var edge_sidecar_to_children =
          shortcode_media['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 6) {
        res = await socialapiPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data['data'];
          List<dynamic>? carousel_media = items['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 7) {
        res = await nikansaraPostApiRequest(url);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var edge_sidecar_to_children = data['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 8) {
        res = await omarmhaimdatPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var xdt_api__v1__media__shortcode__web_info =
          data['xdt_api__v1__media__shortcode__web_info'];
          var items = xdt_api__v1__media__shortcode__web_info['item'];
          List<dynamic>? carousel_media = items[0]['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 9) {
        res = await thekirtanPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data[0];
          List<dynamic>? carousel_media = items[0]['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions']['candidates'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 10) {
        res = await maxcukerbergs007PostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data['items'];
          List<dynamic>? carousel_media = items[0]['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 11) {
        res = await mohammadtahapourabbasPostApiRequest(url);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          List<dynamic>? media = data['media'];

          for (int i = 0; i < media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (media[i]['is_video'] == true) {
              instaObject._displayUrl = "${media[i]['url'].toString()}.mp4";
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
              instaObject._displayUrl = "${media[i]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 12) {
        res = await mrnewton1PostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var item = data['data'];
          var xdt_shortcode_media = item['xdt_shortcode_media'];
          var edge_sidecar_to_children =
          xdt_shortcode_media['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 13) {
        res = await neotankPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var edge_sidecar_to_children = data['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 14) {
        //maatootz api post 50req/month
        res = await illusionPostApiRequest(url);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data['items'];
          List<dynamic>? carousel_media = items[0]['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i]['video_versions'][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 15) {
        //maatootz api post 50req/month
        res = await justmobiPostApiRequest(url);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var items = data['data'];
          List<dynamic>? mediaList = items['mediaList'];

          for (int i = 0; i < mediaList!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (mediaList[i].toString().contains('videoUrl')) {
              instaObject._displayUrl =
              "${mediaList[i]['videoUrl'].toString()}.mp4";
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
              "${mediaList[i]['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 16) {
        //maatootz api post 50req/month
        res = await capungGGWPPostApiRequest(url);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var media = data['media'];
          List<dynamic>? children = media['children'];

          for (int i = 0; i < children!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (children[i].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${children[i]['video_url'].toString()}.mp4";
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
              "${children[i]['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 17) {
        //maatootz api post 50req/month
        res = await instagapicomPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (errorException().checkException(res.toString()) &&
            res != null &&
            res.statusCode == 200) {
          var data = res.data;
          var media = data['data'];
          List<dynamic>? carousel_media = media['carousel_media'];

          for (int i = 0; i < carousel_media!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (carousel_media[i].toString().contains('video_versions')) {
              instaObject._displayUrl =
              "${carousel_media[i][0]['url'].toString()}.mp4";
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
              "${carousel_media[i]['image_versions2']['candidates'][0].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 18) {
        //maatootz api post 50req/month
        res = await glavierPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var graphql = data['graphql'];
          var shortcode_media = graphql['shortcode_media'];
          var edge_sidecar_to_children =
          shortcode_media['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 19) {
        //maatootz api post 50req/month
        res = await maatootzPostApiRequest(url);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          List<dynamic>? media_with_thumb = data['media_with_thumb'];
          for (int i = 0; i < media_with_thumb!.length; i++) {
            InstaPost instaObject = new InstaPost();

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
      } else if (errorException().checkException(prefixPattern) &&
          countCallRapidRequest == 20) {
        //maatootz api post 50req/month
        res = await mrngstarPostApiRequest(paramShortcode);
        countCallRapidRequest++;

        if (res.statusCode == 200 &&
            res.data.toString().isNotEmpty &&
            res.data != null) {
          var data = res.data;
          var items = data['data'];
          var edge_sidecar_to_children = items['edge_sidecar_to_children'];
          List<dynamic>? listNode = edge_sidecar_to_children['edges'];
          for (int i = 0; i < listNode!.length; i++) {
            InstaPost instaObject = new InstaPost();

            if (listNode[i]['node'].toString().contains('video_url')) {
              instaObject._displayUrl =
              "${listNode[i]['node']['video_url'].toString()}.mp4";
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
              "${listNode[i]['node']['display_url'].toString()}.jpg";
              allDataApi.add(instaObject);
            }
          }
        } else {
          allDataApi.clear();
        }
      } else if (prefixPattern.contains('graphql')) {
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
      } else if (countCallRapidRequest > 19) {
        break;
      } else {
        countCallRapidRequest++;
        // allDataApi.add(res.data.toString());
        // allDataApi.add(res.data.toString());
        print(res.data.toString());
      }
    }
  }



  return allDataApi;
}
