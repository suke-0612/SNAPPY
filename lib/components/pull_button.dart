import 'package:flutter/material.dart';

class SelectTagPullButton extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final Function(String) onTagSelected;
  final Color? borderColor;
  final double borderRadius;
  final bool shadow;

  const SelectTagPullButton({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.borderColor,
    this.shadow = false,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? Colors.transparent),
        boxShadow: [
          if (shadow)
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTag,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
          elevation: 16,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
          onChanged: (String? value) {
            if (value != null) {
              onTagSelected(value);
            }
          },
          items: tags.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
