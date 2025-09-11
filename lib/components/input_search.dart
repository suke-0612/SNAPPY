import 'package:flutter/material.dart';

class InputSearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const InputSearch({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          cursorColor: Colors.grey[800],
          decoration: InputDecoration(
            hintText: '検索',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }
}
