import 'dart:convert';
import 'dart:typed_data';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../rapidapi_service/illusion_story_api.dart';
import '../rapidapi_service/maatootz_story_api.dart';
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
  //checkIsPrivate is in illusion_story_api.dart file
  checkPrivate = await checkIsPrivate(usernameUrl);
  if (storiesUrl.contains('www.')) {
    patternUrl = storiesUrl.substring(
      34,
    );
    usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  } else if (storiesUrl.contains('highlights')){
    patternUrl = storiesUrl.substring(
      34,
    );
    usernameUrl = await getUsername(storiesUrl);
  } else {
  patternUrl = storiesUrl.substring(
  30,
  );
  usernameUrl = patternUrl.substring(0, patternUrl.indexOf("/"));
  }


  if (checkPrivate == true) {
  } else if (countApiRequest == 0) {
    print('usernameUrl $usernameUrl');

    final response = await vahotaStoryApiRequest(usernameUrl);
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
  } else if (countApiRequest == 1) {
    print('usernameUrl $usernameUrl');

    final response = await illusionStoryApiRequest(usernameUrl);
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
  } else if (countApiRequest == 2) {
    print('usernameUrl $usernameUrl');

    final response = await maatootzStoryApiRequest(usernameUrl);
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


//start mutual methods
Future<bool> checkIsPrivate(String username) async{


  final response = await Dio().get(
      'https://www.instagram.com/'+username+'/?__a=1&__d=dis');

  var data = json.decode(response.data);
  Map items = data['graphql'];
  Map user = items['user'];
  bool is_private = user['is_private'];
  return is_private;
}
//"message" -> "Please wait a few minutes before you try again."

Future<String> getUsername(String url) async {
  final urlRequest = Uri.parse(url + '/?__a=1&__d=dis');

  // final response = await http.get(
  //   url,
  // );

  final response = await Dio().get(
    url,
  );
  String username = '';

  var data = json.decode(response.data);
  if (data
      .toString()
      .contains("Please wait a few minutes before you try again.")) {
    return username;
  } else {
    username = data['user']['username'].toString();
    return username;
  }
}
/*
* json for highlight get request api after add /?__a=1&__d=dis
* {
	"user": {
		"id": "1152500318",
		"profile_pic_url": "https://instagram.fsgn2-9.fna.fbcdn.net/v/t51.2885-19/398839605_2043866312639963_3562212760234049305_n.jpg?stp=dst-jpg_s150x150&_nc_ht=instagram.fsgn2-9.fna.fbcdn.net&_nc_cat=111&_nc_ohc=WM7HAkYTj4kAX_uO56W&edm=AKGtDmEBAAAA&ccb=7-5&oh=00_AfDz1abFLzXXaVnZGTi49dVH9-Yl7KlXyiD8fVwZBZq6wg&oe=655756A2&_nc_sid=2078dd",
		"username": "duongle.fitness"
	},
	"highlight": {
		"id": 18045959020472376,
		"title": "Mục đít chính"
	},
	"showQRModal": false
}
* */


//end mutual methods