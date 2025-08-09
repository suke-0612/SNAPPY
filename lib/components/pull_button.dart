import 'package:flutter/material.dart';

class SelectTagPullButton extends StatefulWidget {
  final List<String> tags;

  const SelectTagPullButton({
    super.key,
    required this.tags,
  });

  @override
  State<SelectTagPullButton> createState() => _SelectTagPullButtonState();
}

class _SelectTagPullButtonState extends State<SelectTagPullButton> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.tags.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurpleAccent),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: widget.tags.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
}
