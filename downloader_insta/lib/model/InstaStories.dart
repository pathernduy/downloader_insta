import 'dart:convert';
import 'dart:typed_data';
import 'package:downloader_insta/helper_methods/helperMethods.dart';
import 'package:downloader_insta/rapidapi_service/rapidAPI_story/1000reqPerDay/shahzodomonboyev0_api.dart';
import 'package:downloader_insta/rapidapi_service/rapidAPI_story/500reqPerMon/social_api1_api.dart';
import 'package:downloader_insta/rapidapi_service/rapidAPI_story/eqORhigh10reqPerDay/jotucker_api.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../rapidapi_service/rapidAPI_post/1000reqPerDay/shahzodomonboyev0_api.dart';
import '../rapidapi_service/rapidAPI_story/10000reqPerMon/sattorlive_api.dart';
import '../rapidapi_service/rapidAPI_story/100reqPerMon/illusion_story_api.dart';
import '../rapidapi_service/rapidAPI_story/200reqPerMon/omarmhaimdat_api.dart';
import '../rapidapi_service/rapidAPI_story/eqORhigh10reqPerDay/vahota_api.dart';
import '../rapidapi_service/rapidAPI_story/eqORhigh10reqPerDay/yuananf_api.dart';
import '../rapidapi_service/rapidAPI_story/eqORlow50reqPerMon/capungGGWP_api.dart';
import '../rapidapi_service/rapidAPI_story/eqORlow50reqPerMon/maatootz_story_api1.dart';
import '../rapidapi_service/rapidAPI_story/eqORlow50reqPerMon/mrnewton_api2.dart';
import '../rapidapi_service/rapidAPI_story/eqORlow50reqPerMon/mrngstar_api.dart';
import '../rapidapi_service/rapidAPI_userInfo/1000reqPerDay/thekirtan_api.dart';
import 'userInfo.dart'; // import http package for API calls

class InstaStories {
  String? _id, _shortcode, _displayUrl;
  bool _isVideo = false, _listDisplay = false, _isPrivate = false;
  Uint8List? _thumbnail;

  String? get id => _id;

  set id(String? value) {
    _id = value;
  } // List of images from user feed

  List<dynamic>? _listFeedImagesUrl = [];

  get shortcode => _shortcode;

  set shortcode(value) {
    _shortcode = value;
  }

  get displayUrl => _displayUrl;

  set displayUrl(value) {
    _displayUrl = value;
  }

  get thumbnail => _thumbnail;

  set thumbnail(value) {
    _thumbnail = value;
  }

  bool get isVideo => _isVideo;

  set isVideo(bool value) {
    _isVideo = value;
  }

  get listDisplay => _listDisplay;

  set listDisplay(value) {
    _listDisplay = value;
  }

  get isPrivate => _isPrivate;

  set isPrivate(value) {
    _isPrivate = value;
  }

  List<dynamic>? get listFeedImagesUrl => _listFeedImagesUrl;

  set listFeedImagesUrl(List<dynamic>? value) {
    _listFeedImagesUrl = value;
  }
}

Future<List<dynamic>> getStoriesAllData(String storiesUrl) async {

  List<dynamic> allDataApi = [];
  String patternUrl = '';
  String usernameUrl = '';
  int countApiRequest = 0;
  var responseUserInfo = null;
  UserInfo userInfo = new UserInfo();
  var response = null;

  if (storiesUrl.contains('www.')) {
    patternUrl = storiesUrl.substring(34, storiesUrl.length);
    usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  } else if (storiesUrl.contains('highlights')) {
    patternUrl = storiesUrl.substring(
      34,
    );
    usernameUrl = await HelperMethods().getUsername(storiesUrl);
  } else if (storiesUrl.contains('?utm_source')) {
    String patternstoriesUrl = storiesUrl.substring(34, storiesUrl.length);
    usernameUrl = patternstoriesUrl.substring(0,patternstoriesUrl.indexOf("/"));
    usernameUrl = await HelperMethods().getUsername(storiesUrl);
    //?utm_source
  } else {
    patternUrl = storiesUrl.substring(34, storiesUrl.length);
    usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  }


  try {
    responseUserInfo = await thekirtanUserInfoApiRequest(usernameUrl);
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

  var res = await Dio().get("https://www.instagram.com/graphql/query/?query_hash=de8017ee0a7c9c45ec4260733d81ea31&variables=%7B%22reel_ids%22%3A%5B"+userInfo.id!+"%5D%2C%22tag_names%22%3A%5B%5D%2C%22location_ids%22%3A%5B%5D%2C%22highlight_reel_ids%22%3A%5B%5D%2C%22precomposed_overlay%22%3Afalse%2C%22show_story_viewer_list%22%3Atrue%2C%22story_viewer_fetch_count%22%3A50%2C%22story_viewer_cursor%22%3A%22%22%7D",
      options: Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ));
  String prefixPattern = res.data.toString();
  print(res);

  if (userInfo.isPrivate == true) {
    allDataApi.add(userInfo);
    return allDataApi;
  }

  else if (countApiRequest == 0) {

    try {
      res = await shahzodomonboyev0StoryApiRequest(storiesUrl);
    } on DioException catch (e) {
      print(e.response?.statusCode);
    }

    countApiRequest++;

    if (res.statusCode == 200 && res.data.toString().isNotEmpty) {
      var data = res.data;
      var detail = data['detail'];
      var subdetail = detail['data'];
      List<dynamic>? items = subdetail['items'];

      for (int i = 0; i < items!.length; i++) {
        InstaStories instaObject = new InstaStories();

        if (items[i]['urls'][0]['url'].toString().contains('.mp4')) {
          String urlDownloader = items[i]['urls'][0]['url'];
          String undecodeUrl = "";
          if(urlDownloader.contains("%26dl%3D1")){
            undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.indexOf("%26dl%3D1"));
          }else{
            undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.length);
          }
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
          String undecodeUrl = "";
          if(urlDownloader.contains("%26dl%3D1")){
            undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.indexOf("%26dl%3D1"));
          }else{
            undecodeUrl = urlDownloader.substring(urlDownloader.indexOf("uri=https")+4, urlDownloader.length);
          }
          instaObject._displayUrl = "${Uri.decodeComponent(undecodeUrl)}.jpg";
          allDataApi.add(instaObject);
        }
      }
    } else {
      allDataApi.clear();
    }
    
    //sattorliveStoryApiRequest
    // response = await sattorliveStoryApiRequest(userInfo.username!);
    // print(response.data);
    //
    // if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
    //   var data = response.data;
    //   List<dynamic>? medias = data['medias'];
    //   for (int i = 0; i < medias!.length; i++) {
    //     InstaStories instaStories = new InstaStories();
    //
    //     if (medias![i].toString().contains('mp4')) {
    //       instaStories.isVideo = true;
    //       if (medias![i]['url'].toString().contains('&dl=1')) {
    //         String shortUrl = medias![i]['url']
    //             .toString()
    //             .substring(0, medias![i]['url'].toString().length - 5);
    //         instaStories.displayUrl = shortUrl;
    //       } else {
    //         instaStories.displayUrl = medias![i]['url'].toString();
    //       }
    //
    //       //video_versions!.first['url'].toString()
    //       instaStories._thumbnail = await VideoThumbnail.thumbnailData(
    //         video: instaStories._displayUrl!,
    //         imageFormat: ImageFormat.JPEG,
    //         maxHeight: 0,
    //         // maxWidth: ,
    //         // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //         quality: 100,
    //       );
    //     } else {
    //       instaStories.isVideo = false;
    //       if (medias![i]['url'].toString().contains('&dl=1')) {
    //         String shortUrl = medias![i]['url']
    //             .toString()
    //             .substring(0, medias![i]['url'].toString().length - 5);
    //         instaStories.displayUrl = shortUrl;
    //       } else {
    //         instaStories.displayUrl =
    //             medias![i]['image_versions2']!['candidates'][0]['url'];
    //       }
    //     }
    //     allDataApi.add(instaStories);
    //   }
    // } else {
    //   countApiRequest++;
    //   allDataApi.clear();
    // }
  }
  else if (countApiRequest == 1) {
    print('userInfo.username! $userInfo.username!');

    response = await vahotaStoryApiRequest(userInfo.username!);
    print(response.data);

    var data = json.decode(response.data);
    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      Map body = data['body'];
      List<dynamic>? stories = body['stories'];
      for (int i = 0; i < stories!.length; i++) {
        InstaStories instaStories = new InstaStories();
        Map image_versions2 = stories![i]['image_versions2'];

        if (stories![i].toString().contains('video_versions')) {
          List<dynamic>? video_versions = stories![i]['video_versions'];
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${video_versions!.first['url'].toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          List<dynamic>? candidates = image_versions2!['candidates'];
          instaStories.isVideo = false;
          instaStories.displayUrl = candidates!.first['url'].toString();
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 2) {
    print('userInfo.username! $userInfo.username!');

    response = await jotuckerStoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      var reel = data['reel'];
      List<dynamic>? items = reel['items'];
      for (int i = 0; i < items!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (items![i].toString().contains('video_versions')) {
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${items![i]['video_versions']![0]['url'].toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl =
              items![i]['image_versions2']!['candidates'][0]['url'];
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 3) {
    print('userInfo.username! $userInfo.username!');

    response = await yuananfStoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      var reel = data['reel'];
      List<dynamic>? items = reel['items'];
      for (int i = 0; i < items!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (items![i].toString().contains('video_versions')) {
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${items![i]['video_versions']![0]['url'].toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl =
              items![i]['image_versions2']!['candidates'][0]['url'];
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 4) {
    print('userInfo.username! $userInfo.username!');

    response = await socialapiStoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      var reel = data['data'];
      List<dynamic>? items = reel['items'];
      for (int i = 0; i < items!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (items![i].toString().contains('video_versions')) {
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${items![i]['video_versions']![0]['url'].toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl =
              items![i]['image_versions2']!['items'][0]['url'];
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 5) {
    print('userInfo.username! $userInfo.username!');

    response = await omarmhaimdatStoryApiRequest(userInfo.id!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      var reels_media = data['reels_media'];
      List<dynamic>? items = reels_media[0]['items'];
      for (int i = 0; i < items!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (items![i].toString().contains('video_versions')) {
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${items![i]['video_versions']![0]['url'].toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl =
              items![i]['image_versions2']!['candidates'][0]['url'];
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 6) {
    print('userInfo.username! $userInfo.username!');

    response = await illusionStoryApiRequest(userInfo.username!);
    print(response.data);

    var data = json.decode(response.data);
    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      for (int i = 0; i < data.length;) {
        InstaStories instaStories = new InstaStories();
        if (data[i].toString().contains(".mp4")) {
          instaStories.isVideo = true;
          instaStories.displayUrl = "${data[i].toString()}.mp4";
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
          i += 2;
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl = data[i].toString();
          i++;
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 7) {
    print('userInfo.username! $userInfo.username!');

    response = await capungGGWPStoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      List<dynamic>? items = data['story'];
      for (int i = 0; i < items!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (items![i].toString().contains('video_src')) {
          instaStories.isVideo = true;
          instaStories.displayUrl = "${items![i]['video_src']!.toString()}";
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl = items![i]['static_image']!;
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 8) {
    print('userInfo.username! $userInfo.username!');

    response = await mrngstarStoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      var item = data['data'];
      List<dynamic>? stories = item['stories'];
      for (int i = 0; i < stories!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (stories![i].toString().contains('video_versions')) {
          instaStories.isVideo = true;
          instaStories.displayUrl = stories![i]['video_versions']![0]['url'].toString();
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl = stories![i]['image_versions2']!['candidates'][0]['url'];
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 9) {
    print('userInfo.username! $userInfo.username!');

    response = await mrnewton2StoryApiRequest(userInfo.username!);
    print(response.data);

    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      var data = response.data;
      List<dynamic>? stories = data['stories'];
      for (int i = 0; i < stories!.length; i++) {
        InstaStories instaStories = new InstaStories();

        if (stories![i]['Type'].toString().contains('Story-Video')) {
          instaStories.isVideo = true;
          instaStories.displayUrl = stories![i]['media'].toString();
          //video_versions!.first['url'].toString()
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl = stories![i]['media'].toString();
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }
  else if (countApiRequest == 10) {
    print('userInfo.username! $userInfo.username!');

    response = await maatootz1StoryApiRequest(userInfo.username!);
    print(response.data);

    var data = json.decode(response.data);
    if (response.statusCode == 200 && response.data.toString().isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        InstaStories instaStories = new InstaStories();
        if (data[i].toString().contains(".mp4")) {
          instaStories.isVideo = true;
          instaStories.displayUrl = "${data[i].toString()}.mp4";
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else if (data[i].toString().contains(".jpg") ||
            data[i].toString().contains(".png") &&
                (data[i + 1].toString().contains(".mp4"))) {
        } else {
          instaStories.isVideo = false;
          instaStories.displayUrl = data[i].toString();
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  }

  return allDataApi;
}
