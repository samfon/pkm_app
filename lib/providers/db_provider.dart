import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_db_service.dart';
import '../models/folder.dart';
import '../models/note.dart';
import 'package:uuid/uuid.dart';

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  throw UnimplementedError('dbService chưa được khởi tạo');
});

final folderListProvider = StateNotifierProvider<FolderListNotifier, List<Folder>>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return FolderListNotifier(dbService);
});

class FolderListNotifier extends StateNotifier<List<Folder>> {
  final LocalDbService _dbService;

  FolderListNotifier(this._dbService) : super([]) {
    loadFolders();
  }

  void loadFolders() {
    state = _dbService.getAllFolders();
  }

  Future<void> addFolder(String name, {String? parentId}) async {
    final folder = Folder(
      id: const Uuid().v4(),
      name: name,
      parentId: parentId,
      lastModified: DateTime.now(),
    );
    await _dbService.saveFolder(folder);
    loadFolders();
  }

  Future<void> updateFolder(Folder folder) async {
    final updated = Folder(
      id: folder.id,
      name: folder.name,
      parentId: folder.parentId,
      lastModified: DateTime.now(),
    );
    await _dbService.saveFolder(updated);
    loadFolders();
  }

  Future<void> deleteFolder(String id) async {
    await _dbService.deleteFolder(id);
    loadFolders();
  }
}

final noteListProvider = StateNotifierProvider<NoteListNotifier, List<Note>>((ref) {
  final dbService = ref.watch(localDbServiceProvider);
  return NoteListNotifier(dbService);
});

class NoteListNotifier extends StateNotifier<List<Note>> {
  final LocalDbService _dbService;

  NoteListNotifier(this._dbService) : super([]) {
    loadNotes();
  }

  void loadNotes() {
    state = _dbService.getAllNotes();
  }

  Future<void> addNote(String folderId, String content) async {
    final note = Note(
      id: const Uuid().v4(),
      content: content,
      folderId: folderId,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    await _dbService.saveNote(note);
    loadNotes();
  }

  Future<void> updateNote(Note note, String newContent) async {
    if (note.content == newContent) return;
    
    List<String> newHistory = List.from(note.editHistory);
    newHistory.add(note.content); // Save old content to history
    
    final updated = note.copyWith(
      content: newContent,
      lastModified: DateTime.now(),
      editHistory: newHistory,
    );
    
    await _dbService.saveNote(updated);
    loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _dbService.deleteNote(id);
    loadNotes();
  }
}
