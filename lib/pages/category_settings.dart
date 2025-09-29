import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class CategorySettings extends StatefulWidget {
  const CategorySettings({super.key});

  @override
  State<CategorySettings> createState() => _CategorySettingsState();
}

class _CategorySettingsState extends State<CategorySettings> {
  Widget _sectionHeader({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _allTags = []; // 親で管理
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await getAllTags();
    setState(() {
      _allTags = tags
          .where(
            (tag) => !['場所', '欲しいもの', 'その他'].contains(tag.name),
          )
          .map((tag) => tag.name)
          .toList();
    });
  }

  Future<void> _refreshCategories() async {
    await _loadTags();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _sectionHeader(
                icon: Icons.add_circle_outline_outlined, title: 'カテゴリの追加'),
            const SizedBox(height: 10),
            AddCategoryForm(onSubmit: _refreshCategories),
            const SizedBox(height: 20),
            _sectionHeader(icon: Icons.remove_circle_outline, title: 'カテゴリの削除'),
            const SizedBox(height: 10),
            DeleteCategory(
              allTags: _allTags,
              selectedTags: _selectedTags,
              onTagsChanged: (newSelected) {
                setState(() {
                  _selectedTags = newSelected;
                });
              },
              onDelete: _refreshCategories,
            ),
          ],
        ),
      ),
    );
  }
}
