import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'services/local_db_service.dart';
import 'providers/db_provider.dart';
import 'providers/app_providers.dart';
import 'services/ota_update_service.dart';
import 'ui/screens/home_screen.dart';

// Conditional import: uses platform_utils.dart on mobile, web stub on web
import 'services/platform_utils_web.dart'
    if (dart.library.io) 'services/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific services (FlutterDownloader on Android)
  final otaService = await initPlatformServices();

  final dbService = LocalDbService();
  await dbService.init();

  runApp(
    ProviderScope(
      overrides: [
        localDbServiceProvider.overrideWithValue(dbService),
        if (otaService != null)
          otaUpdateServiceProvider.overrideWithValue(otaService),
      ],
      child: const PkmApp(),
    ),
  );
}

class PkmApp extends StatelessWidget {
  const PkmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKM App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
