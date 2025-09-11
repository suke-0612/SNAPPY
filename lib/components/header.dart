import 'package:flutter/material.dart';
import 'package:snappy/pages/home.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      titleSpacing: 10,
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                final currentRoute = ModalRoute.of(context)?.settings.name;

                if (currentRoute != Home.routeName) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Home(),
                      settings: const RouteSettings(name: Home.routeName),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Image(
                image: AssetImage('assets/images/snappy_logo.png'),
                height: kToolbarHeight * 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
