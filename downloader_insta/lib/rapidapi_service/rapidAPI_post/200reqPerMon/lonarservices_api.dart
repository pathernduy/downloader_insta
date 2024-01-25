import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
import 'package:extended_image/extended_image.dart';

import '../../../helper_methods/helperMethods.dart';
import '../../../model/InstaStories.dart'; // import http package for API calls

//https://rapidapi.com/iq.faceok/api/instagram-looter2
//download post only
// rapidapi for insta post
Future<Response> lonarservicesPostApiRequest(String paramUrl)async{
  String urlAPI = Uri.encodeComponent(paramUrl);
  var response = null;
  for(var key in rapidAPIKeys.Keys){
    response = await Dio().get(
      'https://instagram-looter2.p.rapidapi.com/post?link=$urlAPI',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': key,
            'x-rapidapi-host': 'instagram-looter2.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    if(response.statusCode == 200 && response.data.toString().isNotEmpty){
      return response;
    }
  }
  return response;
}

