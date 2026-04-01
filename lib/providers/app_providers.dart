import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/drive_sync_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/ota_update_service.dart';
import 'db_provider.dart';

// Services Providers
final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  final dbService = ref.read(localDbServiceProvider);
  return DriveSyncService(dbService);
});

final geminiAiServiceProvider = Provider<GeminiAiService>((ref) {
  return GeminiAiService();
});

final otaUpdateServiceProvider = Provider<OtaUpdateService>((ref) {
  return OtaUpdateService();
});

// Sync State Notifier provider
class SyncStateNotifier extends StateNotifier<bool> {
  SyncStateNotifier() : super(false);
  
  void setSyncing(bool value) {
    state = value;
  }
}

final syncLoadingProvider = StateNotifierProvider<SyncStateNotifier, bool>((ref) {
  return SyncStateNotifier();
});
