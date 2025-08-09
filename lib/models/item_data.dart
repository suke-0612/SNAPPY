import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';

class ItemData {
  final String id;
  final String imagePath;
  final String text;
  final Widget onTapPopupContent;
  final AssetEntity? assetEntity;

  ItemData({
    required this.id,
    required this.imagePath,
    required this.text,
    required this.onTapPopupContent,
    this.assetEntity,
  });
}
