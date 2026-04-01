import 'package:hive_flutter/hive_flutter.dart';
import '../models/folder.dart';
import '../models/note.dart';

class LocalDbService {
  static const String foldersBoxName = 'folders';
  static const String notesBoxName = 'notes';

  Box<Folder>? _foldersBox;
  Box<Note>? _notesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FolderAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteAdapter());
    }

    _foldersBox = await Hive.openBox<Folder>(foldersBoxName);
    _notesBox = await Hive.openBox<Note>(notesBoxName);
  }

  List<Folder> getAllFolders() {
    return _foldersBox?.values.toList() ?? [];
  }

  Future<void> saveFolder(Folder folder) async {
    await _foldersBox?.put(folder.id, folder);
  }

  Future<void> deleteFolder(String folderId) async {
    await _foldersBox?.delete(folderId);
    
    // Xóa Note thuộc về Folder bị xóa
    final notesToDelete = _notesBox?.values.where((n) => n.folderId == folderId).toList() ?? [];
    for (var note in notesToDelete) {
      await _notesBox?.delete(note.id);
    }
    
    // Xóa đệ quy các Folder con
    final subFolders = _foldersBox?.values.where((f) => f.parentId == folderId).toList() ?? [];
    for (var subF in subFolders) {
      await deleteFolder(subF.id); // Recursive delete
    }
  }

  List<Note> getNotesByFolder(String folderId) {
    return _notesBox?.values.where((note) => note.folderId == folderId).toList() ?? [];
  }
  
  List<Note> getAllNotes() {
    return _notesBox?.values.toList() ?? [];
  }

  Future<void> saveNote(Note note) async {
    await _notesBox?.put(note.id, note);
  }

  Future<void> deleteNote(String noteId) async {
    await _notesBox?.delete(noteId);
  }
  
  Future<void> overwriteAll(List<Folder> folders, List<Note> notes) async {
    await _foldersBox?.clear();
    await _notesBox?.clear();
    
    for (var f in folders) {
      await _foldersBox?.put(f.id, f);
    }
    for (var n in notes) {
      await _notesBox?.put(n.id, n);
    }
  }
}
