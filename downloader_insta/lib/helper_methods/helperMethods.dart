import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../model/InstaPost.dart';
import '../model/InstaStories.dart';


class HelperMethods{
  Future<bool> checkIsPrivate(String username) async{
    // final url = Uri.parse( );
    final response = await Dio().get(
        'https://www.instagram.com/'+username+'/?__a=1&__d=dis'
    );
    print(response?.data?.toString());
    var data = response.data;
    Map items = data['graphql'];
    Map user = items['user'];
    bool is_private = user['is_private'];
    return is_private;
  }

  Future<String> getUserId(String username) async{
    //https://i.instagram.com/api/v1/users/web_profile_info/?username=username
    // final url = Uri.parse( 'https://www.instagram.com/'+username+'/?__a=1&__d=dis');
    final response = await Dio().get(
        'https://www.instagram.com/'+username+'/?__a=1&__d=dis'
    );
    print(response?.data?.toString());
    var data = response.data;
    Map items = data['graphql'];
    Map user = items['user'];
    String id = user['id'];
    return id;
  }

  Future<String> getUsername(String url) async {
    final urlRequest = Uri.parse(url + '/?__a=1&__d=dis');

    // final response = await http.get(
    //   url,
    // );

    final response = await Dio().get(
      url,
    );
    String username = '';

    print(response?.data?.toString());
    var data = response.data;
    if (data
        .toString()
        .contains("Please wait a few minutes before you try again.")) {
      return username;
    } else {
      username = data['user']['username'].toString();
      return username;
    }
  }

  void downloadData(dynamic inputData) async {
    if (inputData.isVideo) {
      // final baseStorage = await getExternalStorageDirectory();
      if ((inputData.id.toString().isEmpty && inputData.shortcode.toString().isEmpty)
          ||(inputData.id.toString().contains("null") && inputData.shortcode.toString().contains("null"))
          ||(inputData.id == null && inputData.shortcode  == null)) {
        // int today = DateTime.now().
        FileDownloader.downloadFile(
            url: inputData.displayUrl!,
            name:
            "com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4",
            onProgress: (String? fileName, double? progress) {
              print('FILE ${DateTime.now().millisecondsSinceEpoch} HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              Fluttertoast.showToast(
                  msg: "Succesfully Downloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onDownloadError: (String error) {
              Fluttertoast.showToast(
                  msg: "Please try it again",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
      } else {
        FileDownloader.downloadFile(
            url: inputData.displayUrl!,
            name:
            "com_helpfulapps_downloader_insta-${inputData.id}_${inputData.shortcode}",
            onProgress: (String? fileName, double? progress) {
              print('FILE ${DateTime.now().millisecondsSinceEpoch} HAS PROGRESS $progress');
            },
            onDownloadCompleted: (String path) {
              Fluttertoast.showToast(
                  msg: "Succesfully Downloaded",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onDownloadError: (String error) {
              Fluttertoast.showToast(
                  msg: "Please try it again",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
      }
    }
    if (inputData.id.toString().isEmpty &&
        inputData.shortcode.toString().isEmpty) {
      //com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.jpg");

      Fluttertoast.showToast(
          msg: "Succesfully Downloaded",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      //com_helpfulapps_downloader_insta-${DateTime.now().millisecondsSinceEpoch}.mp4
      var response = await Dio().get("${inputData.displayUrl}",
          options: Options(responseType: ResponseType.bytes));
      await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: "com_helpfulapps_downloader_insta-${inputData.id}_${inputData.shortcode}.jpg");

      Fluttertoast.showToast(
          msg: "Succesfully Downloaded",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  String convertUrlObjectToString(dynamic paramObject){
    String url = paramObject.displayUrl!.toString();
    return url;
  }

  // Future showListURL(String url, List<dynamic>? listItemAttaching) async {
  //   if(url.contains("/p/")){
  //     listItemAttaching = (await getPostAllData(url)).cast<InstaPost>();
  //   }else if(url.contains("/highlights/")){
  //     listItemAttaching = (await getStoriesAllData(url)).cast<InstaStories>();
  //   }else if(url.contains("/stories/")){
  //     listItemAttaching = (await getStoriesAllData(url)).cast<InstaStories>();
  //   }else if(url.contains("/reel/")){
  //     listItemAttaching = (await getPostAllData(url)).cast<InstaPost>();
  //   }else{
  //     listItemAttaching = null;
  //   }
  //   // showListData = (await getPostAllData(urlPost)).cast<InstaPost>();
  //   _getMoreData();
  // }
}