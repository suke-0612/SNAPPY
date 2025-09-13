import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({super.key, required this.onSubmit});

  final Future<void> Function() onSubmit;

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _nameController.text.trim();
    final categoryDescription = _descriptionController.text.trim();

    try {
      // DBに保存（非同期）
      await saveTags([
        [categoryName, categoryDescription]
      ]);
    } catch (e) {
      print('Error saving category: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カテゴリの保存に失敗しました。')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリを作成しました！')),
      );
      _nameController.clear();
      _descriptionController.clear();
    }

    // 親に通知してタグリストを更新
    await widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final double formWidth = MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: SizedBox(
        width: formWidth,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'カテゴリ名',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: '例：train, book, など',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'カテゴリ名を入力してください。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'カテゴリの説明',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.black),
                    tooltip: '説明について',
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24.0),
                          child: const Text(
                            "スクショの内容を判別するために使用します。短く、正確なほど分類の精度が上がります。",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: '例:発車時刻、到着時刻、駅名などが含まれます。',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: '作成',
                  onPressed: _submitForm,
                  backgroundColor: Colors.teal[400]!,
                  fontColor: Colors.white,
                  size: Size(formWidth * 0.3, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
