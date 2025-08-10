import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({super.key});

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final categoryName = _nameController.text;
      final categoryDescription = _descriptionController.text;

      print('カテゴリ名: $categoryName');
      print('説明: $categoryDescription');

      try {
        saveTags([
          [categoryName, categoryDescription]
        ]);
      } catch (e) {
        print('Error saving category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カテゴリの保存に失敗しました。')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('カテゴリを作成しました！')),
      );

      _nameController.clear();
      _descriptionController.clear();
    }
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
              const SizedBox(height: 8.0),
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
              const SizedBox(height: 24.0),
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
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: '例:発車時刻、到着時刻、駅名などが含まれます。',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32.0),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: '作成',
                  onPressed: _submitForm,
                  backgroundColor: const Color(0xFFA1CCA6),
                  fontColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
