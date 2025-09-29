import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final List<String> _defaultTags = ["all", "場所", "欲しいもの", "その他"];
  final ScrollController _scrollController = ScrollController();

  final List<String> _customTags = [];
  String _selectedTag = "all";

  Map<String, Screenshot> _isarScreenshotMap = {};
  List<AssetEntity> _screenshots = [];

  String _searchQuery = '';
  bool _hasAccess = false;
  bool _loading = true;

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<String> get _allTags => [..._defaultTags, ..._customTags];

  List<ItemData> get _itemsFromScreenshots {
    return _screenshots.where((asset) {
      final dbData = _isarScreenshotMap[asset.id];
      final matchesSearch = _searchQuery.isEmpty ||
          (dbData?.title ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (dbData?.description ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == "all" || dbData?.tag == _selectedTag;
      return matchesSearch && matchesTag;
    }).map((asset) {
      final dbData = _isarScreenshotMap[asset.id];
      return ItemData(
        id: asset.id,
        text: dbData?.title ?? '',
        location: dbData?.location ?? '',
        category: dbData?.tag ?? 'loading',
        description: dbData?.description ?? 'なし',
        assetEntity: asset,
        thumbnailBytes: null,
      );
    }).toList();
  }

  List<ItemData> get _pagedItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = min(_currentPage * _itemsPerPage, _itemsFromScreenshots.length);
    return _itemsFromScreenshots.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadTags();
    await _checkPermissionAndLoad();
    PhotoManager.addChangeCallback((_) async {
      if (_hasAccess) await _loadAndDisplayAllScreenshotsAndSync();
    });
    PhotoManager.startChangeNotify();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadTags();
  }

  @override
  void didPopNext() => {
        Future.delayed(const Duration(milliseconds: 300), () {
          _loadTags();
        })
      };

  @override
  void dispose() {
    PhotoManager.stopChangeNotify();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await getAllTags();
    if (!mounted) return;
    setState(() {
      _customTags.addAll(
        tags.map((t) => t.name).where(
            (n) => !_defaultTags.contains(n) && !_customTags.contains(n)),
      );
    });
  }

  Future<void> _refreshIsarScreenshotMap() async {
    final isar = await openIsarInstance();
    final all = await isar.screenshots.where().findAll();
    if (!mounted) return;
    setState(() {
      _isarScreenshotMap = {for (var s in all) s.assetId: s};
    });
  }

  Future<void> _checkPermissionAndLoad() async {
    setState(() => _loading = true);

    Future<bool> request() async {
      final ps = await PhotoManager.requestPermissionExtend();
      return ps.hasAccess;
    }

    if (await request()) {
      _hasAccess = true;
      await _loadAndDisplayAllScreenshotsAndSync();
    } else {
      await PhotoManager.openSetting();
      if (await request()) {
        _hasAccess = true;
        await _loadAndDisplayAllScreenshotsAndSync();
      } else {
        _hasAccess = false;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadAndDisplayAllScreenshotsAndSync() async {
    // 1. スクリーンショットアルバム取得
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup()
        ..addOrderOption(
          OrderOption(type: OrderOptionType.createDate, asc: false),
        ),
    );

    final screenshotAlbum = albums.firstWhere(
      (album) => album.name.toLowerCase().contains("screenshot"),
      orElse: () => albums.first,
    );

    // 2. ページングで全件取得
    const pageSize = 100;
    List<AssetEntity> allAssets = [];
    int page = 0;
    final totalCount = await screenshotAlbum.assetCountAsync;

    while (allAssets.length < totalCount) {
      final assets =
          await screenshotAlbum.getAssetListPaged(page: page, size: pageSize);
      if (assets.isEmpty) break;
      allAssets.addAll(assets);
      page++;
    }

    // 3. 既存データ取得
    final isar = await openIsarInstance();
    final existingScreenshots = await isar.screenshots.where().findAll();

    final screenshotMap = {for (var s in existingScreenshots) s.assetId: s};
    final existingIds = screenshotMap.keys.toSet();

    if (!mounted) return;
    setState(() {
      _isarScreenshotMap = screenshotMap;
      _screenshots = allAssets;
    });

    // 4. 新規アセットだけを送信
    final newAssets =
        allAssets.where((a) => !existingIds.contains(a.id)).take(5).toList();
    if (newAssets.isEmpty) return;

    try {
      final apiTags = [
        ['場所', ''],
        ['欲しいもの', ''],
        ['その他', ''],
        ...(await getAllTags()).map((t) => [t.name, t.description]),
      ];
      await uploadFilesWithTags(newAssets, apiTags);
      await _refreshIsarScreenshotMap();
    } catch (e) {
      print('API送信失敗: $e');
    }
  }

  Future<void> refreshData() async {
    await _refreshIsarScreenshotMap();
    await _loadAndDisplayAllScreenshotsAndSync();
    if (mounted) setState(() {});
  }

  void _handleTap(ItemData item) {
    if (_isSelectionMode) {
      setState(() {
        _selectedIds.contains(item.id)
            ? _selectedIds.remove(item.id)
            : _selectedIds.add(item.id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
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

  Future<void> _deleteSelectedItems() async {
    final selectedMap = {
      for (var id in _selectedIds)
        _screenshots.firstWhere((a) => a.id == id): id
    };

    await DeleteItemService.deleteBulkScreenshotsWithAuth(
      context: context,
      items: selectedMap,
      onSuccess: () {
        setState(() {
          _screenshots.removeWhere((a) => _selectedIds.contains(a.id));
          _exitSelectionMode();
        });
        _refreshIsarScreenshotMap();
      },
      onError: (e) => print('削除エラー: $e'),
    );
  }

  Future<void> _changeSelectedItemsCategory() async {
    if (_selectedIds.isEmpty) return;

    // all を除いたタグ一覧
    final selectableTags =
        _allTags.where((tag) => tag.toLowerCase() != 'all').toList();

    final selectedTag = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        String? tempSelected;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'カテゴリを選択',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // タグ一覧
                  SizedBox(
                    height: 300,
                    child: ListView.separated(
                      itemCount: selectableTags.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tag = selectableTags[index];
                        final isSelected = tag == tempSelected;

                        return InkWell(
                          onTap: () => setState(() => tempSelected = tag),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.grey.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade300,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  CustomButton(
                    label: '変更する',
                    icon: Icons.check,
                    onPressed: () {
                      if (tempSelected == null) return;
                      Navigator.pop(ctx, tempSelected);
                    },
                    backgroundColor: Colors.black,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );

    if (selectedTag == null) return;

    final isar = await openIsarInstance();

    await isar.writeTxn(() async {
      for (var id in _selectedIds) {
        final screenshot = _isarScreenshotMap[id];
        if (screenshot != null) {
          screenshot.tag = selectedTag;
          await isar.screenshots.put(screenshot);
        }
      }
    });

    await _refreshIsarScreenshotMap();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedIds.length}件のカテゴリを "$selectedTag" に変更しました'),
        ),
      );
      _exitSelectionMode();
    }
  }

  Future<void> _showPopup(ItemData item) async {
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupContainer(
                    item: item,
                    onPressedEdit: () async {
                      final edited = await showEditItemPopup(
                        context,
                        item: item,
                        onRefresh: refreshData,
                      );
                      if (edited == true) Navigator.of(ctx).pop(true);
                    },
                    onPressedDelete: () async {
                      await DeleteItemService.deleteScreenshotWithAuth(
                        context: ctx,
                        assetEntity: item.assetEntity!,
                        assetId: item.id,
                        onSuccess: () => Navigator.of(ctx).pop(),
                        onError: null,
                      );
                    },
                  ),
                ],
              ),

              // 右上に閉じるボタン
              Positioned(
                top: -30,
                right: 30,
                child: Material(
                  color: Colors.white.withOpacity(0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: '閉じる',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('編集内容を保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_itemsFromScreenshots.length / _itemsPerPage).ceil();

    return BaseScreen(
      child: Column(
        children: [
          _buildSearchBar(),
          _buildPageInfo(),
          if (_loading) _buildLoadingIndicator(),
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
                    onRefresh: refreshData,
                  )
                : _buildPermissionWarning(context),
          ),
          if (totalPages > 1)
            Pagination(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _scrollController.jumpTo(0.0);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: InputSearch(
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 1;
                }),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: SelectTagPullButton(
                tags: _allTags,
                selectedTag: _selectedTag,
                shadow: true,
                onTagSelected: (t) => setState(() {
                  _selectedTag = t;
                  _currentPage = 1;
                }),
              ),
            ),
          ],
        ));
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '画像を読み込み中...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(BuildContext context) {
    return Center(
      child: Text(
        "スクリーンショットマネージャーは、写真へのアクセスが必要です。アプリの設定から有効にしてください。",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildPageInfo() {
    final totalItems = _itemsFromScreenshots.length;
    if (totalItems == 0) return const SizedBox.shrink();

    final start = (_currentPage - 1) * _itemsPerPage + 1;
    final end = min(_currentPage * _itemsPerPage, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFF98E6E),
                Color.fromARGB(255, 145, 54, 33)
              ], // 赤→オレンジ
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Show: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '$start–$end',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' of $totalItems',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
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
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              // カテゴリ変更ボタン
              IconButton(
                icon: const Icon(Icons.category, color: Colors.white),
                tooltip: 'カテゴリを変更',
                onPressed: _changeSelectedItemsCategory,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: _deleteSelectedItems,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
