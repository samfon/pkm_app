// OTA Update Service - Web-safe base with conditional factory
import 'package:flutter/foundation.dart';

abstract class OtaUpdateServiceBase {
  Future<void> checkForUpdate(Function(String version, String downloadUrl) onUpdateAvailable);
  Future<void> downloadAndInstallUpdate(String url);
}

/// Web (no-op) implementation
class WebOtaUpdateService implements OtaUpdateServiceBase {
  @override
  Future<void> checkForUpdate(Function(String version, String downloadUrl) onUpdateAvailable) async {}

  @override
  Future<void> downloadAndInstallUpdate(String url) async {}
}

/// Factory - returns web stub by default. 
/// On mobile, main.dart registers the mobile implementation via provider override.
OtaUpdateServiceBase createOtaUpdateService() {
  return WebOtaUpdateService();
}
