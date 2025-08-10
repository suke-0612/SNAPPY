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
        assetEntity: asset,
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
        await _loadAndSaveScreenshots();
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
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await getAllTags();
    print(tags);
    setState(() {
      for (var tag in tags) {
        if (!customTags.contains(tag.name) && !defaultTags.contains(tag.name)) {
          customTags.add(tag.name);
        }
      }
    });
  }

  /// DBから全スクショ情報を取得してMapに変換し更新
  Future<void> _refreshIsarScreenshotMap() async {
    final isar = await openIsarInstance();
    final all = await isar.screenshots.where().findAll();
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
      await _loadAndSaveScreenshots();
    } else {
      // 権限拒否時のUI案内（リトライは一度だけにするなど検討）
      await PhotoManager.openSetting();
      final newPs = await PhotoManager.requestPermissionExtend();
      if (newPs.hasAccess) {
        setState(() {
          _hasAccess = true;
        });
        await _loadAndSaveScreenshots();
      } else {
        setState(() {
          _hasAccess = false;
          // ここでユーザーに権限拒否の案内をUIに表示するのも良い
        });
      }
    }

    setState(() => _loading = false);
  }

  /// 写真を読み込み、DBに保存し、APIに新規写真のみ送信
  Future<void> _loadAndSaveScreenshots() async {
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
    final isar = await openIsarInstance();

    // まずDBの既存データを読み込む
    final existingScreenshots = await isar.screenshots.where().findAll();
    final existingAssetIds = existingScreenshots.map((e) => e.assetId).toSet();

    // 表示用に、DBにあるassetIdに対応するAssetEntityをassetsから取り出す
    final screenshotsToDisplay =
        assets.where((asset) => existingAssetIds.contains(asset.id)).toList();

    // ここでまずDBの既存データに対応する写真だけ表示
    setState(() {
      _screenshots = screenshotsToDisplay;
      _currentPage = 1;
    });

    // DBにない新規写真だけ抽出
    final newAssetsAll =
        assets.where((asset) => !existingAssetIds.contains(asset.id)).toList();
    final newAssets = newAssetsAll.sublist(0, min(5, newAssetsAll.length));

    if (newAssets.isNotEmpty) {
      print('新しいスクリーンショットが ${newAssets.length} 件あります。');
      try {
        List<List<String>> apiTags = [
          ['location', ''],
          ['things', ''],
          ['others', ''],
        ];
        await getAllTags().then((tags) {
          for (var tag in tags) {
            apiTags.add([tag.name, tag.description]);
          }
        });
        await uploadFilesWithTags(newAssets, apiTags);
      } catch (e) {
        print('API送信失敗: $e');
        return;
      }
    }

    // API成功 or 新規写真なしならDBの最新データを再取得し画面更新
    await _refreshIsarScreenshotMap();

    final allScreenshots = await isar.screenshots.where().findAll();
    final allAssetIds = allScreenshots.map((e) => e.assetId).toSet();

    // assetsからDBにあるものだけ抽出して表示用にセット
    final updatedScreenshots =
        assets.where((asset) => allAssetIds.contains(asset.id)).toList();

    setState(() {
      _screenshots = updatedScreenshots;
      _currentPage = 1;
    });
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

                // ローディングアイコン部分
                if (_loading)
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
              },
            ),
        ],
      ),
    );
  }
}
