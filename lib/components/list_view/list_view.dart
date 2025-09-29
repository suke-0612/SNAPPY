import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snappy/importer.dart';

class TitleListView extends StatefulWidget {
  final List<ItemData> items;
  final Set<String> selectedItems;
  final bool isSelectionMode;
  final Function(ItemData) onItemTap;
  final Function(bool) changeSelectMode;
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;

  const TitleListView({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.isSelectionMode,
    required this.onItemTap,
    required this.changeSelectMode,
    this.scrollController,
    required this.onRefresh,
  });

  @override
  State<TitleListView> createState() => _TitleListViewState();
}

class _TitleListViewState extends State<TitleListView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = widget.selectedItems.contains(item.id);

          return GestureDetector(
            onTap: () => widget.onItemTap(item),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[200] : Colors.white,
                borderRadius: BorderRadius.circular(12), // 角丸
                border: Border.all(
                  color: isSelected ? Colors.grey[800]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ], // 軽い影
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSelected
                            ? widget.selectedItems.remove(item.id)
                            : widget.selectedItems.add(item.id);
                        if (widget.selectedItems.isEmpty &&
                            widget.isSelectionMode) {
                          widget.changeSelectMode(false);
                        } else {
                          widget.changeSelectMode(true);
                        }
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 32,
                    icon: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.text ?? 'タイトルなし',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.grey[800] : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 右端のインジケーター（タグがある場合）
                  if (item.category != null && item.category!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFF98E6E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.category!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
