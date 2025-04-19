import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ai_chat_screen.dart';

class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return Stack(
      children: [
        Positioned(
          bottom: 16 * scaleFactor,
          right: 16 * scaleFactor,
          child: FloatingActionButton(
            onPressed: () => Get.to(() => const AIChatScreen()),
            backgroundColor: Colors.green[600],
            mini: true,
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}