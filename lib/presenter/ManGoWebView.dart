import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:weview/main.dart';

import 'components/nagivations_controls.dart';


class ManGoWebView extends StatefulWidget {
  ManGoWebView({key}) : super(key: key);

  @override
  _ManGoWebViewState createState() => _ManGoWebViewState();
}

class _ManGoWebViewState extends State<ManGoWebView> {
  final globalKey = GlobalKey<ScaffoldState>();

  String _title = 'ManGo';

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),
      body: _buildWebView(),
      floatingActionButton: _buldShowUrlBtn(),
    );
  }

  Widget _buildWebView() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: 'https://himdeve.eu',
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
      navigationDelegate: (request) {
        return _buildNavigationDicission(request);
      },
      javascriptChannels: <JavascriptChannel>[
        _createTopBarJsChannel(),
      ].toSet(),
      onPageFinished: (url) {
        _showPageTitle();
      },
    );
  }


  Widget _buildChangeTitleBtn() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _title = "Man.Go!";
        });
      },
      child: Icon(Icons.title),
    );
  }

  Widget _buldShowUrlBtn() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              String? url = await controller.data?.currentUrl();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  '$url',
                  style: TextStyle(fontSize: 20),
                ),
              ));
            },
            child: Icon(Icons.link),
          );
        }
        return Container();
      },
    );
  }

  NavigationDecision _buildNavigationDicission(NavigationRequest request) {
    if (request.url.contains('my-account')) {
      globalKey.currentState?.showSnackBar(SnackBar(
        content: Text(
          'No Permission',
          style: TextStyle(fontSize: 20),
        ),
      ));
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _showPageTitle() {
    _controller.future.then((webViewController) {
      webViewController
          .evaluateJavascript('TopBarJsChannel.postMessage(document.title);');
    });
  }

  JavascriptChannel _createTopBarJsChannel() {
    return JavascriptChannel(
        name: 'TopBarJsChannel',
        onMessageReceived: (message) {
          String newTitle = message.message;

          if (newTitle.contains('-')) {
            newTitle = newTitle.substring(0, newTitle.indexOf('-')).trim();
          }

          setState(() {
            _title = newTitle;
          });
        });
  }

  JavascriptChannel _getMacAddress() {
    return JavascriptChannel(
        name: 'GetMacAddress',
        onMessageReceived: (message) {
          String newTitle = message.message;

          if (newTitle.contains('-')) {
            newTitle = newTitle.substring(0, newTitle.indexOf('-')).trim();
          }

          setState(() {
            _title = newTitle;
          });
        });
  }
}
