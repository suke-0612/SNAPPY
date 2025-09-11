import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:snappy/importer.dart';

class ItemCard extends StatelessWidget {
  final ItemData item;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Uint8List? thumbnailBytes;
  final Future<void> Function()? onEdit;

  const ItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
    this.thumbnailBytes,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // サムネイル
              if (thumbnailBytes != null)
                Image.memory(
                  thumbnailBytes!,
                  fit: BoxFit.cover,
                )
              else
                Container(color: Colors.grey[300]),

              // グラデーションオーバーレイ
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // テキスト
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                  child: Text(
                    item.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 編集ボタン（丸く浮かせる）
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withOpacity(0.85),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black87),
                    onPressed: () async {
                      if (onEdit == null) return;
                      final bool? success = await showEditItemPopup(
                        context,
                        item: item,
                        onRefresh: onEdit!,
                      );
                      if (!context.mounted) return;
                      if (success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('編集内容を保存しました')),
                        );
                      }
                    },
                    tooltip: 'Edit',
                    splashRadius: 20,
                  ),
                ),
              ),

              // 選択状態
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
