import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> tags = ["all", "things", "map", "train"];

    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SelectTagPullButton(tags: tags),
            ),
          ),
        ],
      ),
    );
  }
}
