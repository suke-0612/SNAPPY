import 'package:flutter/material.dart';

class ItemData {
  final String id;
  final String imagePath;
  final String text;
  final Widget onTapPopupContent;

  ItemData({
    required this.id,
    required this.imagePath,
    required this.text,
    required this.onTapPopupContent,
  });
}
