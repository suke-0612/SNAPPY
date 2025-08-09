import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static List<String> tags = ["all", "map", "train", "things"];
  String selectedTag = tags.first;

  void _onTagSelected(String tag) {
    setState(() {
      selectedTag = tag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selected Tag: $selectedTag',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SelectTagPullButton(
                    tags: tags,
                    selectedTag: selectedTag,
                    onTagSelected: _onTagSelected,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
