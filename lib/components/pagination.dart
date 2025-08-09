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
          // 先頭のページに戻るボタン
          if (currentPage > 1) ...[
            GestureDetector(
              onTap: () => onPageChanged(1),
              child: const Icon(
                Icons.keyboard_double_arrow_left,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () => onPageChanged(currentPage - 1),
              child: const Icon(
                Icons.keyboard_arrow_left,
                color: Colors.black,
              ),
            ),
          ] else
            const SizedBox(width: 48), // スペースを確保

          // 数字のリスト
          ...List.generate(totalPages, (index) {
            final pageIndex = index + 1;
            return GestureDetector(
              onTap: () => onPageChanged(pageIndex),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: currentPage == pageIndex ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '$pageIndex',
                  style: TextStyle(
                    color:
                        currentPage == pageIndex ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),

          // 次のページに進むボタン
          if (currentPage < totalPages) ...[
            GestureDetector(
              onTap: () => onPageChanged(currentPage + 1),
              child: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () => onPageChanged(totalPages),
              child: const Icon(
                Icons.keyboard_double_arrow_right,
                color: Colors.black,
              ),
            ),
          ] else
            const SizedBox(width: 48), // スペースを確保
        ],
      ),
    );
  }
}
