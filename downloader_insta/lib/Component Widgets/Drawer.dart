
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screens/DownloadHighlightScreen.dart';
import '../Screens/DownloadReelScreen.dart';
import '../Screens/DownloadStoryScreen.dart';
import '../main.dart';

Widget drawerForScreen(BuildContext context ){
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to ',
                  style: TextStyle(
                    // height: ,
                    // color: Colors.white,
                    // fontSize: 11.,
                  )),
              Text('Downloader Image Video Insta',
                  style: TextStyle(
                    // height: ,
                    // color: Colors.white,
                    // fontSize: 11.,
                  )),
            ],
          ),),
        ),
        // ListTile(
        //   title: const Text('Collection'),
        //   onTap: () => Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => HomePage()),
        //   ),
        // ),
        ListTile(
          title: const Text('Download Posts'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          ),
        ),
        ListTile(
          title: const Text('Download Stories'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DownloadStoryScreen()),
          ),
        ),
        ListTile(
          title: const Text('Download Reel'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DownloadReelScreen()),
          ),
        ),
        ListTile(
          title: const Text('Download Highlights'),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DownloadHighlightScreen()),
          ),
        ),
        //
      ],
    ),
  );
}