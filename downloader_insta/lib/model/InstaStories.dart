import 'dart:convert';
import 'dart:typed_data';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../rapidapi_service/illusion_story_api.dart';
import '../rapidapi_service/vahota_api.dart';
import 'instaApi.dart'; // import http package for API calls

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
  //******** code of https://rapidapi.com/arraybobo/api/instagram-media-downloader
  // const options = {
  //   method: 'GET',
  //   url: 'https://instagram-media-downloader.p.rapidapi.com/rapid/allstories.php',
  //   params: {
  //     url: '$storiesUrl'
  //   },
  //   headers: {
  //     'X-RapidAPI-Key': '74da2f9e9bmshce8d60192c94677p1551e8jsn6262e9e72c06',
  //     'X-RapidAPI-Host': 'instagram-media-downloader.p.rapidapi.com'
  //   }
  // };

  // https://instagram.com/stories/zyn.oiiiiiiii/3182195549875829278?utm_source=ig_story_item_share&igshid=ODk2MDJkZDc2Zg==
  // https://instagram.com/stories/duongle.fitness/3182287639284178637?utm_source=ig_story_item_share&igshid=ODk2MDJkZDc2Zg==
  // https://www.instagram.com/khahgiangg/?__a=1&__d=dis
  List<dynamic> allDataApi = [];
  bool checkPrivate = false;
  String patternUrl = '';
  String usernameUrl = '';
  int countApiRequest = 0;
  if (storiesUrl.contains('www.')) {
    patternUrl = storiesUrl.substring(
      34,
    );
    usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  } else {
    patternUrl = storiesUrl.substring(
      30,
    );
    usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  }

  checkPrivate = await checkIsPrivate(usernameUrl);
  if (checkPrivate == true) {
  } else if (countApiRequest == 0) {
    print('usernameUrl $usernameUrl');

    final response = await vahotaStoryApiRequest(usernameUrl);
    print(response.body);

    var data = json.decode(response.body);
    if (response.statusCode == 200 && response.body.toString().isNotEmpty) {
      Map body = data['body'];
      List<dynamic>? stories = body['stories'];
      for (int i = 0; i < stories!.length; i++) {
        InstaStories instaStories = new InstaStories();
        Map image_versions2 = stories![i]['image_versions2'];
        List<dynamic>? candidates = image_versions2['candidates'];
        if (candidates![i].toString().contains(".mp4")) {
          instaStories.isVideo = true;
          instaStories.displayUrl =
              "${candidates!.first['url'].toString()}.mp4";
          instaStories._thumbnail = await VideoThumbnail.thumbnailData(
            video: instaStories._displayUrl!,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 0,
            // maxWidth: ,
            // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            quality: 100,
          );
        } else if (candidates![i].toString().contains(".jpg") ||
            candidates![i].toString().contains(".png")) {
          instaStories.isVideo = false;
          instaStories.displayUrl = candidates!.first['url'].toString();
        }
        allDataApi.add(instaStories);
      }
    } else {
      countApiRequest++;
      allDataApi.clear();
    }
  } else if (countApiRequest == 1) {
    print('usernameUrl $usernameUrl');

    final response = await illusionStoryApiRequest(usernameUrl);
    print(response.body);

    var data = json.decode(response.body);
    if (response.statusCode == 200 && response.body.toString().isNotEmpty) {
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
  } else if (countApiRequest == 2) {
    print('usernameUrl $usernameUrl');

    final response = await illusionStoryApiRequest(usernameUrl);
    print(response.body);

    var data = json.decode(response.body);
    if (response.statusCode == 200 && response.body.toString().isNotEmpty) {
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

Future<bool> checkIsPrivate(String username) async {
  final url =
      Uri.parse('https://www.instagram.com/' + username + '/?__a=1&__d=dis');

  final response = await http.get(
    url,
  );

  var data = json.decode(response.body);
  Map items = data['graphql'];
  Map user = items['user'];
  bool is_private = user['is_private'];
  return is_private;
}
