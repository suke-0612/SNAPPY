import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class PopupContainer extends StatefulWidget {
  final AssetEntity assetEntity;
  final String? title;
  final String? location;
  final VoidCallback onPressedAddMap;
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;

  const PopupContainer({
    Key? key,
    required this.assetEntity,
    required this.title,
    this.location,
    required this.onPressedAddMap,
    required this.onPressedEdit,
    required this.onPressedDelete,
  }) : super(key: key);

  @override
  _PopupContainerState createState() => _PopupContainerState();
}

class _PopupContainerState extends State<PopupContainer> {
  Uint8List? thumbnailBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final data =
        await widget.assetEntity.thumbnailDataWithSize(ThumbnailSize(300, 400));
    if (mounted) {
      setState(() {
        thumbnailBytes = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 高さを必要最低限に抑える
            children: [
              if (isLoading)
                SizedBox(
                  width: maxWidth * 0.8,
                  height: maxHeight * 0.5,
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (thumbnailBytes != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth * 0.8,
                    maxHeight: maxHeight * 0.5,
                  ),
                  child: Image.memory(
                    thumbnailBytes!,
                    fit: BoxFit.contain, // はみ出さずに収まる
                  ),
                )
              else
                Container(
                  width: maxWidth * 0.8,
                  height: maxHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                widget.title ?? '情報なし',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.location != null && widget.location!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.location ?? '情報なし',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: widget.onPressedAddMap,
                  label: '地図に追加',
                  backgroundColor: Colors.white,
                  fontColor: Colors.black,
                  size: Size(maxWidth * 0.8, 50),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: widget.onPressedEdit,
                    label: '修正',
                    icon: Icons.edit,
                    iconSize: 24.0,
                    backgroundColor: const Color(0xFFF98E6E),
                    fontColor: Colors.white,
                    size: Size(maxWidth * 0.38, 50),
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    onPressed: widget.onPressedDelete,
                    label: '削除',
                    icon: Icons.delete,
                    iconSize: 24.0,
                    backgroundColor: const Color(0xFFDE543F),
                    fontColor: Colors.white,
                    size: Size(maxWidth * 0.38, 50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
