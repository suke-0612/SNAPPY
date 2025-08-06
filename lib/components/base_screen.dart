// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  const BaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const Header(),
        endDrawer: const AppDrawer(),
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
              child: _buildBlurCircle(
                  200, const Color(0xFFB2EBF2).withOpacity(0.4)),
            ),
            Positioned(
              top: -40,
              left: -50,
              child: _buildBlurCircle(
                  180, const Color(0xFFB39DDB).withOpacity(0.6)),
            ),
            Positioned(
              bottom: 80,
              left: -50,
              child: _buildBlurCircle(
                  160, const Color(0xFFB2EBF2).withOpacity(0.4)),
            ),
            Positioned(
              bottom: -40,
              right: -30,
              child: _buildBlurCircle(
                  200, const Color(0xFFEF5350).withOpacity(0.25)),
            ),
            Positioned(
              top: 150,
              right: -40,
              child: _buildBlurCircle(
                  120, const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            Positioned(
              bottom: 120,
              left: 40,
              child: _buildBlurCircle(
                  140, const Color(0xFF536DFE).withOpacity(0.15)),
            ),
            SafeArea(child: child),
          ],
        ));
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
