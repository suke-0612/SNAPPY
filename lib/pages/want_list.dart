import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class WantList extends StatelessWidget {
  const WantList({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'ここに欲しいものリストの内容',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
