import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class EditItemInfoForm extends StatefulWidget {
  final ItemData item;
  final Future<void> Function() onRefresh;

  const EditItemInfoForm({
    super.key,
    required this.item,
    required this.onRefresh,
  });

  @override
  State<EditItemInfoForm> createState() => _EditItemInfoFormState();
}

class _EditItemInfoFormState extends State<EditItemInfoForm> {
  List<String> _categoryOptions = [];
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.item.text);
    _categoryController = TextEditingController(text: widget.item.category);
    _selectedCategory = widget.item.category;
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _locationController = TextEditingController(text: widget.item.location);

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final tags = await getAllTags();
    final names = tags.map((t) => t.name).toList();

    setState(() {
      _categoryOptions = names.isNotEmpty
          ? names + ['場所', '欲しいもの', 'その他']
          : ['場所', '欲しいもの', 'その他'];

      if (!_categoryOptions.contains(_selectedCategory)) {
        _selectedCategory = _categoryOptions.first;
        _categoryController.text = _selectedCategory;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final isar = await openIsarInstance();

      await isar.writeTxn(() async {
        final screenshot = await isar.screenshots
            .filter()
            .assetIdEqualTo(widget.item.id)
            .findFirst();

        if (screenshot != null) {
          screenshot.title = _titleController.text;
          screenshot.tag = _categoryController.text;
          screenshot.description = _descriptionController.text;
          screenshot.location = _locationController.text.isNotEmpty
              ? _locationController.text
              : null;
          await isar.screenshots.put(screenshot);
        }
      });
      // DB更新後に再取得して最新タイトルを取得
      final updatedScreenshot = await isar.screenshots
          .filter()
          .assetIdEqualTo(widget.item.id)
          .findFirst();

      print('After update title: ${updatedScreenshot?.title}');

      // 編集完了後にDBの最新データを再取得
      print('Refreshing data...');
      await widget.onRefresh();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
      // widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 背景タップでキーボード閉じる
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag, // スクロールで閉じる
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '編集',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text('タイトル',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'タイトルを入力',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'タイトルを入力してください' : null,
                ),
                const SizedBox(height: 16),
                const Text('カテゴリ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 130,
                    child: SelectTagPullButton(
                      tags: _categoryOptions,
                      selectedTag: _selectedCategory,
                      borderRadius: 10,
                      borderColor: Colors.grey[600],
                      onTagSelected: (String value) {
                        setState(() {
                          _selectedCategory = value;
                          _categoryController.text = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('説明',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: '説明を入力',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                if (_categoryController.text == '場所') ...[
                  const Text('位置情報',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: '例: 東京駅 / 35.6812,139.7671',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: _submitForm,
                  label: "確定",
                  backgroundColor: Colors.black,
                  fontColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
