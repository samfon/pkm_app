// Platform utilities - Mobile/Desktop (dart:io available)
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'ota_update_service.dart';
import 'ota_update_service_mobile.dart';

Future<OtaUpdateServiceBase?> initPlatformServices() async {
  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
    return MobileOtaUpdateService();
  }
  return null;
}

bool get isAndroidPlatform => Platform.isAndroid;
