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
      contentType: MediaType('image', 'jpeg'), // 適宜 mime タイプ設定
    );
    request.files.add(multipartFile);
  }

  // tags を JSON 文字列にして fields にセット
  request.fields['tags'] = jsonEncode(tags);

  // リクエスト送信
  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final decoded = jsonDecode(responseBody);
    await saveApiResponseToIsar(decoded);
  } else {
    throw Exception('Failed to upload files');
  }
}

Future<void> saveApiResponseToIsar(dynamic jsonResponse) async {
  print('Saving API response to Isar');
  print('Response: $jsonResponse');
  final isar = await openIsarInstance();

  // jsonResponseがMapの場合、'results'キーからリストを取得
  final List<dynamic> results = jsonResponse['results'] ?? [];

  final screenshots = results.map((item) {
    return Screenshot()
      // APIの返却に合わせてassetId等は取得するかどうか調整してください
      ..assetId = item['assetId'] ?? ''
      ..filePath = item['filePath'] ?? ''
      ..createDate = item.containsKey('createDate')
          ? DateTime.parse(item['createDate'])
          : DateTime.now(); // createDateが無ければ今日時で代用
    // 必要な他のフィールドもここでセット
  }).toList();

  await isar.writeTxn(() async {
    await isar.screenshots.putAll(screenshots);
  });
}
