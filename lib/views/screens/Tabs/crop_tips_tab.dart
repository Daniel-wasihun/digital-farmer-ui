import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/glassmorphic_card.dart';

class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return GlassmorphicCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'cropTips'.tr,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 40,
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14 * scaleFactor,
                  ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                hintText: 'Search crops...'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}