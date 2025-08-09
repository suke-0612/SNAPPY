import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snappy/api.dart';
import 'package:snappy/database/db.dart';
import 'package:snappy/importer.dart';
import 'package:snappy/models/schema.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1; // 最初のページ番号
  int totalPages = 20; // 総ページ数

  //currentPageを引数の値に更新する関数．
  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
  bool _hasAccess = false;
  List<AssetEntity> _screenshots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();

    PhotoManager.addChangeCallback((_) async {
      if (_hasAccess) {
        await _loadAndSaveScreenshots();
      }
    });
    PhotoManager.startChangeNotify();
  }

  @override
  void dispose() {
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  Future<void> _checkPermissionAndLoad() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (ps.hasAccess) {
      setState(() {
        _hasAccess = true;
        _loading = true;
      });
      await _loadAndSaveScreenshots();
      setState(() => _loading = false);
    } else {
      await PhotoManager.openSetting();
      final PermissionState newPs =
          await PhotoManager.requestPermissionExtend();
      if (newPs.hasAccess) {
        setState(() {
          _hasAccess = true;
          _loading = true;
        });
        await _loadAndSaveScreenshots();
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadAndSaveScreenshots() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup()
        ..addOrderOption(
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ),
    );

    final screenshotAlbum = albums.firstWhere(
      (album) => album.name.toLowerCase().contains("screenshot"),
      orElse: () => albums.first,
    );

    final assets = await screenshotAlbum.getAssetListPaged(
      page: 0,
      size: 50,
    );

    final isar = await openIsarInstance();

    // 端末からの画像情報をDBに一旦保存
    final screenshots = assets
        .where((asset) => asset.relativePath != null)
        .map((asset) => Screenshot()
          ..assetId = asset.id
          ..createDate = asset.createDateTime
          ..filePath = asset.relativePath!)
        .toList();

    await isar.writeTxn(() async {
      await isar.screenshots.putAll(screenshots);
    });

    // APIにファイルとタグを送る処理を呼ぶ
    try {
      await uploadFilesWithTags(assets.sublist(0, 5), [
        ['tag1', 'tag1の説明'],
        ['tag2', 'tag2の説明'],
      ]);
    } catch (e) {
      print('API送信失敗: $e');
    }
    setState(() {
      _screenshots = assets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: _hasAccess
                ? _loading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: _screenshots.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<Uint8List?>(
                            future: _screenshots[index].thumbnailDataWithSize(
                              const ThumbnailSize.square(200),
                            ),
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(color: Colors.grey);
                            },
                          );
                        },
                      )
                : Center(
                    child: Text(
                      "スクリーンショットマネージャーは、\n"
                      "アプリの設定から有効にしてください。",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
