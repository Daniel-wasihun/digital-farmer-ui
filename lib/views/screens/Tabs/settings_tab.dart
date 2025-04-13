
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/glassmorphic_card.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : size.width * 0.9,
        ),
        child: Container(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor, horizontal: 12 * scaleFactor),
            children: [
              Text(
                'settings'.tr,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 22 * scaleFactor,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16 * scaleFactor),
              _buildSettingsTile(
                context,
                icon: Icons.lock,
                title: 'change_password'.tr,
                onTap: () => Get.toNamed(AppRoutes.getChangePasswordPage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.person,
                title: 'update_profile'.tr,
                onTap: () => Get.toNamed(AppRoutes.getUpdateProfilePage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language,
                title: 'language_preference'.tr,
                onTap: () {
                  authController.toggleLanguage();
                  Get.snackbar('success'.tr, 'language_changed'.tr,
                      backgroundColor: Colors.green, colorText: Colors.white);
                },
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.security,
                title: 'security_question'.tr,
                onTap: () => Get.toNamed(AppRoutes.getSecurityQuestionPage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.help,
                title: 'faq'.tr,
                onTap: () => Get.toNamed(AppRoutes.getFaqPage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.contact_support,
                title: 'contact_us'.tr,
                onTap: () => Get.toNamed(AppRoutes.getContactUsPage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.feedback,
                title: 'feedback'.tr,
                onTap: () => Get.toNamed(AppRoutes.getFeedbackPage()),
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.share,
                title: 'invite_friend'.tr,
                onTap: () {
                  // Implement share functionality
                  // For simplicity, show a snackbar (replace with actual share logic)
                  Get.snackbar('info'.tr, 'Share feature not implemented yet',
                      backgroundColor: Colors.blue, colorText: Colors.white);
                },
                scaleFactor: scaleFactor,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.logout,
                title: 'logout'.tr,
                onTap: () => authController.logout(),
                scaleFactor: scaleFactor,
                textColor: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double scaleFactor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24 * scaleFactor,
        color: textColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16 * scaleFactor,
              fontWeight: FontWeight.w500,
              color: textColor ?? Theme.of(context).textTheme.bodyMedium!.color,
            ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
      dense: true,
    );
  }
}