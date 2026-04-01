import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../providers/db_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKeyController.text = (prefs.getString('gemini_api_key') ?? '');
    _promptController.text = 'Tóm tắt tất cả kiến thức của tôi và nhóm chúng thành các chủ đề ngắn gọn.';
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKeyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu API Key thành công!')));
    ref.read(geminiAiServiceProvider).initModel();
  }

  Future<void> _testAi() async {
    if (_promptController.text.trim().isEmpty) return;
    
    setState(() {
       _isLoading = true;
       _aiResponse = '';
    });
    
    final aiService = ref.read(geminiAiServiceProvider);
    final notes = ref.read(noteListProvider);
    final folders = ref.read(folderListProvider);
    
    final response = await aiService.processNotesWithAi(_promptController.text.trim(), notes, folders);
    
    setState(() {
      _isLoading = false;
      _aiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trung tâm điều khiển AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cấu hình Gemini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'Nhập AIzaSyCoXd...',
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Lưu Cấu Hình AI'),
              onPressed: _saveApiKey,
            ),
            const Divider(height: 60, thickness: 2),
            const Text('Phân tích Kiến trúc (Global Prompt)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Prompt cho AI',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 icon: const Icon(Icons.auto_awesome),
                 label: const Text('Chạy phân tích toàn bộ Box Kiến Thức'),
                 onPressed: _isLoading ? null : _testAi,
               ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
               const Center(child: SpinKitPulse(color: Colors.deepPurple, size: 50.0)),
            if (!_isLoading && _aiResponse.isNotEmpty)
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.shade100)),
                 child: Text(_aiResponse, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
               )
          ],
        ),
      ),
    );
  }
}
