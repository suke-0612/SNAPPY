import 'package:flutter/material.dart';
import 'dart:math' as math;

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

    // 1ページ目を表示
    pages.add(_buildPageButton(1));

    // 1ページ目と現在のページ範囲の間に省略記号が必要か
    if (currentPage > 3) {
      pages.add(_buildEllipsis());
    }

    // 現在のページの前後1ページを表示
    int start = (currentPage - 1);
    int end = (currentPage + 1);

    if (currentPage >= totalPages - 1 &&
        (currentPage - 2) >= 2 &&
        (currentPage - 2) <= totalPages - 1) {
      pages.add(_buildPageButton(currentPage - 2));
    }

    for (int i = start; i <= end; i++) {
      if (i > 1 && i < totalPages) {
        pages.add(_buildPageButton(i));
      }
    }

    if (currentPage <= 2 && (currentPage + 2) <= totalPages) {
      pages.add(_buildPageButton(currentPage + 2));
    }

    // 現在のページ範囲と最後のページの間に省略記号が必要か
    if (currentPage < totalPages - 2) {
      pages.add(_buildEllipsis());
    }

    // 最後のページを表示（1ページより多い場合）
    if (totalPages > 1) {
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
          border: Border.all(color: Colors.grey[300]!),
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
