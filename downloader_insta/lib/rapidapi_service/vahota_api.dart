import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';

import '../model/InstaStories.dart'; // import http package for API calls



Future<Response> vahotaStoryApiRequest(String paramUsername)async{
  //email phatdinh.work@gmail.com
  var response = await Dio().get(
      'https://instagram-story-and-highlights-saver.p.rapidapi.com/api/stories?username=@$paramUsername',
      // queryParameters: {'url':'$paramUsername'},
      options: Options(
        headers: {
          "content-type": "application/json; charset=UTF-8",
          'x-rapidapi-key': '6ae41ebf1amsh3c53c3c23620f18p1574e8jsn5093714fbf64',
          'x-rapidapi-host': 'instagram-story-and-highlights-saver.p.rapidapi.com',
        },
      ));
  print(response?.data?.toString());
  
  
  //pathernduy@gmail.com
  if ( response?.data == null || response?.data == '') {
    var response = await Dio().get(
        'https://instagram-story-and-highlights-saver.p.rapidapi.com/api/stories?username=@$paramUsername',
        // queryParameters: {'url':'$paramUsername'},
        options: Options(
          headers: {
            "content-type": "application/json; charset=UTF-8",
            'x-rapidapi-key': '74da2f9e9bmshce8d60192c94677p1551e8jsn6262e9e72c06',
            'x-rapidapi-host': 'instagram-story-and-highlights-saver.p.rapidapi.com',
          },
        ));
    print(response?.data?.toString());
    
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
