import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snappy/importer.dart';

class PopupContainer extends StatefulWidget {
  final AssetEntity assetEntity;
  final String? title;
  final String? location;
  final VoidCallback? onPressedAddMap; // オプショナルに変更
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;

  const PopupContainer({
    Key? key,
    required this.assetEntity,
    required this.title,
    this.location,
    this.onPressedAddMap, // オプショナルに変更
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

  Future<void> _openMapView(BuildContext context) async {
    // デバッグ用：locationデータを確認
    print('Location data: ${widget.location}');

    if (widget.location != null && widget.location!.isNotEmpty) {
      Navigator.of(context).pop(); // 現在のポップアップを閉じる

      // 直接Google MapsのURLを開く
      final encodedLocation = Uri.encodeComponent(widget.location!);
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
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              // 位置情報の表示と地図ボタン
              if (widget.location != null && widget.location!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.location!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () => _openMapView(context),
                  label: '地図を開く',
                  icon: Icons.map,
                  iconSize: 20.0,
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
                    label: '編集',
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
