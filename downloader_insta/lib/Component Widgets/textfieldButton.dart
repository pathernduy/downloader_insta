// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../model/InstaPost.dart';
//
// class TextfieldButton extends StatefulWidget {
//   String titleScreenName;
//   bool pressed;
//   TextfieldButton(this.titleScreenName,this.pressed, {Key? key}) : super(key: key);
//
//   @override
//   State<TextfieldButton> createState() => TextfieldButtonState();
// }
//
// class TextfieldButtonState extends State<TextfieldButton> {
//   TextEditingController _urlInputController = TextEditingController();
//   String prefix = "https://www.instagram.com/p/";
//
//   Future showListURL(String urlPost) async {
//     listItemAttaching = (await getPostAllData(urlPost)).cast<InstaPost>();
//     // showListData = (await getPostAllData(urlPost)).cast<InstaPost>();
//     _getMoreData();
//     // if (showListData!.isNotEmpty) {
//     //   lengthItem = showListData?.length;
//     //   for(int i = 0; i< showListData!.length; i++){
//     //     if(i % 4 == 3 && i != 0){
//     //       showListData!.insert(i , new InstaPost());
//     //     }
//     //   }
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.all(10),
//               // labelText: 'Enter username',
//               labelText: 'Enter ${widget.titleScreenName} url',
//             ),
//             controller: _urlInputController,
//           ),
//         ),
//         Expanded(
//           child: ElevatedButton(
//             child: Text("Show Details"),
//             onPressed: () async {
//               await showListURL(_urlInputController.text);
//               Future.delayed(
//                 const Duration(seconds: 1),
//                     () {
//                   setState(() {
//                     if (_urlInputController.text.contains(prefix)) {
//                       widget.pressed = true;
//                     } else {
//                       showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               title: Text(' URL post can\'t be found'),
//                               content: Text(
//                                   'We can\t found your post url. Please wait a few minutes before you try again and make sure you got right url.'),
//                               actions: <Widget>[
//                                 TextButton(
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: Text('ok')),
//                               ],
//                             );
//                           });
//                     }
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//         Expanded(
//           child: ElevatedButton(
//             style:
//             ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             child: Text("Clear"),
//             onPressed: () {
//               setState(() {
//                 _urlInputController.text = '';
//                 widget.pressed = false;
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
