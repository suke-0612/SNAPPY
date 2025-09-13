import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';
import 'package:url_launcher/url_launcher.dart';

class WantList extends StatefulWidget {
  const WantList({super.key});

  @override
  State<WantList> createState() => _WantListState();
}

class _WantListState extends State<WantList> {
  static const String _thingsTag = 'things';
  static const String _amazonBaseUrl = 'https://www.amazon.co.jp/s?k=';

  List<ItemData> _thingsItems = [];
  Map<String, Screenshot> _isarScreenshotMap = {};
  Map<String, AssetEntity> _assetEntityMap = {};
  bool _loading = true;
  String _searchQuery = '';
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadThingsData();
  }

  Future<void> _loadThingsData() async {
    setState(() => _loading = true);

    try {
      final isar = await openIsarInstance();
      final screenshots = await isar.screenshots.where().findAll();

      _isarScreenshotMap = {for (var s in screenshots) s.assetId: s};
      await _loadAssetEntities(screenshots);

      _thingsItems = screenshots
          .where((s) => s.tag == _thingsTag)
          .map(_createItemData)
          .toList();
    } catch (e) {
      _showError('データ読み込みエラー: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadAssetEntities(List<Screenshot> screenshots) async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup()
          ..addOrderOption(
              const OrderOption(type: OrderOptionType.createDate, asc: false)),
      );
      if (albums.isEmpty) return;

      final album = albums.firstWhere(
        (a) => a.name.toLowerCase().contains("screenshot"),
        orElse: () => albums.first,
      );
      final assets = await album.getAssetListPaged(page: 0, size: 200);
      _assetEntityMap = {for (var asset in assets) asset.id: asset};
    } catch (e) {
      debugPrint('AssetEntity読み込みエラー: $e');
    }
  }

  ItemData _createItemData(Screenshot screenshot) {
    return ItemData(
      id: screenshot.assetId,
      text: screenshot.title ?? 'タイトルなし',
      category: screenshot.tag ?? '',
      description: screenshot.description ?? '',
    );
  }

  AssetEntity? _getAssetEntity(String assetId) => _assetEntityMap[assetId];

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2)),
      );
    }
  }

  List<ItemData> get _filteredItems {
    if (_searchQuery.isEmpty) return _thingsItems;
    return _thingsItems.where((item) {
      final s = _isarScreenshotMap[item.id];
      return (s?.title ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (s?.description ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
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
    final s = _isarScreenshotMap[item.id];
    final asset = _getAssetEntity(item.id);
    if (s == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: WantListItemPopup(
          screenshot: s,
          assetEntity: asset,
          onAmazonSearch: () => _openAmazonSearch(s.title ?? ''),
          onClose: () => Navigator.of(context).pop(),
          onDelete: () async {
            await _deleteItem(item.id);
          },
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  Widget _buildListItem(ItemData item) {
    final isSelected = _selectedItems.contains(item.id);
    final s = _isarScreenshotMap[item.id];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.grey.shade300 : Colors.white,
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _toggleSelection(item.id),
          child: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
        title: Text(
          s?.title ?? 'タイトルなし',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    try {
      final asset = _getAssetEntity(id);

      if (asset != null) {
        await DeleteItemService.deleteScreenshotWithAuth(
          context: context,
          assetEntity: asset,
          assetId: id,
          onSuccess: () {
            setState(() {
              _thingsItems.removeWhere((item) => item.id == id);
              _selectedItems.remove(id);
              _showSuccess('アイテムを削除しました');
            });
          },
          onError: (e) => _showError(e),
        );
      }
    } catch (e) {
      _showError('削除エラー: $e');
      return;
    }
  }

  Future<void> _deleteSelectedItems() async {
    for (var id in _selectedItems.toList()) {
      await _deleteItem(id);
    }
    setState(() {
      _selectedItems.clear();
    });
    _showSuccess('選択したアイテムを削除しました');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
              _searchQuery.isEmpty
                  ? '"$_thingsTag" タグのアイテムがありません'
                  : '検索結果が見つかりませんでした',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center),
          if (_searchQuery.isEmpty) const SizedBox(height: 8),
          if (_searchQuery.isEmpty)
            const Text('ホーム画面でスクリーンショットに\n"things"タグを付けてください',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child:
                InputSearch(onChanged: (v) => setState(() => _searchQuery = v)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.black),
                const SizedBox(width: 8),
                _selectedItems.isNotEmpty
                    ? Text(
                        'マイリスト (${_selectedItems.length}/${_filteredItems.length}件)',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'マイリスト (${_filteredItems.length}件)',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                const Spacer(),
                if (_selectedItems.isNotEmpty)
                  GestureDetector(
                    onTap: _deleteSelectedItems,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16)),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.delete, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text('削除',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (_, i) =>
                            _buildListItem(_filteredItems[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
