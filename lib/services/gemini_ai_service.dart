import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/folder.dart';

class GeminiAiService {
  GenerativeModel? _model;
  
  Future<void> initModel() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );
    }
  }

  Future<String> processNotesWithAi(String prompt, List<Note> notes, List<Folder> folders) async {
    if (_model == null) {
      await initModel();
      if (_model == null) {
       return "Lỗi: Chưa cấu hình Gemini API Key trong Settings.";
      }
    }

    // Build context
    StringBuffer contextBuilder = StringBuffer();
    contextBuilder.writeln("Dưới đây là dữ liệu các ghi chú kiến thức của tôi:");
    for (var note in notes) {
      var folderName = folders.firstWhere((f) => f.id == note.folderId, orElse: () => Folder(id: '', name: 'Unknown', lastModified: DateTime.now())).name;
      contextBuilder.writeln("--- Folder: $folderName ---");
      contextBuilder.writeln(note.content);
      contextBuilder.writeln("-------------------------");
    }
    
    contextBuilder.writeln("\nDựa vào dữ liệu trên, hãy trả lời yêu cầu sau: $prompt");

    try {
      final content = [Content.text(contextBuilder.toString())];
      final response = await _model!.generateContent(content);
      return response.text ?? "Không nhận được phản hồi từ AI.";
    } catch (e) {
      return "Lỗi gọi AI: ${e.toString()}";
    }
  }
}
