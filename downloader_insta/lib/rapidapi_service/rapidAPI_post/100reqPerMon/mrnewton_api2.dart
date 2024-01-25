// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:downloader_insta/rapidapi_service/rapidapi_keys/my_rapidapi_keys.dart';
// import 'package:extended_image/extended_image.dart';
//
// import '../../../model/InstaStories.dart'; // import http package for API calls
//
//
// // rapidapi for insta post
// Future<Response> mrnewton2PostApiRequest(String paramLink)async{
//   String parsedData = Uri.encodeComponent(paramLink);
//   var response = null;
//   var params =  {
//     'url': paramLink,
//   };
//   for(var key in rapidAPIKeys.Keys){
//     response = await Dio().post(
//
//       'https://all-media-downloader.p.rapidapi.com/rapid_download/download/',
//       // queryParameters: {'url':'$paramUsername'},
//       options: Options(
//         headers:{
//           "content-type": "application/x-www-form-urlencoded",
//           // "content-type": "application/json; charset=UTF-8",
//           'x-rapidapi-key': key,
//           'x-rapidapi-host': 'all-media-downloader.p.rapidapi.com',
//         },
//       ),
//       // queryParameters: {'url': paramLink},
//       // queryParameters: params,
//       data: jsonEncode({
//         'url': parsedData,
//       }),
//       // data: paramLink,
//     );
//     print(response?.data?.toString());
//     if(response.statusCode == 200 && response.data.toString().isNotEmpty){
//       return response;
//     }
//   }
//   return response;
// }
//
// if (prefixPattern.contains(
// errorException.exceptionFreeApiInsta) &&
// countCallRapidRequest == 1) {
// res = await mrnewton2PostApiRequest(url);
// countCallRapidRequest++;
//
// if (res != errorException.exceptionFreeApiInsta && res != null && res.statusCode == 200) {
// var data = res.data;
// var items = data[0];
// List<dynamic>? carousel_media = items[0]['carousel_media'] ;
//
// for (int i = 0; i < carousel_media!.length; i++) {
// InstaPost instaObject = new InstaPost();
//
// if (carousel_media[i].toString().contains('video_versions')) {
// instaObject._displayUrl =
// "${carousel_media[i]['video_versions']['candidates'][0]['url'].toString()}.mp4";
// instaObject._thumbnail = await VideoThumbnail.thumbnailData(
// video: instaObject._displayUrl!,
// imageFormat: ImageFormat.JPEG,
// maxHeight: 0,
// // maxWidth: ,
// // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
// quality: 100,
// );
// //"${media_with_thumb[i]['thumbnail'].toString()}.mp4";
// instaObject._isVideo = true;
// allDataApi.add(instaObject);
// } else {
// instaObject._displayUrl =
// "${carousel_media[i]['image_versions2']['candidates'][0]['url'].toString()}.jpg";
// allDataApi.add(instaObject);
// }
// }
// } else {
// allDataApi.clear();
// }
// }
