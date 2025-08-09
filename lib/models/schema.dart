import 'package:isar/isar.dart';

part 'schema.g.dart';

@Collection()
class Screenshot {
  Id id = Isar.autoIncrement;
  late String assetId;
  late String filePath;

  set createDate(DateTime createDate) {}
}
