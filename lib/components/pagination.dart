import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ..._buildPageNumbers(),
        ],
      ),
    );
  }

  // 数字表示部
  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // totalPagesが0以下の場合は空のリストを返す
    if (totalPages <= 0) {
      return pages;
    }

    // 常に同じ数の要素を表示するための設定
    const int maxVisibleElements = 7; // 数字ボタン + 省略記号の合計数

    // 総ページ数が少ない場合は、すべてのページを表示
    if (totalPages <= maxVisibleElements) {
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildPageButton(i));
      }
      return pages;
    }

    // 1ページ目は常に表示
    pages.add(_buildPageButton(1));

    // 現在のページに基づいて表示パターンを決定
    if (currentPage <= 4) {
      // 前半部分の表示 [1] 2 3 4 5 ... 10
      for (int i = 2; i <= 5; i++) {
        pages.add(_buildPageButton(i));
      }
      pages.add(_buildEllipsis());
      pages.add(_buildPageButton(totalPages));
    } else if (currentPage >= totalPages - 3) {
      // 後半部分の表示 1 ... 6 7 8 9 [10]
      pages.add(_buildEllipsis());
      for (int i = totalPages - 4; i <= totalPages; i++) {
        if (i > 1) {
          pages.add(_buildPageButton(i));
        }
      }
    } else {
      // 中間部分の表示 1 ... 4 [5] 6 ... 10
      pages.add(_buildEllipsis());
      pages.add(_buildPageButton(currentPage - 1));
      pages.add(_buildPageButton(currentPage));
      pages.add(_buildPageButton(currentPage + 1));
      pages.add(_buildEllipsis());
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int pageNumber) {
    return GestureDetector(
      onTap: () => onPageChanged(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: currentPage == pageNumber ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: currentPage == pageNumber ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      alignment: Alignment.center,
      width: 44,
      child: const Text(
        '...',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
