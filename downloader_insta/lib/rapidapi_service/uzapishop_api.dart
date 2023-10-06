import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:extended_image/extended_image.dart';

import '../model/InstaStories.dart'; // import http package for API calls


// rapidapi for insta post
Future<http.Response> uzapishopPostApiRequest(String paramUsername)async{
  //email phatdinh.work@gmail.com
  final url = Uri.parse(
      'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=$paramUsername'
  );
  final response = await http.get(
    url,
    headers: {
      'x-rapidapi-key': '6ae41ebf1amsh3c53c3c23620f18p1574e8jsn5093714fbf64',
      'x-rapidapi-host': 'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
    },
  );
  //pathernduy@gmail.com
  if(response.body.isEmpty || response.body == null || response.body == ''){
    final url = Uri.parse(
        'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=$paramUsername'
    );
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-key': '74da2f9e9bmshce8d60192c94677p1551e8jsn6262e9e72c06',
        'x-rapidapi-host': 'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
      },
    );

  }
  return response;
}

