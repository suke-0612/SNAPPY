import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 1; // 最初のページ番号
  int totalPages = 20; // そうページ数

  //currentPageを引数の値に更新する関数．
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
