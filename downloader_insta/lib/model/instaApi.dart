import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart'; // import dio package for API calls

class FlutterInsta {
  String url = "https://www.instagram.com/";
  final dio = Dio();
  String? _followers, _following, _website, _bio, _imgurl, _username, _id;
  bool isVideo = false, _isPrivate=false;
  // List of images from user feed
  List<String>? _feedImagesUrl;

  //Download reels video
  Future<String> downloadReels(String link) async {
    var linkEdit = link.replaceAll(" ", "").split("/");
    var downloadURL = await dio.get(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "?__a=1&__d=dis");
    var data = downloadURL.data['graphql'];
    var shortcodeMedia = data['shortcode_media'];
    var videoUrl = shortcodeMedia['video_url'];
    return videoUrl; // return download link
  }

  //get profile details
  Future<void> getProfileData(String username) async {
    try {
      var res = await dio.get(Uri.encodeFull(url +
          username +
          "/?__a=1&__d=dis")); // adding /?__a=1&__d=dis at the end will return json data
      var data = res.data['graphql'];
      print(data.toString());
      var user = data['user'];
      var biography = user['biography'];
      _id = user['id'];
      _bio = biography;
      var myfollowers = user['edge_followed_by'];
      var myfollowing = user['edge_follow'];
      _followers = myfollowers['count'].toString();
      _following = myfollowing['count'].toString();
      _website = user['external_url'];
      _imgurl = user['profile_pic_url_hd'];

      _feedImagesUrl = user['edge_owner_to_timeline_media']['edges']
          .map<String>((image) => image['node']['display_url'] as String)
          .toList();
      // _imageName = user['edge_owner_to_timeline_media']['edges']
      // isVideo = user['edge_owner_to_timeline_media']['edges'];
      this._username = username;
    } catch (e) {
      print(e);
    }
  }

  String? get id => _id;

  String? get followers => _followers; // number of followers of the user

  get following => _following; // number of following on the user

  get username => _username; // Username of the user

  get website => _website; // Link in the bio

  get bio => _bio; // Instagram bio of the user

  get imgurl => _imgurl; // Profile picture URL

  List<String>? get feedImagesUrl =>
      _feedImagesUrl; // List of URLs of feed images
}
