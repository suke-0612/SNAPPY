import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, Widget page,
      {bool clearStack = false}) {
    Navigator.pop(context);
    final route = PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

    if (clearStack) {
      Navigator.pushAndRemoveUntil(context, route, (_) => false);
    } else {
      Navigator.push(context, route);
    }
  }

  // 共通のListTile生成
  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget page,
    bool clearStack = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => _navigateTo(context, page, clearStack: clearStack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: 150,
            height: 100,
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF98E6E),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 40,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: const Text(
                        'MENU',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  _buildMenuTile(
                    context: context,
                    icon: Icons.home,
                    title: 'ホーム',
                    page: const Home(),
                    clearStack: true,
                  ),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.map,
                    title: 'マップ',
                    page: const MapPage(),
                  ),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.category,
                    title: 'カテゴリー編集',
                    page: const CategorySettings(),
                  ),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.settings,
                    title: '設定',
                    page: const Settings(),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
