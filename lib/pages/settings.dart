import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 8.0)),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'カテゴリの追加',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                AddCategoryForm(),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: const [
                      Icon(Icons.remove, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'カテゴリの削除',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  height: 300, // ここで高さを固定、適宜調整してください
                  child: DeleteCategory(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
