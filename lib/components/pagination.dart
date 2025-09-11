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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildPageNumbers(),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    if (totalPages <= 0) return pages;

    const int maxVisibleElements = 7;

    if (totalPages <= maxVisibleElements) {
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildPageButton(i));
      }
      return pages;
    }

    pages.add(_buildPageButton(1));

    if (currentPage <= 4) {
      for (int i = 2; i <= 5; i++) {
        pages.add(_buildPageButton(i));
      }
      pages.add(_buildEllipsis());
      pages.add(_buildPageButton(totalPages));
    } else if (currentPage >= totalPages - 3) {
      pages.add(_buildEllipsis());
      for (int i = totalPages - 4; i <= totalPages; i++) {
        if (i > 1) pages.add(_buildPageButton(i));
      }
    } else {
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
    final bool isCurrent = pageNumber == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Material(
        color: isCurrent ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: isCurrent ? 4 : 1,
        child: InkWell(
          onTap: () => onPageChanged(pageNumber),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Text(
              '$pageNumber',
              style: TextStyle(
                color: isCurrent ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        width: 44,
        alignment: Alignment.center,
        child: const Text(
          '...',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
