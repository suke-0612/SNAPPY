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
      appBar: const Header(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF98E6E),
                  Color(0xFFFFCFD2),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 40,
            child:
                _buildBlurCircle(200, const Color(0xFFB2EBF2).withOpacity(0.5)),
          ),
          Positioned(
            top: -30,
            left: -40,
            child:
                _buildBlurCircle(180, const Color(0xFFB39DDB).withOpacity(0.4)),
          ),
          Positioned(
            bottom: 70,
            left: -30,
            child:
                _buildBlurCircle(160, const Color(0xFFB2EBF2).withOpacity(0.4)),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: _buildBlurCircle(
                200, const Color(0xFFEF5350).withOpacity(0.25)),
          ),
          Positioned(
            top: 130,
            right: -30,
            child:
                _buildBlurCircle(120, const Color(0xFFFFD700).withOpacity(0.4)),
          ),
          Positioned(
            bottom: 110,
            left: 40,
            child:
                _buildBlurCircle(140, const Color(0xFF536DFE).withOpacity(0.3)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
              // 選択されているインデックスに応じて、表示するページを切り替える
              child: _pages.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),

      // ここがフッター部分
      bottomNavigationBar: BottomNavigationBar(
        // フッターに表示するアイテムのリスト
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
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
        currentIndex: _selectedIndex, // 現在選択されているアイテム
        onTap: _onItemTapped, // タップされたときの処理

        // --- フッターのデザイン設定 ---
        backgroundColor: Colors.white, // 背景色
        selectedItemColor: Color(0xFFF98E6E), // 選択中のアイテムの色
        unselectedItemColor: Colors.grey, // 非選択のアイテムの色
        type: BottomNavigationBarType.fixed, // アイテムを等間隔に配置
        showUnselectedLabels: true, // 非選択のラベルも表示
        selectedFontSize: 12.0, // 選択中のフォントサイズ
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}
