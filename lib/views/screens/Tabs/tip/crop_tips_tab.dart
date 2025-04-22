import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return Stack(
      children: [
        // Your other Crop Tips content would go here

        Positioned(
          bottom: 16 * scaleFactor,
          right: 16 * scaleFactor,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AIChatScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300), // Adjust as needed
                ),
              );
            },
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