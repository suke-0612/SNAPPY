import 'package:flutter/material.dart';

class SelectTagPullButton extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final Function(String) onTagSelected;

  const SelectTagPullButton({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: selectedTag,
        icon: const Icon(Icons.keyboard_arrow_down),
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(height: 0, color: Colors.transparent),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        onChanged: (String? value) {
          if (value != null) {
            onTagSelected(value);
          }
        },
        items: tags.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
