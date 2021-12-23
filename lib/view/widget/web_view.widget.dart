import 'dart:developer';

import 'dart:io';

import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:weview/utils/export.util.dart';
import 'package:weview/view/barcode_scanner.dart';

class Webview extends StatelessWidget {
  Webview({Key? key}) : super(key: key);
  final AppController _ctrl = Get.put<AppController>(AppController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* info:: progress bar
        _ctrl.progress < 1.0 ? LinearProgressIndicator(value: _ctrl.progress) : Container(),

        //* info:: webview
        Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.8,
          child: InAppWebView(
            initialData: InAppWebViewInitialData(data: initailData),
            initialUrlRequest: URLRequest(url: Uri.parse(ksIntialUrl)),
            initialOptions: _ctrl.options,
            onWebViewCreated: (InAppWebViewController controller) async {
              // await _ctrl.getInfo(controller);
              controller.evaluateJavascript(source: 'fromFlutter("pop")');
            },
            onLoadStart: (controller, url) async {
              log('message');
              // await _ctrl.getInfo(controller);
              // _ctrl.sendCodeData(controller, '123');
              controller.evaluateJavascript(source: 'fromFlutter("pop")');
            },
            onConsoleMessage: (InAppWebViewController controller, consoleMessage) async {
              controller.evaluateJavascript(source: 'fromFlutter("pop")');
            },
          ),
        ),

        const Divider(height: 2, color: Colors.grey),
        ElevatedButton(
            onPressed: () {
              // Get.to(
              //   () => BarcodeScanner(
              //     appController: _ctrl,
              //   ),
              // );
            },
            child: Text('data')),
        //* info:: camera
      ],
    );
  }
}
