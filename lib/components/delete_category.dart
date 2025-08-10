import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class DeleteCategory extends StatefulWidget {
  final VoidCallback onPressedDelete;
  final List<String> Function() getTags;

  DeleteCategory(
      {super.key, required this.onPressedDelete, required this.getTags});

  @override
  State<DeleteCategory> createState() => _DeleteCategoryState();
}

class _DeleteCategoryState extends State<DeleteCategory> {
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    final List<String> tags = widget.getTags();
    final double listWidth = MediaQuery.of(context).size.width * 0.8;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final bool isSelected = _selectedTags.contains(tag);

              return Center(
                  child: SizedBox(
                      width: listWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: CheckboxListTile(
                          title: Text(tag),
                          value: isSelected,
                          activeColor: const Color(0xFFDE543F),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      )));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: CustomButton(
            onPressed: widget.onPressedDelete,
            label: "削除",
            fontColor: Colors.white,
            backgroundColor: const Color(0xFFDE543F),
          ),
        ),
      ],
    );
  }
}
