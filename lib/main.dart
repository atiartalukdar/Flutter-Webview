import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:weview/presenter/ManGoInAppWebView.dart';
import 'package:weview/presenter/components/TestInAppWebView.dart';

void main() async{
  //Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.orange,
  ));

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final double statusBarHeight = MediaQuery.of(context).padding.top;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Man.Go',
      home: ManGoInAppWebView()
    );
  }
}