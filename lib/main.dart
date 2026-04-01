import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'core/theme/app_theme.dart';
import 'services/local_db_service.dart';
import 'providers/db_provider.dart';
import 'ui/screens/home_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && Platform.isAndroid) {
     await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
  }

  final dbService = LocalDbService();
  await dbService.init();

  runApp(
    ProviderScope(
      overrides: [
        localDbServiceProvider.overrideWithValue(dbService),
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
