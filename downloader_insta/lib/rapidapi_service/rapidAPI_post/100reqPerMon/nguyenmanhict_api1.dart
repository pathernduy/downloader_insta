import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../model/InstaStories.dart'; // import http package for API calls


// rapidapi for insta post
Future<Response> nguyenmanhictPostApiRequest(String paramShortcode)async{
  // String parsedData = Uri.encodeComponent(paramLink);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().post(
        'https://instagram-media-api.p.rapidapi.com/media/shortcode',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'instagram-media-api.p.rapidapi.com',
          },
        ),
        data:{
        'shortcode' : paramShortcode,
        'proxy' : ''
        }
    );
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

