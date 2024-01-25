import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../helper_methods/helperMethods.dart';
import '../../../model/InstaStories.dart'; // import http package for API calls

//download post only
// rapidapi for insta post
Future<Response> omarmhaimdatPostApiRequest(String paramShortcode)async{
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      //https://instagram230.p.rapidapi.com/post/details?shortcode=Czgn3v4pkcj
        'https://instagram230.p.rapidapi.com/post/details?shortcode=$paramShortcode',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'instagram230.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

