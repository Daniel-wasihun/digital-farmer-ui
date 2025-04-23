import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/glassmorphic_card.dart';

class GenericTab extends StatelessWidget {
  final String tabKey;

  const GenericTab({super.key, required this.tabKey});

  String getContentKey(String tabKey) {
    switch (tabKey) {
      case 'home':
        return 'cropTips';
      case 'profile':
        return 'weather';
      case 'notifications':
        return 'market';
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
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}