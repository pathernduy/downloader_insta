import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../helper_methods/helperMethods.dart';
import '../../../model/InstaStories.dart'; // import http package for API calls

//download post only
// rapidapi for insta post
Future<Response> portamine781StoryApiRequest(String paramLink)async{
  String urlAPI = Uri.encodeComponent(paramLink);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      //https://fast-tubedown-videos-api.p.rapidapi.com/?metaplatf=insta&metaurl=https%3A%2F%2Fwww.facebook.com%2Fwatch%2F%3Fv%3D286653967026118
        'https://fast-tubedown-videos-api.p.rapidapi.com/?metaplatf=insta&metaurl=$urlAPI',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'fast-tubedown-videos-api.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

