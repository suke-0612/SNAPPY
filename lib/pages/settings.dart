import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'カテゴリの追加',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  AddCategoryForm(),
                  Text(
                    'カテゴリの削除',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(child: DeleteCategory())
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
