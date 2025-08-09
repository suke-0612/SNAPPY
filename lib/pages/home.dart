import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 既存のフィールドはそのまま
  bool _hasAccess = false;
  List<AssetEntity> _screenshots = [];
  bool _loading = true;

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  // ページネーション追加
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // 現在のページに表示するアイテムを切り出す
  List<ItemData> get _pagedItems {
    final allItems = _itemsFromScreenshots;
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (_currentPage * _itemsPerPage).clamp(0, allItems.length);
    return allItems.sublist(start, end);
  }

  // AssetEntity を ItemsView 用の ItemData に変換
  List<ItemData> get _itemsFromScreenshots {
    return _screenshots.map((asset) {
      return ItemData(
        id: asset.id,
        imagePath: '', // AssetEntityから画像取得するので空文字でOK
        text: asset.relativePath ?? 'No Path',
        onTapPopupContent:
            Text('Asset ID: ${asset.id}\nパス: ${asset.relativePath ?? "不明"}'),
        assetEntity: asset, // これを追加した ItemData クラスを使う想定
      );
    }).toList();
  }

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

    final assets = await screenshotAlbum.getAssetListPaged(page: 0, size: 50);

    final isar = await openIsarInstance();

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
      // TODO: 後で復活
      // await uploadFilesWithTags(assets.sublist(0, 5), [
      //   ['tag1', 'tag1の説明'],
      //   ['tag2', 'tag2の説明'],
      // ]);
    } catch (e) {
      print('API送信失敗: $e');
    }

    setState(() {
      _screenshots = assets;
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
      _showPopup(item.onTapPopupContent);
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

  void _showPopup(Widget content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
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
          if (_isSelectionMode) _buildSelectionPanel(),
          Expanded(
            child: _hasAccess
                ? _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ItemsView(
                        items: _pagedItems,
                        selectedItems: _selectedIds,
                        isSelectionMode: _isSelectionMode,
                        onItemTap: _handleTap,
                        onItemLongPress: _handleLongPress,
                      )
                : Center(
                    child: Text(
                      "スクリーンショットマネージャーは、\nアプリの設定から有効にしてください。",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
          ),

          // ここにページネーションを追加
          if (!_loading && totalPages > 1)
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
