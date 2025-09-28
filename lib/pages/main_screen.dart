import 'package:flutter/material.dart';
import 'package:snappy/importer.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 現在選択されているページのインデックス
  int _selectedIndex = 0;

  // フッターで切り替えるページのリスト
  static const List<Widget> _pages = <Widget>[
    Home(),
    WantList(),
    MapPage(),
    CategorySettings(),
    Settings(),
  ];

  // フッターのアイテムがタップされたときの処理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 選択されているインデックスに応じて、表示するページを切り替える
      body: _pages.elementAt(_selectedIndex),
      
      // ここがフッター部分
      bottomNavigationBar: BottomNavigationBar(
        // フッターに表示するアイテムのリスト
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'マイリスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'マップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'カテゴリー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,       // 現在選択されているアイテム
        onTap: _onItemTapped,              // タップされたときの処理
        
        // --- フッターのデザイン設定 ---
        backgroundColor: Colors.white,      // 背景色
        selectedItemColor: Color(0xFFF98E6E), // 選択中のアイテムの色
        unselectedItemColor: Colors.grey,     // 非選択のアイテムの色
        type: BottomNavigationBarType.fixed,  // アイテムを等間隔に配置
        showUnselectedLabels: true,           // 非選択のラベルも表示
        selectedFontSize: 12.0,               // 選択中のフォントサイズ
      ),
    );
  }
}