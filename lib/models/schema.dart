import 'package:isar/isar.dart';

part 'schema.g.dart';

@collection
class Screenshot {
  Id id = Isar.autoIncrement; // Isar内部ID
  late String assetId; // AssetEntity.id と対応
  String? tag;
  String? title;
  String? location;
  String? description;
}

@Collection()
class Tag {
  Id id = Isar.autoIncrement;

  late String name; // 例: "tag1"
  late String description; // 例: "hogho"
}
