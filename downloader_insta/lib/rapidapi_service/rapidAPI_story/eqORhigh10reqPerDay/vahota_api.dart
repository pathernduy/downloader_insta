import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../model/InstaStories.dart'; // import http package for API calls



Future<Response> vahotaStoryApiRequest(String paramUsername)async{
  var response = null;
  for(var key in rapidAPIKeys.Keys){

    response = await Dio().get(
        'https://instagram-story-and-highlights-saver.p.rapidapi.com/api/stories?username=@$paramUsername',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'instagram-story-and-highlights-saver.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

Future<bool> checkIsPrivate(String username) async{
  final url = Uri.parse( 'https://www.instagram.com/'+username+'/?__a=1&__d=dis');
  final response = await get(
    url,
  );
  var data = json.decode(response.body);
  Map items = data['graphql'];
  Map user = items['user'];
  bool is_private = user['is_private'];
  return is_private;
}
