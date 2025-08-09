import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snappy/models/schema.dart';

Isar? _isarInstance;

Future<Isar> openIsarInstance() async {
  if (_isarInstance != null && _isarInstance!.isOpen) {
    return _isarInstance!;
  }
  _isarInstance = await Isar.open([ScreenshotSchema],
      directory: (await getApplicationDocumentsDirectory()).path);
  return _isarInstance!;
}
