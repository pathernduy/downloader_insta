import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../helper_methods/helperMethods.dart';
import '../../../model/InstaStories.dart'; // import http package for API calls


// rapidapi for insta post
Future<Response> jotuckerPostApiRequest(String paramShortcode)async{
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      //https://instagram-scraper2.p.rapidapi.com/media_info_v2?short_code=Czgn3v4pkcj
        'https://instagram-scraper2.p.rapidapi.com/media_info_v2?short_code=$paramShortcode',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'instagram-scraper2.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if((response.statusCode == 200 && response.data.toString().isNotEmpty) || response.statusCode == 429){
      return response;
    }
  }
  return response;
}

