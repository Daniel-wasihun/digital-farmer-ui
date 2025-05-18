import 'package:agri/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../controllers/auth/auth_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../services/api/base_api.dart';
import '../../../../../services/storage_service.dart';
import 'contact_us_screen.dart';
import 'change_password_screen.dart';
import 'feedback_screen.dart';
import 'security_question_screen.dart';
import 'dart:math' as math;
import 'update_profile_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final appController = Get.find<AppController>();
    final storageService = Get.find<StorageService>();
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;
    final isTablet = size.width > 600;

    // Adjusted scale factor for slightly larger content
    final scaleFactor = isTablet ? 1.0 : 0.9;

    // Text scale factor, slightly smaller for settings tiles
    final textScaleFactor = math.min(scaleFactor * 1.0, 1.0); // Reduced from 1.2/1.1

    const appShareUrl = 'https://example.com/app';
    const shareMessage =
        'Check out this awesome app! Download it at $appShareUrl';

    final settingsOptions = [
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'change_password'.tr,
        'action': () => ChangePasswordScreen.show(),
      },
      {
        'icon': Icons.person_outline_rounded,
        'title': 'update_profile'.tr,
        'action': () => UpdateProfileModal.show(),
      },
      {
        'icon': Icons.language_outlined,
        'title': 'language_preference'.tr,
        'action': () {
          appController.toggleLanguage();
        },
        'trailing': Obx(() => Text(
              appController.currentLanguage.value,
              textScaleFactor: textScaleFactor,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14 * textScaleFactor, // Reduced font size
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            )),
      },
      {
        'icon': Icons.security_outlined,
        'title': 'security_question'.tr,
        'action': () => SecurityQuestionScreen.show(),
      },
      {
        'icon': Icons.question_mark_outlined,
        'title': 'faq'.tr,
        'action': () => Get.toNamed(AppRoutes.getFaqPage()),
        'route': AppRoutes.getFaqPage(),
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'contact_us'.tr,
        'action': () => Get.dialog(
              const ContactUsScreen(),
              barrierDismissible: true,
              transitionDuration: const Duration(milliseconds: 300),
              transitionCurve: Curves.easeInOut,
            ),
      },
      {
        'icon': Icons.thumb_up_outlined,
        'title': 'feedback'.tr,
        'action': () => FeedbackScreen.show(),
      },
      {
        'icon': Icons.share_outlined,
        'title': 'invite_friend'.tr,
        'action': () async {
          try {
            await Share.share(shareMessage, subject: 'Invite a Friend');
          } catch (e) {
            Get.snackbar(
              'error'.tr,
              'failed_to_share'.tr,
              backgroundColor: Theme.of(context).colorScheme.error,
              colorText: Theme.of(context).colorScheme.onError,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16 * scaleFactor),
              child: _buildProfileCard(context, storageService, scaleFactor, textScaleFactor, cardColor),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8 * scaleFactor),
                        ...settingsOptions.map((option) => Padding(
                              padding: EdgeInsets.only(bottom: 8 * scaleFactor),
                              child: _buildSettingsTile(
                                context,
                                icon: option['icon'] as IconData,
                                title: option['title'] as String,
                                onTap: option['action'] != null
                                    ? option['action'] as VoidCallback
                                    : () => Get.toNamed(AppRoutes.getHomePage()),
                                scaleFactor: scaleFactor,
                                textScaleFactor: textScaleFactor,
                                trailing: option['trailing'] as Widget?,
                                cardColor: cardColor,
                              ),
                            )),
                        SizedBox(height: 80 * scaleFactor),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16 * scaleFactor,
                    right: 16 * scaleFactor,
                    bottom: 16 * scaleFactor,
                    child: _buildLogoutButton(context, authController, scaleFactor, textScaleFactor, cardColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, StorageService storageService, double scaleFactor, double textScaleFactor, Color cardColor) {
    return Obx(() {
      final user = storageService.user.value ?? storageService.getUser() ?? {};
      final username = user['username']?.toString() ?? 'User';
      final email = user['email']?.toString() ?? 'email@example.com';
      final profilePictureRaw = user['profilePicture']?.toString() ?? '';
      final profilePicture = profilePictureRaw.isNotEmpty
          ? profilePictureRaw.replaceFirst(
              RegExp(r'[/\\]?[uU][pP][lL][oO][aA][dD][sS][/\\]?'), '')
          : '';
      final hasProfilePicture = profilePicture.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 3 * scaleFactor),
            ),
          ],
        ),
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30 * scaleFactor,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundImage: hasProfilePicture
                  ? NetworkImage(
                      '${BaseApi.imageBaseUrl}/Uploads/$profilePicture?ts=${DateTime.now().millisecondsSinceEpoch}',
                    ) as ImageProvider<Object>?
                  : null,
              onForegroundImageError: hasProfilePicture
                  ? (exception, stackTrace) {
                      print('Profile image error: $exception, Stack: $stackTrace');
                    }
                  : null,
              child: hasProfilePicture
                  ? null
                  : Icon(
                      Icons.person_rounded,
                      size: 30 * scaleFactor,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
            ),
            SizedBox(width: 16 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    textScaleFactor: textScaleFactor,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * textScaleFactor,
                        ),
                  ),
                  SizedBox(height: 4 * scaleFactor),
                  Text(
                    email,
                    textScaleFactor: textScaleFactor,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 13 * textScaleFactor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    required double scaleFactor,
    required double textScaleFactor,
    Widget? trailing,
    required Color cardColor,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12 * scaleFactor),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 12 * scaleFactor,
            horizontal: 16 * scaleFactor,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28 * scaleFactor, // Increased icon size from 24 to 28
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 16 * scaleFactor),
              Expanded(
                child: Text(
                  title,
                  textScaleFactor: textScaleFactor,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * textScaleFactor, // Reduced font size from 16 to 14
                      ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(left: 16 * scaleFactor),
                  child: trailing,
                ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18 * scaleFactor, // Increased icon size from 16 to 18
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthController authController,
    double scaleFactor,
    double textScaleFactor,
    Color cardColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scaleFactor),
              ),
              title: Text(
                'logout'.tr,
                textScaleFactor: textScaleFactor,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              content: Text(
                'are_you_sure_logout'.tr,
                textScaleFactor: textScaleFactor,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('no'.tr, textScaleFactor: textScaleFactor),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text('yes'.tr, textScaleFactor: textScaleFactor),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
          ),
          elevation: 3 * scaleFactor,
        ),
        child: Text(
          'logout'.tr.toUpperCase(),
          textScaleFactor: textScaleFactor,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16 * textScaleFactor,
          ),
        ),
      ),
    );
  }
}