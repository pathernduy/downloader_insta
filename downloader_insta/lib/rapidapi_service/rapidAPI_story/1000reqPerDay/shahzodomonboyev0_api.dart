import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../helper_methods/helperMethods.dart';
import '../../../model/InstaStories.dart'; // import http package for API calls

////email phatdinh.work@gmail.com
// '6ae41ebf1amsh3c53c3c23620f18p1574e8jsn5093714fbf64'
//pathernduy@gmail.com
// '74da2f9e9bmshce8d60192c94677p1551e8jsn6262e9e72c06'

// rapidapi for insta post
Future<Response> shahzodomonboyev0StoryApiRequest(String paramLink)async{
  String parsedData = Uri.encodeComponent(paramLink);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      'https://instagram-post-and-reels-downloader.p.rapidapi.com/insta/?url=$paramLink',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            //pathernduy@gmail.com
            'x-rapidapi-key': '74da2f9e9bmshce8d60192c94677p1551e8jsn6262e9e72c06',
            'x-rapidapi-host': 'instagram-post-and-reels-downloader.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if((response.statusCode == 200 && response.data.toString().isNotEmpty) || response.statusCode == 429){
      return response;
    }
  }
  return response;
}

