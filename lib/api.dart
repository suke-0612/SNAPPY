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
  var uri = Uri.parse('http://172.26.62.30:8080/ocr/upload-and-classify-batch');
  var request = http.MultipartRequest('POST', uri);

  // ファイルをMultipartFileに変換して追加
  for (var asset in assets) {
    final file = await asset.file;
    if (file == null) continue;
    final multipartFile = await http.MultipartFile.fromPath(
      'files', // API側のフィールド名
      file.path,
      contentType: MediaType('image', 'jpeg'), // 適宜 mime タイプ設定
    );
    request.files.add(multipartFile);
  }

  // tags を JSON 文字列にして fields にセット
  // request.fields['tags'] = jsonEncode(tags);

  // リクエスト送信
  final response = await request.send();

  print('API Response: ${response}');

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    // JSONパースしてDBに保存など処理
    final decoded = jsonDecode(responseBody);
    await saveApiResponseToIsar(decoded);
  } else {
    throw Exception('Failed to upload files');
  }
}

Future<void> saveApiResponseToIsar(dynamic jsonResponse) async {
  final isar = await openIsarInstance();

  // 例: jsonResponseがリストなら
  final screenshots = (jsonResponse as List).map((item) {
    return Screenshot()
      ..assetId = item['assetId']
      ..filePath = item['filePath']
      ..createDate = DateTime.parse(item['createDate']);
    // 他のフィールドもあればセット
  }).toList();

  await isar.writeTxn(() async {
    await isar.screenshots.putAll(screenshots);
  });
}
