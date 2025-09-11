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
              child: child,
            ),
          ),
        ],
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
