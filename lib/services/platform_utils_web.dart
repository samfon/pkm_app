// Platform utilities - Web stub (no dart:io available on web)
import 'ota_update_service.dart';

Future<OtaUpdateServiceBase?> initPlatformServices() async {
  // No-op on web, return null (use default web stub)
  return null;
}

bool get isAndroidPlatform => false;
