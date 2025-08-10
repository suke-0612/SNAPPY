import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snappy/database/db.dart';
import 'package:snappy/models/schema.dart';

Future<void> uploadFilesWithTags(
    List<AssetEntity> assets, List<List<String>> tags) async {
  print(
      'Uploading files with tags: ${assets.length} assets, ${tags.length} tags');
  var uri = Uri.parse(
      'https://snappy-backend-7yyq.onrender.com/ocr/upload-and-classify-test');
  var request = http.MultipartRequest('POST', uri);

  // ファイルをMultipartFileに変換して追加
  for (var asset in assets) {
    final file = await asset.file;
    if (file == null) continue;
    final multipartFile = await http.MultipartFile.fromPath(
      'files', // API側のフィールド名
      file.path,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
  }

  // tags を JSON 文字列にして fields にセット
  // request.fields['tags'] = jsonEncode(tags);

  // リクエスト送信
  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final decoded = jsonDecode(responseBody);
    await saveApiResponseToIsar(decoded, assets);
    // print(decoded);
  } else {
    throw Exception('Failed to upload files');
  }
}

Future<void> saveApiResponseToIsar(
    dynamic jsonResponse, List<AssetEntity> assets) async {
  if (jsonResponse is! Map || jsonResponse['results'] == null) {
    return;
  }

  final List<dynamic> results = jsonResponse['results'];
  final isar = await openIsarInstance();

  // assets.length と results.length が同じ前提でマッピング
  final screenshots = <Screenshot>[];
  for (int i = 0; i < results.length && i < assets.length; i++) {
    final asset = assets[i];
    final item = results[i];

    if (item['status.success'] == true) {
      screenshots.add(
        Screenshot()
          ..assetId = asset.id
          ..tag = item['tag'] ?? ''
          ..title = item['title'] ?? ''
          ..location = item['location'] ?? ''
          ..description = item['description'] ?? '',
      );
    }
  }

  await isar.writeTxn(() async {
    await isar.screenshots.putAll(screenshots);
  });

  print('Saved ${screenshots.length} records to Isar');
}
