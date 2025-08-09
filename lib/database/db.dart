import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snappy/models/schema.dart';

Future<Isar> openIsarInstance() async {
  final dir = await getApplicationDocumentsDirectory();

  return await Isar.open(
    [ScreenshotSchema], // 生成されたスキーマを指定
    directory: dir.path,
  );
}
