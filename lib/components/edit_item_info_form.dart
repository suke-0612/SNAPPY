import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class EditItemInfoForm extends StatefulWidget {
  final ItemData item;
  final VoidCallback onSubmit;

  const EditItemInfoForm({
    super.key,
    required this.item,
    required this.onSubmit,
  });

  @override
  State<EditItemInfoForm> createState() => _EditItemInfoFormState();
}

class _EditItemInfoFormState extends State<EditItemInfoForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;

  // DropdownButtonの選択値を保持するための状態変数
  late String _selectedCategory;
  final List<String> _categoryOptions = ['カテゴリ1', 'カテゴリ2', 'カテゴリ3', 'その他'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.text);

    // initialCategoryでコントローラーと状態変数を初期化
    _categoryController = TextEditingController(text: widget.item.category);
    _selectedCategory = widget.item.category;

    _descriptionController =
        TextEditingController(text: widget.item.description);

    // initialCategoryが選択肢にない場合には最初の選択肢を設定
    if (!_categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = _categoryOptions.first;
      _categoryController.text = _selectedCategory;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit();
      final isar = await openIsarInstance();
      isar.writeTxn(() async {
        final screenshot =
            await isar.screenshots.get(int.parse(widget.item.id));
        if (screenshot != null) {
          screenshot.title = _titleController.text;
          screenshot.tag = _categoryController.text;
          screenshot.description = _descriptionController.text;
          await isar.screenshots.put(screenshot);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('編集内容を保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '編集',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'タイトル',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'タイトルを入力',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'カテゴリ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 130,
                    child: SelectTagPullButton(
                      tags: _categoryOptions,
                      selectedTag: _selectedCategory,
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
                const Text(
                  '説明',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: '説明を入力',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: () async {
                    await _submitForm();
                  },
                  label: "確定",
                  backgroundColor: Colors.black,
                  fontColor: Colors.white,
                ),
              ]),
        ),
      ),
    );
  }
}
