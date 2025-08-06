import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'ここに設定の内容',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
