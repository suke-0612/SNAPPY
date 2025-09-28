import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snappy/importer.dart';

class PopupContainer extends StatefulWidget {
  final ItemData item;
  final VoidCallback? onPressedAddMap;
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;

  const PopupContainer({
    super.key,
    required this.item,
    this.onPressedAddMap,
    required this.onPressedEdit,
    required this.onPressedDelete,
  });

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
    // 高解像度の画像を取得して拡大時に綺麗に表示する
    final data = await widget.item.assetEntity?.originBytes;
    if (mounted) {
      setState(() {
        thumbnailBytes = data;
        isLoading = false;
      });
    }
  }

  Future<void> _openMapView(BuildContext context) async {
    if (widget.item.location != null && widget.item.location!.isNotEmpty) {
      Navigator.of(context).pop();

      // 直接Google MapsのURLを開く
      final encodedLocation = Uri.encodeComponent(widget.item.location!);
      final url =
          'https://www.google.com/maps/search/?api=1&query=$encodedLocation';

      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showMessage(context, 'Google Mapsを開けませんでした');
        }
      } catch (e) {
        _showMessage(context, 'エラーが発生しました: $e');
      }
    } else {
      // locationデータがない場合のメッセージ
      _showMessage(context, '位置情報が設定されていません');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth * 0.8,
                  maxHeight: maxHeight * 0.5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container( 
                    color: Colors.grey[900],
                    child: _buildImageViewer(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.item.category.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.item.category,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              Text(
                widget.item.text,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (widget.item.category == "location" &&
                  widget.item.location != null &&
                  widget.item.location!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.item.location!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () => _openMapView(context),
                  label: '地図アプリを開く',
                  icon: Icons.map,
                  iconSize: 20.0,
                  backgroundColor: Colors.white,
                  fontColor: Colors.black87,
                  size: Size(maxWidth * 0.8, 50),
                  borderRadius: 12,
                  elevation: 5,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    onPressed: widget.onPressedEdit,
                    label: '編集',
                    icon: Icons.edit,
                    iconSize: 24.0,
                    backgroundColor: Colors.deepOrange[300]!,
                    fontColor: Colors.white,
                    size: Size(maxWidth * 0.38, 50),
                    borderRadius: 12,
                    elevation: 5,
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    onPressed: widget.onPressedDelete,
                    label: '削除',
                    icon: Icons.delete,
                    iconSize: 24.0,
                    backgroundColor: Colors.red[400]!,
                    fontColor: Colors.white,
                    size: Size(maxWidth * 0.38, 50),
                    borderRadius: 12,
                    elevation: 5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 画像表示部分を構築するヘルパーメソッド
  Widget _buildImageViewer() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (thumbnailBytes != null) {
      return InteractiveViewer(
        panEnabled: true, // ドラッグ移動を有効にする
        minScale: 1.0,    // 最小縮小率
        maxScale: 6.0,    // 最大拡大率
        child: Image.memory(
          thumbnailBytes!,
          // fit: BoxFit.cover, は削除（デフォルトの contain を使用）
        ),
      );
    } else {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 60,
        ),
      );
    }
  }
}