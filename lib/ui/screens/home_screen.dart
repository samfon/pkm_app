import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../providers/db_provider.dart';
import '../../providers/app_providers.dart';
import 'folder_tree_screen.dart';
import 'settings_screen.dart';

// Conditional import for platform check
import '../../services/platform_utils_web.dart'
    if (dart.library.io) '../../services/platform_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isAndroidPlatform) {
         ref.read(otaUpdateServiceProvider).checkForUpdate((version, url) {
             _showUpdateDialog(version, url);
         });
      }
    });
  }

  void _showUpdateDialog(String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Có bản cập nhật mới!'),
        content: Text('Bản cập nhật $version đã sẵn sàng. Bạn có muốn tải và cài đặt ngay?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bỏ qua')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải xuống... Vui lòng đợi')),
              );
              ref.read(otaUpdateServiceProvider).downloadAndInstallUpdate(url);
            },
            child: const Text('Cập nhật'),
          )
        ],
      ),
    );
  }

  void _syncToDrive() async {
    ref.read(syncLoadingProvider.notifier).setSyncing(true);
    try {
      final syncService = ref.read(driveSyncServiceProvider);
      bool isLogged = await syncService.signIn();
      if (isLogged) {
        await syncService.syncData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đồng bộ lên Drive thành công!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng nhập Google thất bại!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đồng bộ: $e')));
      }
    } finally {
      ref.read(syncLoadingProvider.notifier).setSyncing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteList = ref.watch(noteListProvider);
    final isSyncing = ref.watch(syncLoadingProvider);
    
    DateTime? lastUpdate;
    if (noteList.isNotEmpty) {
      lastUpdate = noteList.map((n) => n.lastModified).reduce((a, b) => a.isAfter(b) ? a : b);
    }

    int daysDiff = lastUpdate != null ? DateTime.now().difference(lastUpdate).inDays : 0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PKM App', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isSyncing) 
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
          if (!isSyncing)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Đồng bộ lên Drive',
              onPressed: _syncToDrive,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Trung tâm AI',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
             _buildGreetingHeader(lastUpdate, daysDiff),
             Expanded(
               child: ScreenTypeLayout.builder(
                 mobile: (context) => const FolderTreeScreen(),
                 tablet: (context) => const FolderTreeScreen(),
                 desktop: (context) => _buildDesktopLayout(),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(DateTime? lastUpdate, int daysDiff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hôm nay bạn muốn update kiến thức gì?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            lastUpdate == null ? "Chưa có dữ liệu nào." : "Lần update gần nhất: ${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          if (lastUpdate != null && daysDiff > 0)
            Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Text(
                "Đã $daysDiff ngày chưa update!",
                style: const TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const SizedBox(
          width: 350,
          child: FolderTreeScreen(),
        ),
        VerticalDivider(width: 1, color: Colors.grey.shade300),
        Expanded(
          child: Center(
            child: Text('Chọn một Note để xem hoặc Edit', style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
          ),
        )
      ],
    );
  }
}
