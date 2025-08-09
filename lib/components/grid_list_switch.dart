import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageListGridSwitcher extends StatefulWidget {
  final List<AssetEntity> assets;

  const ImageListGridSwitcher({super.key, required this.assets});

  @override
  State<ImageListGridSwitcher> createState() => _ImageListGridSwitcherState();
}

class _ImageListGridSwitcherState extends State<ImageListGridSwitcher> {
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 切り替えボタン
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(isGrid ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    isGrid = !isGrid;
                  });
                },
                tooltip: isGrid ? 'リスト表示に切り替え' : 'グリッド表示に切り替え',
              ),
            ],
          ),
        ),

        // 画像表示部分
        Expanded(
          child: isGrid
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: widget.assets.length,
                  itemBuilder: (context, index) {
                    return _buildThumbnail(widget.assets[index]);
                  },
                )
              : ListView.builder(
                  itemCount: widget.assets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: FutureBuilder<Uint8List?>(
                        future: widget.assets[index]
                            .thumbnailDataWithSize(const ThumbnailSize(64, 64)),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey,
                          );
                        },
                      ),
                      title: Text(widget.assets[index].title ?? 'No Title'),
                      subtitle:
                          Text(widget.assets[index].createDateTime.toString()),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.grey);
      },
    );
  }
}
