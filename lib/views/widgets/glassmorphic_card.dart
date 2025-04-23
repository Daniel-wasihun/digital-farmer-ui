import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;

  const GlassmorphicCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final isDark = Get.isDarkMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(16 * scaleFactor),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color(0xFF263238).withOpacity(0.3),
                      Color(0xFF1A2B1F).withOpacity(0.25),
                    ]
                  : [
                      Colors.white.withOpacity(0.25),
                      Color(0xFFE8F5E9).withOpacity(0.2),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Color(0xFF388E3C).withOpacity(0.4)
                  : Color(0xFF81C784).withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Color(0xFF388E3C).withOpacity(0.2)
                    : Color(0xFF81C784).withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}