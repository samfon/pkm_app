import 'package:hive/hive.dart';

class Note {
  final String id;
  String content;
  String folderId;
  final DateTime createdAt;
  DateTime lastModified;
  List<String> editHistory;

  Note({
    required this.id,
    required this.content,
    required this.folderId,
    required this.createdAt,
    required this.lastModified,
    this.editHistory = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'folderId': folderId,
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'editHistory': editHistory,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        content: json['content'],
        folderId: json['folderId'],
        createdAt: DateTime.parse(json['createdAt']),
        lastModified: DateTime.parse(json['lastModified']),
        editHistory: List<String>.from(json['editHistory'] ?? []),
      );
      
  Note copyWith({
    String? id,
    String? content,
    String? folderId,
    DateTime? createdAt,
    DateTime? lastModified,
    List<String>? editHistory,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      editHistory: editHistory ?? this.editHistory,
    );
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 1;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      content: reader.readString(),
      folderId: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      lastModified: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      editHistory: reader.readList().cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.writeString(obj.folderId);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.lastModified.millisecondsSinceEpoch);
    writer.writeList(obj.editHistory);
  }
}
