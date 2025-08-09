import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<ItemData> _items = List.generate(
    10,
    (index) => ItemData(
      id: '${index + 1}',
      imagePath: 'assets/images/IMG_0304.jpg',
      text: 'アイテム ${index + 1}',
      onTapPopupContent: Text('アイテム ${index + 1} の詳細情報'),
    ),
  );

  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  void _handleLongPress(ItemData item) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedItems.add(item.id);
      });
    }
  }

  void _handleTap(ItemData item) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedItems.contains(item.id)) {
          _selectedItems.remove(item.id);
          if (_selectedItems.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedItems.add(item.id);
        }
      });
    } else {
      _showPopup(item.onTapPopupContent);
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      _items.removeWhere((item) => _selectedItems.contains(item.id));
      _exitSelectionMode();
    });
    print('削除が実行されました: $_selectedItems');
  }

  void _showPopup(Widget content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: content,
      ),
    );
  }

  Widget _buildSelectionPanel() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.black.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              ),
              Text(
                '${_selectedItems.length}個選択中',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteSelectedItems,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          if (_isSelectionMode) _buildSelectionPanel(),
          Expanded(
            child: ItemsView(
              items: _items,
              selectedItems: _selectedItems,
              isSelectionMode: _isSelectionMode,
              onItemTap: _handleTap,
              onItemLongPress: _handleLongPress,
            ),
          ),
        ],
      ),
    );
  }
}
