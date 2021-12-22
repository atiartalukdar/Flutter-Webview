import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:location/location.dart';
import 'package:weview/utils/export.util.dart';

class AppController {
  double progress = 0;
  late StreamSubscription subscription;
  late bool isConnected;
  late String platformVersion;
  late LocationData locationData;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
  );

  Future<void> getInfo(InAppWebViewController controller) async {
    controller.addJavaScriptHandler(
      handlerName: 'AjaxHandler',
      callback: (args) async {
        // log('arags: ' + args.toString());
        String _args = args[0].toString();
        if (_args == 'ip') {
          String ip = await getIP();
          log('IP Address: ' + ip);
          return {'getData': ip};
        } else if (_args == 'location') {
          try {
            var res = await getLocation();
            log('location: ' + res.toString());
            return {'getData': 'Location: ${getLocation()}'};
          } catch (e) {
            log(e.toString());
          }
        } else if (_args == 'connection') {
          log('Connection: ' + isConnected.toString());
          return {'getData': isConnected.toString()};
        } else if (_args == 'mac') {
          log('MAC Address: ' 'Mac Address: 00:0a:95:9d:68:16');
          return {'getData': 'Mac Address: 00:0a:95:9d:68:16'};
        }
      },
    );
  }

  Future<String> getIP() async {
    String _ip = '';
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        _ip = '${addr.address} ${addr.host}';
      }
    }
    return _ip;
  }

  Future<void> isConnectedToInternet(result) async {
    if (result.toString() == 'ConnectivityResult.mobile' || result.toString() == 'ConnectivityResult.wifi') {
      isConnected = true;
    } else {
      isConnected = false;
    }
    // log(isConnected.toString());
  }

  Future<dynamic> getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        log('location service not enabled');
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        log('location permission denied');
        return;
      }
    }

    try {
      locationData = await location.getLocation();
    } catch (e) {
      log(e.toString());
    }

    return {'latitude': locationData.latitude, 'longitude': locationData.longitude};
    // locationData.toString();
  }
}
