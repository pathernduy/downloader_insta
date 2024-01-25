import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../model/InstaStories.dart'; // import http package for API calls


// rapidapi for insta post
Future<Response> mrngstarPostApiRequest(String paramLink)async{
  String parsedData = Uri.encodeComponent(paramLink);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().post(
        'https://all-media-downloader.p.rapidapi.com/rapid_download/download',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'all-media-downloader.p.rapidapi.com',
          },
        ),
        data:{
          'url': parsedData,
        }
    );
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

