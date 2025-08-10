import 'package:flutter/material.dart';
import 'package:snappy/app.dart';
import 'package:snappy/components/popup_container.dart';
import 'package:snappy/importer.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final List<String> defaultTags = ["all", "location", "things", "others"];
  List<String> customTags = [];
  List<String> get allTags => [...defaultTags, ...customTags];

  late String selectedTag;

  Map<String, Screenshot> _isarScreenshotMap = {};
  List<AssetEntity> _screenshots = [];

  String _searchQuery = '';
  bool _hasAccess = false;
  bool _loading = true;

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final ScrollController _scrollController = ScrollController();

  // --- ページング用データ ---
  List<ItemData> get _pagedItems {
    final allItems = _itemsFromScreenshots;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (_currentPage * _itemsPerPage).clamp(0, allItems.length);
    return allItems.sublist(start, end);
  }

  List<ItemData> get _itemsFromScreenshots {
    final filtered = _screenshots.where((asset) {
      final dbData = _isarScreenshotMap[asset.id];
      final matchesSearch = _searchQuery.isEmpty ||
          (dbData?.title ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (dbData?.description ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesTag = selectedTag == "all" || (dbData?.tag == selectedTag);
      return matchesSearch && matchesTag;
    }).toList();

    return filtered.map((asset) {
      final dbData = _isarScreenshotMap[asset.id];
      return ItemData(
        id: asset.id,
        text: dbData?.title ?? '',
        category: dbData?.tag ?? 'その他',
        description: dbData?.description ?? 'なし',
        assetEntity: asset,
        onTapPopupContent: Text('Asset ID: ${asset.id}\n'
            'タグ: ${dbData?.tag ?? "なし"}\n'
            'タイトル: ${dbData?.title ?? "なし"}\n'
            '場所: ${dbData?.location ?? "不明"}\n'
            '説明: ${dbData?.description ?? "なし"}\n'),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    selectedTag = allTags.first;
    // 権限チェックと初期データロードを一括で実行
    _checkPermissionAndLoad();
    _loadTags();

    // 写真の変更検知セットアップ
    PhotoManager.addChangeCallback((_) async {
      if (_hasAccess) {
        await _loadAndDisplayAllScreenshotsAndSync();
      }
    });
    PhotoManager.startChangeNotify();
  }

  // RouteAware: 画面が表示された時
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadTags();
  }

  // // RouteAware: 別ページから戻ってきた時
  @override
  void didPopNext() {
    _loadTags();
  }

  @override
  void dispose() {
    PhotoManager.stopChangeNotify();
    PhotoManager.removeChangeCallback((MethodCall call) {});
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await getAllTags();
    // print(tags);
    setState(() {
      for (var tag in tags) {
        if (!customTags.contains(tag.name) && !defaultTags.contains(tag.name)) {
          customTags.add(tag.name);
        }
      }
    });
  }

  Future<void> loadScreenshotsFromDb() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup()
        ..addOrderOption(
            OrderOption(type: OrderOptionType.createDate, asc: false)),
    );

    final screenshotAlbum = albums.firstWhere(
      (album) => album.name.toLowerCase().contains("screenshot"),
      orElse: () => albums.first,
    );

    final assets = await screenshotAlbum.getAssetListPaged(page: 0, size: 50);

    final existingAssetIds = _isarScreenshotMap.keys.toSet();

    final filteredAssets =
        assets.where((asset) => existingAssetIds.contains(asset.id)).toList();

    setState(() {
      _screenshots = filteredAssets;
    });
  }

  /// DBから全スクショ情報を取得してMapに変換し更新
  Future<void> _refreshIsarScreenshotMap() async {
    final isar = await openIsarInstance();
    final all = await isar.screenshots.where().findAll();
    print(all.map((e) => e.title).toList());
    setState(() {
      _isarScreenshotMap = {for (var s in all) s.assetId: s};
    });
  }

  /// 権限チェック＋写真データロードの一連処理
  Future<void> _checkPermissionAndLoad() async {
    setState(() => _loading = true);

    final ps = await PhotoManager.requestPermissionExtend();

    if (ps.hasAccess) {
      setState(() {
        _hasAccess = true;
      });
      await _loadAndDisplayAllScreenshotsAndSync();
    } else {
      // 権限拒否時のUI案内（リトライは一度だけにするなど検討）
      await PhotoManager.openSetting();
      final newPs = await PhotoManager.requestPermissionExtend();
      if (newPs.hasAccess) {
        setState(() {
          _hasAccess = true;
        });
        await _loadAndDisplayAllScreenshotsAndSync();
      } else {
        setState(() {
          _hasAccess = false;
          // ここでユーザーに権限拒否の案内をUIに表示するのも良い
        });
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _loadAndDisplayAllScreenshotsAndSync() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup()
        ..addOrderOption(
            OrderOption(type: OrderOptionType.createDate, asc: false)),
    );

    final screenshotAlbum = albums.firstWhere(
      (album) => album.name.toLowerCase().contains("screenshot"),
      orElse: () => albums.first,
    );

    final allAssets =
        await screenshotAlbum.getAssetListPaged(page: 0, size: 50);

    final isar = await openIsarInstance();

    // DBのスクショ情報を取得してマップにセット
    final existingScreenshots = await isar.screenshots.where().findAll();
    final Map<String, Screenshot> screenshotMap = {
      for (var s in existingScreenshots) s.assetId: s
    };

    // 画面表示用に全端末写真をセット
    setState(() {
      _isarScreenshotMap = screenshotMap; // ここでDBデータを事前にセット
      _screenshots = allAssets;
    });

    // DBにない新規写真を抽出
    final existingAssetIds = screenshotMap.keys.toSet();
    final newAssetsAll = allAssets
        .where((asset) => !existingAssetIds.contains(asset.id))
        .toList();
    final newAssets = newAssetsAll.sublist(0, min(5, newAssetsAll.length));

    if (newAssets.isNotEmpty) {
      print('新しいスクリーンショットが ${newAssets.length} 件あります。');
      try {
        List<List<String>> apiTags = [
          ['location', ''],
          ['things', ''],
          ['others', ''],
        ];
        final tags = await getAllTags();
        for (var tag in tags) {
          apiTags.add([tag.name, tag.description]);
        }

        await uploadFilesWithTags(newAssets, apiTags);

        // API成功後にDBのデータ再取得してマップ更新
        await _refreshIsarScreenshotMap();
      } catch (e) {
        print('API送信失敗: $e');
      }
    }
  }

  Future<void> refreshData() async {
    print('Refreshing data... home');
    await _refreshIsarScreenshotMap();
    await _loadAndDisplayAllScreenshotsAndSync();
    setState(() {});
  }

  void _handleTap(ItemData item) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedIds.contains(item.id)) {
          _selectedIds.remove(item.id);
          if (_selectedIds.isEmpty) _isSelectionMode = false;
        } else {
          _selectedIds.add(item.id);
        }
      });
    } else {
      _showPopup(item);
    }
  }

  void _handleLongPress(ItemData item) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedIds.add(item.id);
      });
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      // AssetEntityのリストからIDに一致するものを除去
      _screenshots.removeWhere((asset) => _selectedIds.contains(asset.id));
      _exitSelectionMode();
    });
    print('削除が実行されました: $_selectedIds');
  }

  void _showPopup(ItemData item) {
    final dbData = _isarScreenshotMap[item.id];
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // 背景を半透明黒にして暗くする
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), // 横の余白で幅調整
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // 最大幅400pxに制限
          child: PopupContainer(
            assetEntity: item.assetEntity!,
            onPressedAddMap: () {
              Navigator.of(context).pop();
              // 地図に追加処理
            },
            onPressedEdit: () {
              Navigator.of(context).pop();
              // 編集処理
            },
            onPressedDelete: () async {
              Navigator.of(context).pop();
              // await _deleteScreenshot(item.id);
            },
            title: dbData?.title,
            location: dbData?.location ?? '',
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPanel() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.black.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              ),
              Text(
                '${_selectedIds.length}個選択中',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteSelectedItems,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_itemsFromScreenshots.length / _itemsPerPage).ceil();

    return BaseScreen(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // 検索バー部分
                InputSearch(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                  },
                ),
                // タグプルダウン
                Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 4.0),
                  alignment: Alignment.centerLeft,
                  child: SelectTagPullButton(
                    tags: allTags,
                    selectedTag: selectedTag,
                    onTagSelected: (tag) {
                      setState(() {
                        selectedTag = tag;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // ローディングアイコン部分
          if (_loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '画像を読み込み中...',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          if (_isSelectionMode) _buildSelectionPanel(),
          Expanded(
            child: _hasAccess
                ? ItemsView(
                    items: _pagedItems,
                    selectedItems: _selectedIds,
                    isSelectionMode: _isSelectionMode,
                    onItemTap: _handleTap,
                    onItemLongPress: _handleLongPress,
                    scrollController: _scrollController,
                    onRefresh: refreshData, // ここで渡す
                  )
                : Center(
                    child: Text(
                      "スクリーンショットマネージャーは、写真へのアクセスが必要です。アプリの設定から有効にしてください。",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
          ),
          if (totalPages > 1)
            Pagination(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    0.0,
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
