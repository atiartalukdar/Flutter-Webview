import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ManGoInAppWebView extends StatefulWidget {
  @override
  _ManGoInAppWebViewState createState() => new _ManGoInAppWebViewState();
}

class _ManGoInAppWebViewState extends State<ManGoInAppWebView> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        clearCache: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        clearSessionCache: true,
        cacheMode: AndroidCacheMode.LOAD_NO_CACHE,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: Column(children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search)
                  ),
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  onSubmitted: (value) {
                    var url = Uri.parse(value);
                    if (url.scheme.isEmpty) {
                      url = Uri.parse("https://www.google.com/search?q=" + value);
                    }
                    webViewController?.loadUrl(
                        urlRequest: URLRequest(url: url));
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                        URLRequest(url: Uri.parse("http://192.168.100.175:8081/CmLogin/Login/Login/")),
                        initialOptions: options,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                          controller.addJavaScriptHandler(handlerName: 'AndroidFunctions', callback: (args) {
                            // print arguments coming from the JavaScript side!
                            print(args);
                            if(args.toString() == "[CommonData]"){
                              // return data to the JavaScript side!
                              return {
                                'MacAddress': '1597283465475_mKVFI3ShJd', 'IP': '192.168.7.164'
                              };
                            }
                          });

                          controller.addJavaScriptHandler(handlerName: 'AjaxHandler', callback: (args) {
                            // print arguments coming from the JavaScript side!
                            print(args);

                            switch(args.toString()){
                              case "[AjaxSettingInfo]":
                                return { 'getData': 'AjaxIntervalTime:500,AjaxRetry:20' };

                              case "[isConnectErrorMessage]":
                                return { 'getData': 'false' };

                              case "[getIniUseVpn]":
                                return { 'getData': '0' };
                            }



                          });
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        androidOnPermissionRequest: (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print(consoleMessage);
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        webViewController?.goBack();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        webViewController?.goForward();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.refresh),
                      onPressed: () {
                        webViewController?.reload();
                      },
                    ),
                  ],
                ),
              ]))),
    );

  }


}
