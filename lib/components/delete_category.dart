import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class DeleteCategory extends StatelessWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final Future<void> Function() onDelete;

  const DeleteCategory({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double listWidth = MediaQuery.of(context).size.width * 0.8;

    if (allTags.isEmpty) {
      return const Center(child: Text('タグがありません'));
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allTags.length,
          itemBuilder: (context, index) {
            final tag = allTags[index];
            final bool isSelected = selectedTags.contains(tag);

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
                      final newSelected = List<String>.from(selectedTags);
                      if (value == true) {
                        newSelected.add(tag);
                      } else {
                        newSelected.remove(tag);
                      }
                      onTagsChanged(newSelected); // 親に通知
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 40, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label: "削除",
                backgroundColor: Colors.red[400]!,
                fontColor: Colors.white,
                size: Size(listWidth * 0.3, 50),
                onPressed: () async {
                  await deleteTags(selectedTags);
                  onTagsChanged([]);
                  await onDelete();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
