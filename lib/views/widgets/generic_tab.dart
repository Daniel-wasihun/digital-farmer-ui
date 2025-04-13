import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'glassmorphic_card.dart';

class GenericTab extends StatelessWidget {
  final String tabKey;

  const GenericTab({super.key, required this.tabKey});

  // Map tab keys to content keys for placeholders
  String getContentKey(String tabKey) {
    switch (tabKey) {
      case 'home':
        return 'cropTips'; // Placeholder: Tips
      case 'profile':
        return 'weather'; // Placeholder: Weather
      case 'notifications':
        return 'market'; // Placeholder: Market
      case 'chat':
        return 'chat';
      case 'settings':
        return 'settings';
      default:
        return tabKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;

    return GlassmorphicCard(
      child: Text(
        getContentKey(tabKey).tr,
        style: TextStyle(
          fontSize: 18 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}