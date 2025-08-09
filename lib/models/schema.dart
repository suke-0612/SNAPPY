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

  get someTextField => null;
}
