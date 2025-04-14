import 'package:agri/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final appcontroller = Get.find<AppController>();
    final storageService = Get.find<StorageService>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.1 : 0.9;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 550 : size.width * 0.9,
        ),
        child: Column(
          children: [
            Obx(() {
              final user = storageService.user.value ?? storageService.getUser();
              final username = user?['username'] ?? 'User';
              final email = user?['email'] ?? 'email@example.com';
              final profilePicture = user?['profilePicture']?.replaceFirst(
                    RegExp(r'[/\\]?[uU][pP][lL][oO][aA][dD][sS][/\\]?'),
                    '',
                  ) ??
                  '';

              print('SettingsTab user: username=$username, email=$email, profilePicture=$profilePicture');
              print('Profile URL: ${ApiService.imageBaseUrl}/uploads/$profilePicture');

              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16 * scaleFactor,
                  horizontal: 8 * scaleFactor,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30 * scaleFactor,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: profilePicture.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                '${ApiService.imageBaseUrl}/uploads/$profilePicture',
                                width: 60 * scaleFactor,
                                height: 60 * scaleFactor,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Image error: $error');
                                  return Icon(
                                    Icons.person,
                                    size: 30 * scaleFactor,
                                    color: Theme.of(context).primaryColor,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator();
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30 * scaleFactor,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                    SizedBox(width: 12 * scaleFactor),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 14 * scaleFactor,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: 12 * scaleFactor,
                  horizontal: 8 * scaleFactor,
                ),
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.lock,
                    title: 'change_password'.tr,
                    onTap: () => Get.toNamed(AppRoutes.getChangePasswordPage()),
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.person,
                    title: 'update_profile'.tr,
                    onTap: () {
                      print('Navigating to UpdateProfileScreen');
                      Get.toNamed(AppRoutes.getUpdateProfilePage());
                    },
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.language,
                    title: 'language_preference'.tr,
                    onTap: () {
                      appcontroller.toggleLanguage();
                      Get.snackbar('success'.tr, 'language_changed'.tr,
                          backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    scaleFactor: scaleFactor,
                    trailing:Text(
                        'language'.tr,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14 * scaleFactor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                    showArrow: false,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.security,
                    title: 'security_question'.tr,
                    onTap: () => Get.toNamed(AppRoutes.getSecurityQuestionPage()),
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.help,
                    title: 'faq'.tr,
                    onTap: () => Get.toNamed(AppRoutes.getFaqPage()),
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.contact_support,
                    title: 'contact_us'.tr,
                    onTap: () => Get.toNamed(AppRoutes.getContactUsPage()),
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.feedback,
                    title: 'feedback'.tr,
                    onTap: () => Get.toNamed(AppRoutes.getFeedbackPage()),
                    scaleFactor: scaleFactor,
                  ),
                  Divider(height: 1, thickness: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.share,
                    title: 'invite_friend'.tr,
                    onTap: () {
                      Get.snackbar('info'.tr, 'Share feature not implemented yet',
                          backgroundColor: Colors.blue, colorText: Colors.white);
                    },
                    scaleFactor: scaleFactor,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16 * scaleFactor,
                  horizontal: 8 * scaleFactor,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text('logout'.tr,
                            style: Theme.of(context).textTheme.titleMedium),
                        content: Text('are_you_sure_logout'.tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('no'.tr),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              authController.logout();
                            },
                            child: Text('yes'.tr,
                                style: const TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48 * scaleFactor),
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14 * scaleFactor,
                          fontWeight: FontWeight.w600,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                    ),
                  ),
                  child: Text('logout'.tr),
                ),
              ),
            ),
          ],
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
    Widget? trailing,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10 * scaleFactor,
          horizontal: 8 * scaleFactor,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22 * scaleFactor,
              color: textColor ?? Theme.of(context).primaryColor,
            ),
            SizedBox(width: 10 * scaleFactor),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14 * scaleFactor,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Theme.of(context).textTheme.bodyMedium!.color,
                    ),
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow && trailing == null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16 * scaleFactor,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }
}