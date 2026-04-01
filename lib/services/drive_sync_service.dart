import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import '../models/folder.dart';
import '../models/note.dart';
import 'local_db_service.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class DriveSyncService {
  final LocalDbService _dbService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveAppdataScope,
  ]);
  
  drive.DriveApi? _driveApi;
  GoogleSignInAccount? currentUser;

  DriveSyncService(this._dbService);

  Future<bool> signIn() async {
    try {
      currentUser = await _googleSignIn.signIn();
      if (currentUser != null) {
        final authHeaders = await currentUser!.authHeaders;
        final authClient = GoogleAuthClient(authHeaders);
        _driveApi = drive.DriveApi(authClient);
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    currentUser = null;
    _driveApi = null;
  }

  Future<String?> _getAppFolderId() async {
    if (_driveApi == null) return null;
    try {
      final fileList = await _driveApi!.files.list(
        q: "name='My_PKM_Data' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
      
      // Tạo thư mục nếu chưa có
      final folder = drive.File()
        ..name = 'My_PKM_Data'
        ..mimeType = 'application/vnd.google-apps.folder';
      final createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      print('Lỗi tìm/tạo thư mục: $e');
      return null;
    }
  }

  Future<drive.File?> _getSyncFile(String folderId) async {
    if (_driveApi == null) return null;
    try {
      final fileList = await _driveApi!.files.list(
        q: "'$folderId' in parents and name='pkm_data.json' and trashed=false",
        spaces: 'drive',
        $fields: 'files(id, name, modifiedTime)',
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first;
      }
    } catch (e) {
      print('Lỗi tìm file sync: $e');
    }
    return null;
  }

  Map<String, dynamic> _exportLocalData() {
    return {
      'last_modified': DateTime.now().toIso8601String(),
      'folders': _dbService.getAllFolders().map((e) => e.toJson()).toList(),
      'notes': _dbService.getAllNotes().map((e) => e.toJson()).toList(),
    };
  }

  Future<void> syncData() async {
    if (_driveApi == null) throw Exception("Chưa đăng nhập");
    final appFolderId = await _getAppFolderId();
    if (appFolderId == null) throw Exception("Không thể tạo/truy cập thư mục My_PKM_Data");

    final syncFile = await _getSyncFile(appFolderId);
    final localData = _exportLocalData();
    final localJson = jsonEncode(localData);

    if (syncFile != null) {
      // 1. Lấy nội dung file trên Cloud để so sánh
      final driveFile = await _driveApi!.files.get(syncFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final bytes = await driveFile.stream.expand((chunk) => chunk).toList();
      final cloudJsonStr = utf8.decode(bytes);
      final cloudData = jsonDecode(cloudJsonStr);

      final cloudModified = DateTime.parse(cloudData['last_modified']);
      final localModified = DateTime.now(); // Thực tế nên lấy record mới nhất trong local DB

      // Nếu Cloud mới hơn -> Tải về ghi đè Local
      // Hiện tại ta đang thiết lập để ưu tiên Local ghi đè nếu user chủ động ấn Sync,
      // Nhưng theo quy chuẩn, hãy backup file cũ đổi tên thành backup
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _driveApi!.files.update(
        drive.File()..name = 'pkm_data_backup_$timestamp.json',
        syncFile.id!,
      );
    }

    // Tạo (hoặc upload) file pkm_data.json mới
    final fileToUpload = drive.File()
      ..name = 'pkm_data.json'
      ..parents = [appFolderId];
    
    final media = drive.Media(
      http.ByteStream.fromBytes(utf8.encode(localJson)),
      utf8.encode(localJson).length,
    );

    await _driveApi!.files.create(fileToUpload, uploadMedia: media);
  }
  
  Future<void> restoreFromDrive() async {
     if (_driveApi == null) throw Exception("Chưa đăng nhập");
      final appFolderId = await _getAppFolderId();
      if (appFolderId == null) throw Exception("Không thể truy cập thư mục My_PKM_Data");
      final syncFile = await _getSyncFile(appFolderId);
      if (syncFile == null) throw Exception("Không tìm thấy dữ liệu trên Cloud để khôi phục");
      
      final driveFile = await _driveApi!.files.get(syncFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final bytes = await driveFile.stream.expand((chunk) => chunk).toList();
      final cloudJsonStr = utf8.decode(bytes);
      final cloudData = jsonDecode(cloudJsonStr);
      
      List<Folder> folders = (cloudData['folders'] as List).map((e) => Folder.fromJson(e)).toList();
      List<Note> notes = (cloudData['notes'] as List).map((e) => Note.fromJson(e)).toList();
      
      await _dbService.overwriteAll(folders, notes);
  }
}
