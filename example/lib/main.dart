import 'package:adv_image_cache/adv_image_cache_mgr.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:adv_image_cache/adv_image_cache.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // String platformVersion;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await AdvImageCache.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text("7 days cache expire"),
                      Image(
                          image: AdvImageCache(
                        "https://picsum.photos/100/160",
                        useMemCache: true,
                        fallbackAssetImage: "assets/img_err.png",
                      )),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Text("0 sec cache expire (always refresh)"),
                      Image(
                          image: AdvImageCache(
                        "https://picsum.photos/100/150",
                        useMemCache: false,
                        diskCacheExpire: Duration(seconds: 0),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text("load fail test"),
                      Image(
                          image: AdvImageCache(
                        "https://picsumaaa.photos/100/170",
                        fallbackAssetImage: "assets/img_err.png",
                      )),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Text("1 min cache expire"),
                      Image(
                          image: AdvImageCache(
                        "https://picsum.photos/100/180",
                        useMemCache: true,
                        diskCacheExpire: Duration(minutes: 1),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(onPressed: () => setState(() {}), child: Text("Reload and test cache rules")),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    AdvImageCacheMgr().clearItem("https://picsum.photos/100/160");
                  });
                },
                child: Text("force cache clear for 1st Image")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  AdvImageCacheMgr().clearAllItems();
                });
              },
              child: Text("force cache clear all items"),
            ),
          ],
        ),
      ),
    );
  }
}
