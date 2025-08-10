import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snappy/models/schema.dart';

Isar? _isarInstance;

Future<Isar> openIsarInstance() async {
  if (_isarInstance != null && _isarInstance!.isOpen) {
    return _isarInstance!;
  }
  _isarInstance = await Isar.open([ScreenshotSchema, TagSchema],
      directory: (await getApplicationDocumentsDirectory()).path);
  return _isarInstance!;
}

Future<void> saveTags(List<List<String>> tags) async {
  final isar = await openIsarInstance();
  await isar.writeTxn(() async {
    for (final pair in tags) {
      final name = pair.isNotEmpty ? pair[0] : '';
      final desc = pair.length > 1 ? pair[1] : '';
      if (name.isEmpty) continue;

      final existingTag =
          await isar.tags.filter().nameEqualTo(name).findFirst();
      if (existingTag == null) {
        final newTag = Tag()
          ..name = name
          ..description = desc;
        await isar.tags.put(newTag);
      }
    }
  });
}

Future<void> deleteTags(List<String> names) async {
  final isar = await openIsarInstance();

  await isar.writeTxn(() async {
    for (final name in names) {
      // Tagコレクションから削除
      final tagToDelete =
          await isar.tags.filter().nameEqualTo(name).findFirst();
      if (tagToDelete != null) {
        await isar.tags.delete(tagToDelete.id);
      }

      // Screenshotのtagが一致しているものは空文字に更新
      final screenshots =
          await isar.screenshots.filter().tagEqualTo(name).findAll();
      for (final ss in screenshots) {
        ss.tag = '';
        await isar.screenshots.put(ss);
      }
    }

    //TODO: タグがなくなったものはAPIに渡して再登録される様にする
  });
}

Future<List<Tag>> getAllTags() async {
  final isar = await openIsarInstance();
  return await isar.tags.where().findAll();
}
