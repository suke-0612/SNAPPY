import 'package:flutter/material.dart';
import 'dart:typed_data';

class ItemCard extends StatelessWidget {
  final String imagePath;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Uint8List? thumbnailBytes;

  const ItemCard({
    super.key,
    required this.imagePath,
    required this.text,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
    this.thumbnailBytes,
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
                else if (imagePath.isNotEmpty)
                  Image.asset(
                    imagePath,
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
