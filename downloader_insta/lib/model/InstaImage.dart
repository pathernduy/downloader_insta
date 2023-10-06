import 'dart:convert';

import 'package:dio/dio.dart'; // import http package for API calls

class InstaImage {
  String? _id, _shortcode, _displayUrl, _username;
  bool _isVideo = false, _listDisplay = false;
  // List of images from user feed

  List<dynamic>? _listFeedImagesUrl = [];

  String? get id => _id;

  String? get shortcode => _shortcode;

  String? get displayUrl => _displayUrl;

  bool get isVideo => _isVideo;

  bool get listDisplay => _listDisplay;

  List<dynamic>? get listFeedImagesUrl => _listFeedImagesUrl;
}

Future<List<dynamic>> getAllData(String username) async {
  List<dynamic> allDataApi = [];
  final dio = Dio();
  String url = "https://www.instagram.com/";
  var res = await dio.get(Uri.encodeFull(url +
      username +
      "/?__a=1&__d=dis")); // adding /?__a=1&__d=dis at the end will return json data

  var data = res.data["graphql"];
  print("data receiver: $data");
  // var graphql = data['graphql'];
  var user = data['user'];
  var biography = user['biography'];

  // _bio = biography;
  // var myfollowers = user['edge_followed_by'];
  // var myfollowing = user['edge_follow'];
  // _followers = myfollowers['count'].toString();
  // _following = myfollowing['count'].toString();
  // _website = user['external_url'];
  // _imgurl = user['profile_pic_url_hd'];
  List<dynamic>? _feedImagesUrl = user['edge_owner_to_timeline_media']['edges'];
  // .map<String>((image) => image['node']['display_url'] as String)
  // .toList();
  if (_feedImagesUrl!.isNotEmpty)
    // ignore: curly_braces_in_flow_control_structures
    for (var i in _feedImagesUrl) {
      InstaImage instaObject = new InstaImage();
      List<dynamic>? _subFeedImagesUrl = [];
      InstaImage subInstaObject;
      instaObject._id = i['node']['id'];
      instaObject._shortcode = i['node']['shortcode'];
      instaObject._displayUrl = i['node']['display_url'];
      if (i['node']['edge_sidecar_to_children'] != null) {
        for (var y in i['node']['edge_sidecar_to_children']['edges']) {
          subInstaObject = new InstaImage();
          subInstaObject._id = y['node']['id'];
          subInstaObject._shortcode = y['node']['shortcode'];
          subInstaObject._displayUrl = y['node']['display_url'];
          instaObject._listFeedImagesUrl!.add(subInstaObject);
        }

        allDataApi.add(instaObject);
        // _subFeedImagesUrl.clear();
      } else {
        instaObject._listDisplay = false;
        instaObject._listFeedImagesUrl = [];
        allDataApi.add(instaObject);
      }
    }

  return allDataApi;
}
