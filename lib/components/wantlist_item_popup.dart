import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';
import 'dart:typed_data';

/// WantListアイテムのポップアップウィジェット
class WantListItemPopup extends StatefulWidget {
  final Screenshot screenshot;
  final AssetEntity? assetEntity;
  final VoidCallback onAmazonSearch;
  final VoidCallback onClose;

  const WantListItemPopup({
    super.key,
    required this.screenshot,
    this.assetEntity,
    required this.onAmazonSearch,
    required this.onClose,
  });

  @override
  State<WantListItemPopup> createState() => _WantListItemPopupState();
}

class _WantListItemPopupState extends State<WantListItemPopup> {
  Uint8List? _imageBytes;
  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.assetEntity != null) {
      _loadImage();
    }
  }

  /// AssetEntityから画像データを読み込む
  Future<void> _loadImage() async {
    if (widget.assetEntity == null) return;

    setState(() {
      _loadingImage = true;
    });

    try {
      final bytes = await widget.assetEntity!.originBytes;
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _loadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 上部: タイトル
        _buildTitleSection(),
        // 中央: 左に画像、右にボタン
        _buildContentSection(),
      ],
    );
  }

  /// タイトルセクションを構築
  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Text(
        widget.screenshot.title ?? 'タイトルなし',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  /// コンテンツセクション（画像とボタン）を構築
  Widget _buildContentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側: 画像
          if (widget.assetEntity != null)
            _buildImageSection()
          else
            _buildPlaceholderImage(),

          const SizedBox(width: 16),

          // 右側: ボタン
          Expanded(
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  /// 画像セクションを構築（横並び用）
  Widget _buildImageSection() {
    return Container(
      width: 120,
      height: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _loadingImage
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _imageBytes != null
                ? Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
      ),
    );
  }

  /// プレースホルダー画像を構築
  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// アクションボタンを構築（右側用）
  Widget _buildActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.screenshot.title != null &&
            widget.screenshot.title!.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onAmazonSearch,
              icon: const Icon(Icons.shopping_cart, size: 20),
              label: const Text(
                'Amazon',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.onClose,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '閉じる',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
