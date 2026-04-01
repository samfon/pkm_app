import 'package:hive/hive.dart';

class Folder {
  final String id;
  final String name;
  final String? parentId;
  final DateTime lastModified;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentId': parentId,
        'lastModified': lastModified.toIso8601String(),
      };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        id: json['id'],
        name: json['name'],
        parentId: json['parentId'],
        lastModified: DateTime.parse(json['lastModified']),
      );
}

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 0;

  @override
  Folder read(BinaryReader reader) {
    return Folder(
      id: reader.readString(),
      name: reader.readString(),
      parentId: reader.readBool() ? reader.readString() : null,
      lastModified: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeBool(obj.parentId != null);
    if (obj.parentId != null) {
      writer.writeString(obj.parentId!);
    }
    writer.writeInt(obj.lastModified.millisecondsSinceEpoch);
  }
}
