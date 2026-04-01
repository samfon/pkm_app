import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/db_provider.dart';
import '../../models/folder.dart';
import '../../models/note.dart';
import 'note_editor_screen.dart';

class FolderTreeScreen extends ConsumerStatefulWidget {
  const FolderTreeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FolderTreeScreen> createState() => _FolderTreeScreenState();
}

class _FolderTreeScreenState extends ConsumerState<FolderTreeScreen> {
  // Setup logic đệ quy để build Tree.
  Map<String, bool> expandedFolders = {};

  void _addFolderDialog(BuildContext context, {String? parentId, int currentLevel = 1}) {
    if (currentLevel > 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giới hạn tạo thư mục tối đa là 3 tầng!')));
      return;
    }
    String folderName = '';
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        title: const Text('Thư mục mới'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên thư mục'),
          onChanged: (val) => folderName = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ct), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (folderName.trim().isNotEmpty) {
                ref.read(folderListProvider.notifier).addFolder(folderName.trim(), parentId: parentId);
                Navigator.pop(ct);
              }
            },
            child: const Text('Tạo'),
          )
        ],
      ),
    );
  }

  void _addNoteDialog(BuildContext context, String folderId) {
    String content = '';
    showDialog(
      context: context,
      builder: (ct) => AlertDialog(
        title: const Text('Ghi chú mới'),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Nội dung...'),
          onChanged: (val) => content = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ct), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (content.trim().isNotEmpty) {
                ref.read(noteListProvider.notifier).addNote(folderId, content.trim());
                Navigator.pop(ct);
              }
            },
            child: const Text('Tạo'),
          )
        ],
      ),
    );
  }

  Widget _buildNode(Folder folder, List<Folder> allFolders, List<Note> allNotes, int level) {
    final subFolders = allFolders.where((f) => f.parentId == folder.id).toList();
    final childNotes = allNotes.where((n) => n.folderId == folder.id).toList();
    bool isExpanded = expandedFolders[folder.id] ?? false;

    return Padding(
      padding: EdgeInsets.only(left: (level == 1) ? 0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            leading: Icon(isExpanded ? Icons.folder_open : Icons.folder, color: Colors.blueAccent),
            trailing: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                  IconButton(
                    icon: const Icon(Icons.note_add, size: 20, color: Colors.green),
                    tooltip: 'Tạo Note',
                    onPressed: () => _addNoteDialog(context, folder.id),
                  ),
                  if (level < 3)
                    IconButton(
                      icon: const Icon(Icons.create_new_folder, size: 20, color: Colors.blueGrey),
                      tooltip: 'Tạo Folder con',
                      onPressed: () => _addFolderDialog(context, parentId: folder.id, currentLevel: level + 1),
                    ),
                  IconButton(
                     icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                     tooltip: 'Xóa Folder',
                     onPressed: () {
                         ref.read(folderListProvider.notifier).deleteFolder(folder.id);
                     },
                  )
               ],
            ),
            onTap: () {
              setState(() {
                expandedFolders[folder.id] = !isExpanded;
              });
            },
          ),
          if (isExpanded) ...[
            ...subFolders.map((subF) => _buildNode(subF, allFolders, allNotes, level + 1)),
            ...childNotes.map((note) => Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.grey, size: 20),
                title: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${note.lastModified.day}/${note.lastModified.month}/${note.lastModified.year} ${note.lastModified.hour}:${note.lastModified.minute}'),
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)));
                },
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () {
                       ref.read(noteListProvider.notifier).deleteNote(note.id);
                    },
                ),
              ),
            ))
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(folderListProvider);
    final notes = ref.watch(noteListProvider);
    final rootFolders = folders.where((f) => f.parentId == null).toList();

    return Column(
      children: [
        Padding(
           padding: const EdgeInsets.all(16.0),
           child: ElevatedButton.icon(
              icon: const Icon(Icons.create_new_folder),
              label: const Text('Thêm Thư mục Gốc'),
              onPressed: () => _addFolderDialog(context, parentId: null, currentLevel: 1),
           ),
        ),
        Expanded(
          child: rootFolders.isEmpty 
          ? const Center(child: Text('Trống. Hãy tạo thư mục đầu tiên!'))
          : ListView.builder(
            itemCount: rootFolders.length,
            itemBuilder: (ctx, idx) => _buildNode(rootFolders[idx], folders, notes, 1),
          ),
        ),
      ],
    );
  }
}
