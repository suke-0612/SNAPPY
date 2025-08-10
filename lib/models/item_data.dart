import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';

class ItemData {
  final String id;
  final String text;
  final String category;
  final String description;
  final Widget onTapPopupContent;
  final AssetEntity? assetEntity;

  ItemData({
    required this.id,
    required this.text,
    required this.category,
    required this.description,
    required this.onTapPopupContent,
    this.assetEntity,
  });
}
