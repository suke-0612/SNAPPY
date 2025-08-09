import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1;
  int totalPages = 5;

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Pagination(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: _onPageChanged,
                ),
                Text(
                  'This is page $currentPage',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
