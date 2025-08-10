import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';
import 'dart:typed_data';

class ItemsView extends StatefulWidget {
  final List<ItemData> items;
  final Set<String> selectedItems;
  final bool isSelectionMode;
  final Function(ItemData) onItemTap;
  final Function(ItemData) onItemLongPress;
  final Future<void> Function() onRefresh;

  const ItemsView({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.isSelectionMode,
    required this.onItemTap,
    required this.onItemLongPress,
    required this.onRefresh,
  });

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final Map<String, Uint8List?> _thumbnailCache = {};

  Future<void> _loadThumbnail(String id, AssetEntity asset) async {
    if (_thumbnailCache.containsKey(id)) return; // 既に読み込み済みなら何もしない
    final data =
        await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (mounted) {
      setState(() {
        _thumbnailCache[id] = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = widget.selectedItems.contains(item.id);

        if (item.assetEntity != null) {
          // サムネイルがまだキャッシュされてなければロード
          if (!_thumbnailCache.containsKey(item.id)) {
            _loadThumbnail(item.id, item.assetEntity!);
          }

          return ItemCard(
            key: ValueKey(item.id),
            item: item,
            isSelected: isSelected,
            onTap: () => widget.onItemTap(item),
            onLongPress: () => widget.onItemLongPress(item),
            thumbnailBytes: _thumbnailCache[item.id],
            onEdit: widget.onRefresh,
          );
        } else {
          return ItemCard(
            key: ValueKey(item.id),
            item: item,
            isSelected: isSelected,
            onTap: () => widget.onItemTap(item),
            onLongPress: () => widget.onItemLongPress(item),
          );
        }
      },
    );
  }
}
