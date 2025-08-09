import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:snappy/importer.dart';

class ItemCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Uint8List? thumbnailBytes;
  final VoidCallback? onEdit;

  const ItemCard({
    super.key,
    required this.text,
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
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // サムネイルがあれば表示、なければ空のContainer
                if (thumbnailBytes != null)
                  Image.memory(
                    thumbnailBytes!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: Colors.grey),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              left: 24.0,
                              right: 24.0,
                              top: 24.0,
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  24.0,
                            ),
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                                child: EditItemInfoForm(
                                  initialTitle: text,
                                  initialCategory: 'その他',
                                  initialDescription: '既存の説明',
                                  onSubmit: () {
                                    if (onEdit != null) {
                                      onEdit!();
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      tooltip: 'Edit',
                      splashRadius: 20,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
