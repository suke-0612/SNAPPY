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
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '検索',
            prefixIcon: const Icon(Icons.search),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
