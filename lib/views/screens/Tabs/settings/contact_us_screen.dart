import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/glassmorphic_card.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        title: Text(
          'contact_us'.tr,
          style: TextStyle(
            fontSize: 18 * scaleFactor,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : size.width * 0.9,
          ),
          child: GlassmorphicCard(
            child: Padding(
              padding: EdgeInsets.all(16 * scaleFactor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'contact_us'.tr,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 22 * scaleFactor,
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  CustomTextField(
                    label: 'message'.tr,
                    controller: messageController,
                    prefixIcon: Icons.message,
                    scaleFactor: scaleFactor,
                    // maxLines: 5,
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  ElevatedButton(
                    onPressed: () {
                      Get.snackbar('success'.tr, 'message_sent'.tr,
                          backgroundColor: Colors.green, colorText: Colors.white);
                      Get.back();
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Text(
                      'send'.tr,
                      style: TextStyle(
                        fontSize: 14 * scaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}