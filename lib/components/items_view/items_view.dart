import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class ItemsView extends StatelessWidget {
  final List<ItemData> items;
  final Set<String> selectedItems;
  final bool isSelectionMode;
  final Function(ItemData) onItemTap;
  final Function(ItemData) onItemLongPress;

  const ItemsView({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.isSelectionMode,
    required this.onItemTap,
    required this.onItemLongPress,
  });

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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.contains(item.id);

        return ItemCard(
          key: ValueKey(item.id),
          imagePath: item.imagePath,
          text: item.text,
          isSelected: isSelected,
          onTap: () => onItemTap(item),
          onLongPress: () => onItemLongPress(item),
        );
      },
    );
  }
}
