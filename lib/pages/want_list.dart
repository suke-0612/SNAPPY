import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';
import 'package:url_launcher/url_launcher.dart';

class WantList extends StatefulWidget {
  const WantList({super.key});

  @override
  State<WantList> createState() => _WantListState();
}

class _WantListState extends State<WantList> {
  // 定数
  static const String _thingsTag = 'things';
  static const String _amazonBaseUrl = 'https://www.amazon.co.jp/s?k=';

  // 状態管理
  List<ItemData> _thingsItems = [];
  Map<String, Screenshot> _isarScreenshotMap = {};
  Map<String, AssetEntity> _assetEntityMap = {}; // AssetEntityのキャッシュを追加
  bool _loading = true;
  String _searchQuery = '';
  bool _isSelecting = false; // 選択モードかどうか
  Set<String> _selectedItems = {}; // 選択されたアイテムのID

  @override
  void initState() {
    super.initState();
    _loadThingsData();
  }

  Future<void> _loadThingsData() async {
    setState(() {
      _loading = true;
    });

    try {
      final isar = await openIsarInstance();
      final existingScreenshots = await isar.screenshots.where().findAll();

      // スクリーンショットデータをマップに変換
      _isarScreenshotMap = {
        for (var screenshot in existingScreenshots)
          screenshot.assetId: screenshot
      };

      // AssetEntityも取得してキャッシュ
      await _loadAssetEntities(existingScreenshots);

      // "things" タグでフィルタリング
      final thingsScreenshots = existingScreenshots
          .where((screenshot) => screenshot.tag == _thingsTag)
          .toList();

      // ItemDataに変換
      _thingsItems = thingsScreenshots
          .map((screenshot) => _createItemData(screenshot))
          .toList();
    } catch (e) {
      _showError('データ読み込みエラー: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// AssetEntityを取得してキャッシュに保存
  Future<void> _loadAssetEntities(List<Screenshot> screenshots) async {
    try {
      // 写真アルバムから全てのAssetEntityを取得
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup()
          ..addOrderOption(
              OrderOption(type: OrderOptionType.createDate, asc: false)),
      );

      if (albums.isEmpty) return;

      final screenshotAlbum = albums.firstWhere(
        (album) => album.name.toLowerCase().contains("screenshot"),
        orElse: () => albums.first,
      );

      final assets =
          await screenshotAlbum.getAssetListPaged(page: 0, size: 200);

      // AssetEntityをIDでマップ化
      _assetEntityMap = {for (var asset in assets) asset.id: asset};
    } catch (e) {
      debugPrint('AssetEntity読み込みエラー: $e');
    }
  }

  /// スクリーンショットからItemDataを作成
  ItemData _createItemData(Screenshot screenshot) {
    return ItemData(
      id: screenshot.assetId,
      text: screenshot.title ?? 'タイトルなし',
      onTapPopupContent: WantListItemPopup(
        screenshot: screenshot,
        assetEntity: _getAssetEntityFromId(screenshot.assetId),
        onAmazonSearch: () => _openAmazonSearch(screenshot.title!),
        onClose: () => Navigator.of(context).pop(),
        onDelete: () => _deleteFromDatabase(screenshot.assetId),
      ),
      category: '',
      description: '',
    );
  }

  /// AssetIDからAssetEntityを取得するヘルパーメソッド
  AssetEntity? _getAssetEntityFromId(String assetId) {
    return _assetEntityMap[assetId];
  }

  /// エラーメッセージを表示
  void _showError(String message) {
    debugPrint(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// フィルタリングされたアイテムを取得
  List<ItemData> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _thingsItems;
    }

    return _thingsItems.where((item) {
      final screenshot = _isarScreenshotMap[item.id];
      final matchesTitle = (screenshot?.title ?? '')
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesDescription = (screenshot?.description ?? '')
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      return matchesTitle || matchesDescription;
    }).toList();
  }

  /// Amazon検索を開く
  Future<void> _openAmazonSearch(String productName) async {
    final encodedName = Uri.encodeComponent(productName);
    final amazonUrl = '$_amazonBaseUrl$encodedName';

    try {
      final uri = Uri.parse(amazonUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Amazonを開けませんでした');
      }
    } catch (e) {
      _showError('エラー: $e');
    }
  }

  void _showItemDetails(ItemData item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: item.onTapPopupContent,
          ),
        ),
      ),
    );
  }

  /// リストアイテムを構築
  Widget _buildListItem(ItemData item, Screenshot? screenshot) {
    final isSelected = _selectedItems.contains(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2,
      color: isSelected ? Colors.grey.shade300 : Colors.white,
      child: ListTile(
        leading: _isSelecting
            ? Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.black : Colors.grey,
              )
            : null,
        title: Text(
          screenshot?.title ?? 'タイトルなし',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _isSelecting
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  Text(
                    'Amazon',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        onTap: () {
          if (_isSelecting) {
            _toggleItemSelection(item.id);
          } else {
            _showItemDetails(item);
          }
        },
      ),
    );
  }

  /// 空の状態を表示するウィジェットを構築
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? '"$_thingsTag" タグのアイテムがありません'
                : '検索結果が見つかりませんでした',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ホーム画面でスクリーンショットに\n"$_thingsTag"タグを付けてください',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _selectDeleteItems() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedItems.clear(); // 選択モードを終了する時は選択をクリア
      }
    });
  }

  /// アイテムの選択状態を切り替え
  void _toggleItemSelection(String itemId) {
    if (!_isSelecting) return;

    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  /// 選択されたアイテムを削除
  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    try {
      // AssetEntityとassetIdのマップを作成
      Map<AssetEntity, String> itemsToDelete = {};
      List<String> databaseOnlyItems = [];

      for (final itemId in _selectedItems.toList()) {
        final assetEntity = _getAssetEntityFromId(itemId);
        if (assetEntity != null) {
          itemsToDelete[assetEntity] = itemId;
        } else {
          databaseOnlyItems.add(itemId);
        }
      }

      // AssetEntityがあるアイテムは一括削除
      if (itemsToDelete.isNotEmpty) {
        await DeleteItemService.deleteBulkScreenshotsWithAuth(
          context: context,
          items: itemsToDelete,
          onSuccess: () {
            // UI状態の更新
            setState(() {
              for (final itemId in itemsToDelete.values) {
                _isarScreenshotMap.remove(itemId);
                _thingsItems.removeWhere((item) => item.id == itemId);
                _assetEntityMap.remove(itemId);
              }
            });
          },
          onError: (errorMessage) {
            _showError(errorMessage);
          },
        );
      }

      // データベースのみのアイテムは個別削除
      for (final itemId in databaseOnlyItems) {
        await _deleteFromDatabaseOnly(itemId);
      }

      // 選択状態をリセット
      setState(() {
        _selectedItems.clear();
        _isSelecting = false;
      });

      _showSuccessMessage('選択したアイテムを削除しました');
    } catch (e) {
      _showError('削除エラー: $e');
    }
  }

  /// DeleteItemServiceを使用してアイテムを削除
  Future<void> _deleteFromDatabase(String assetId) async {
    try {
      final assetEntity = _getAssetEntityFromId(assetId);

      if (assetEntity != null) {
        // AssetEntityがある場合は DeleteItemService を使用
        await DeleteItemService.deleteScreenshotWithAuth(
          context: context,
          assetEntity: assetEntity,
          assetId: assetId,
          onSuccess: () {
            setState(() {
              _isarScreenshotMap.remove(assetId);
              _thingsItems.removeWhere((item) => item.id == assetId);
              _assetEntityMap.remove(assetId);
            });
          },
          onError: (errorMessage) {
            _showError(errorMessage);
          },
        );
      } else {
        // AssetEntityがない場合はデータベースのみから削除
        await _deleteFromDatabaseOnly(assetId);
      }
    } catch (e) {
      _showError('削除エラー: $e');
    }
  }

  /// データベースのみから削除（AssetEntityがない場合）
  Future<void> _deleteFromDatabaseOnly(String assetId) async {
    try {
      final isar = await openIsarInstance();

      await isar.writeTxn(() async {
        await isar.screenshots.filter().assetIdEqualTo(assetId).deleteAll();
      });

      // ローカル状態も更新
      setState(() {
        _isarScreenshotMap.remove(assetId);
        _thingsItems.removeWhere((item) => item.id == assetId);
        _assetEntityMap.remove(assetId);
      });
    } catch (e) {
      _showError('削除エラー: $e');
    }
  }

  /// 成功メッセージを表示
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          // 検索バー
          Container(
            margin: const EdgeInsets.all(10.0),
            child: InputSearch(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // ヘッダー
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _isSelecting
                    ? SizedBox.shrink()
                    : Icon(Icons.inventory_2, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  _isSelecting
                      ? '選択中 (${_selectedItems.length}/${_filteredItems.length}件)'
                      : '欲しいものリスト (${_filteredItems.length}件)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isSelecting && _selectedItems.isNotEmpty) ...[
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '削除',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: _deleteSelectedItems,
                  ),
                  const SizedBox(width: 8),
                ],
                GestureDetector(
                  child: Icon(_isSelecting ? Icons.close : Icons.delete,
                      color: Colors.black),
                  onTap: _selectDeleteItems,
                ),
              ],
            ),
          ),

          // コンテンツ
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final screenshot = _isarScreenshotMap[item.id];

                          return _buildListItem(item, screenshot);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
