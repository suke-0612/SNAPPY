import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class PopupContainer extends StatelessWidget {
  final Uint8List? thumbnailBytes;
  final String? title;
  final String? location;
  final VoidCallback onPressedAddMap;
  final VoidCallback onPressedEdit;
  final VoidCallback onPressedDelete;

  const PopupContainer({
    Key? key,
    this.thumbnailBytes,
    this.title,
    this.location,
    required this.onPressedAddMap,
    required this.onPressedEdit,
    required this.onPressedDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xB2000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          if (thumbnailBytes != null)
            Image.memory(
              thumbnailBytes!,
              width: 360,
              height: 520,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: 360,
              height: 520,
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
          Text(title ?? '情報なし',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          Text(location ?? '情報なし',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: onPressedAddMap,
            label: '地図に追加',
            backgroundColor: Colors.white,
            fontColor: Colors.black,
            size: const Size(360, 60),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                onPressed: onPressedEdit,
                label: '修正',
                icon: Icons.edit,
                iconSize: 24.0,
                backgroundColor: const Color(0xFFF98E6E),
                fontColor: Colors.white,
                size: const Size(175, 60),
              ),
              const SizedBox(width: 10),
              CustomButton(
                onPressed: onPressedDelete,
                label: '削除',
                icon: Icons.delete,
                iconSize: 24.0,
                backgroundColor: const Color(0xFFDE543F),
                fontColor: Colors.white,
                size: const Size(175, 60),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
