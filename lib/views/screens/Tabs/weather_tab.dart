import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/glassmorphic_card.dart';

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    return GlassmorphicCard(
      child: Text(
        'weather'.tr,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}