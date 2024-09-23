import 'package:hive/hive.dart';

part "folder.g.dart"; // Untuk menghasilkan adapter

@HiveType(typeId: 0)
class Folder {
  @HiveField(0)
  final String path;

  Folder(this.path);
}
