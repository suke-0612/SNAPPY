import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'ここにホームの内容',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
