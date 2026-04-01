// OTA Update Service - Android/Mobile implementation
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ota_update_service.dart';

class MobileOtaUpdateService implements OtaUpdateServiceBase {
  static const String repoOwner = "samfon"; // Cần cấu hình
  static const String repoName = "pkm_app";

  @override
  Future<void> checkForUpdate(Function(String version, String downloadUrl) onUpdateAvailable) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest'));
      
      if (response.statusCode == 200) {
        final releaseData = jsonDecode(response.body);
        final latestVersion = (releaseData['tag_name'] as String).replaceAll('v', '');
        
        if (latestVersion != currentVersion) {
          final assets = releaseData['assets'] as List;
          if (assets.isNotEmpty) {
            final apkAsset = assets.firstWhere(
              (a) => (a['name'] as String).endsWith('.apk'),
              orElse: () => null,
            );
            if (apkAsset != null) {
              String downloadUrl = apkAsset['browser_download_url'];
              onUpdateAvailable(latestVersion, downloadUrl);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Check update failed: $e");
    }
  }

  @override
  Future<void> downloadAndInstallUpdate(String url) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;
      final savePath = dir.path;
      final fileName = "pkm_app_update.apk";
      final file = File('$savePath/$fileName');
      if (file.existsSync()) {
        file.deleteSync();
      }

      final dio = Dio();
      await dio.download(url, '$savePath/$fileName', onReceiveProgress: (rec, total) {
         // UI Update here if needed
      });
      
      OpenFile.open('$savePath/$fileName');
    } catch (e) {
      debugPrint("Download error: $e");
    }
  }
}

/// Factory override for mobile platforms
OtaUpdateServiceBase createMobileOtaUpdateService() {
  return MobileOtaUpdateService();
}
