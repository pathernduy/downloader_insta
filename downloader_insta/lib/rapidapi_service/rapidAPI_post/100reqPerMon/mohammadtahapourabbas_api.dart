import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../model/InstaStories.dart'; // import http package for API calls


// rapidapi for insta post
Future<Response> mohammadtahapourabbasPostApiRequest(String paramLink)async{
  String parsedData = Uri.encodeComponent(paramLink);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      'https://instagram-downloader15.p.rapidapi.com/api/v1/media?url_or_username=$parsedData',
      // queryParameters: {'url':'$paramUsername'},
      options: Options(
        headers: {
          "content-type": "application/json; charset=UTF-8",
          'x-rapidapi-key': key,
          'x-rapidapi-host': 'instagram-downloader15.p.rapidapi.com',
        },
      ),
    );
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

