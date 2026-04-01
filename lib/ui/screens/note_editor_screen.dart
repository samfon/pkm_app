import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/db_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note note;
  const NoteEditorScreen({Key? key, required this.note}) : super(key: key);

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Nội dung không được để trống!')));
      return;
    }
    ref.read(noteListProvider.notifier).updateNote(widget.note, text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa Ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lịch sử sửa (${widget.note.editHistory.length})',
            onPressed: () {
               showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Lịch sử sửa đổi'),
                  content: SizedBox(
                     width: double.maxFinite,
                     height: 300,
                     child: ListView(
                        children: widget.note.editHistory.map((h) => ListTile(
                           leading: const Icon(Icons.history),
                           title: Text(h),
                        )).toList(),
                     )
                  )
               ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                     hintText: 'Soạn thảo kiến thức của bạn ở đây...',
                     border: InputBorder.none,
                     focusedBorder: InputBorder.none,
                     filled: false,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Container(
                 width: double.infinity,
                 padding: const EdgeInsets.only(top: 16),
                 child: ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
