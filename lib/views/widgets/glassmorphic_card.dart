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
                      Colors.grey.shade900.withOpacity(0.3),
                      Colors.black.withOpacity(0.25),
                    ]
                  : [
                      Colors.white.withOpacity(0.25),
                      Colors.blue.shade50.withOpacity(0.2),
                    ],
            ),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}