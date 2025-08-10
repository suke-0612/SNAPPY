import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class ItemData {
  final String id;
  final String text;
  final AssetEntity? assetEntity;
  final Uint8List? thumbnailBytes;

  ItemData({
    required this.id,
    required this.text,
    this.assetEntity,
    this.thumbnailBytes,
  });
}
