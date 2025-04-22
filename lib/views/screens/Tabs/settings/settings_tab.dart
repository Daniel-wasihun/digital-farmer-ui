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
    final isTablet = size.width > 600;

    // Adjusted scale factor for overall smaller content
    final scaleFactor = isTablet ? 0.9 : 0.8; // Reduced base scale factor

    // Text scale factor, ensuring text doesn't become too small
    final textScaleFactor = math.min(scaleFactor * 1.1, 1.0); // Slightly larger text relative to other elements

    const appShareUrl = 'https://example.com/app'; // Replace with your actual app URL
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
          Get.snackbar(
            'success'.tr,
            'language_changed'.tr,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            colorText: Theme.of(context).colorScheme.onSecondary,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(10 * scaleFactor),
          );
        },
        'trailing': Obx(() => Text(
              appController.currentLanguage.value,
              textScaleFactor: textScaleFactor,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14 * textScaleFactor, // Keep font size relative to text scale
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
              padding: EdgeInsets.all(12 * scaleFactor), // Reduced padding
              child: _buildProfileCard(context, storageService, scaleFactor, textScaleFactor),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor), // Reduced horizontal padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 6 * scaleFactor), // Reduced space
                        ...settingsOptions.map((option) => Padding(
                              padding:
                                  EdgeInsets.only(bottom: 6 * scaleFactor), // Reduced space between tiles
                              child: _buildSettingsTile(
                                context,
                                icon: option['icon'] as IconData,
                                title: option['title'] as String,
                                onTap: option['action'] != null
                                    ? option['action'] as VoidCallback
                                    : () =>
                                        Get.toNamed(AppRoutes.getHomePage()),
                                scaleFactor: scaleFactor,
                                 textScaleFactor: textScaleFactor, // Pass text scale factor
                                trailing: option['trailing'] as Widget?,
                              ),
                            )),
                        SizedBox(height: 60 * scaleFactor), // Adjusted height for logout button space
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12 * scaleFactor, // Match horizontal padding
                    right: 12 * scaleFactor, // Match horizontal padding
                    bottom: 12 * scaleFactor, // Reduced bottom padding
                    child: _buildLogoutButton(context, authController, scaleFactor, textScaleFactor),
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
      BuildContext context, StorageService storageService, double scaleFactor, double textScaleFactor) {
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10 * scaleFactor), // Slightly smaller border radius
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
              blurRadius: 6 * scaleFactor, // Reduced blur
              offset: Offset(0, 2 * scaleFactor), // Adjusted offset
            ),
          ],
        ),
        padding: EdgeInsets.all(12 * scaleFactor), // Reduced padding
        child: Row(
          children: [
            CircleAvatar(
              radius: 24 * scaleFactor, // Reduced avatar size
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
                      size: 24 * scaleFactor, // Reduced icon size
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
            ),
            SizedBox(width: 12 * scaleFactor), // Reduced space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    textScaleFactor: textScaleFactor,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15 * textScaleFactor, // Adjusted font size
                        ),
                  ),
                  SizedBox(height: 3 * scaleFactor), // Reduced space
                  Text(
                    email,
                    textScaleFactor: textScaleFactor,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 11 * textScaleFactor, // Adjusted font size
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
    required double textScaleFactor, // Receive text scale factor
    Widget? trailing,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10 * scaleFactor), // Slightly smaller border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scaleFactor), // Match border radius
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10 * scaleFactor, // Reduced vertical padding for smaller tile height
            horizontal: 12 * scaleFactor, // Reduced horizontal padding
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20 * scaleFactor, // Reduced icon size
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12 * scaleFactor), // Reduced space
              Expanded(
                child: Text(
                  title,
                  textScaleFactor: textScaleFactor, // Use passed text scale factor
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * textScaleFactor, // Adjusted font size
                      ),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(left: 12 * scaleFactor), // Reduced padding
                  child: trailing,
                ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14 * scaleFactor, // Reduced icon size
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
    double textScaleFactor, // Receive text scale factor
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor), // Match horizontal padding
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scaleFactor), // Adjusted border radius
              ),
              title: Text(
                'logout'.tr,
                textScaleFactor: textScaleFactor, // Use passed text scale factor
                style: Theme.of(context).textTheme.titleSmall,
              ),
              content: Text(
                'are_you_sure_logout'.tr,
                textScaleFactor: textScaleFactor, // Use passed text scale factor
                style: Theme.of(context).textTheme.bodySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('no'.tr, textScaleFactor: textScaleFactor), // Use passed text scale factor
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    authController.logout();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text('yes'.tr, textScaleFactor: textScaleFactor), // Use passed text scale factor
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          padding: EdgeInsets.symmetric(vertical: 10 * scaleFactor), // Reduced vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10 * scaleFactor), // Adjusted border radius
          ),
          elevation: 2 * scaleFactor, // Adjusted elevation
        ),
        child: Text(
          'logout'.tr.toUpperCase(),
          textScaleFactor: textScaleFactor, // Use passed text scale factor
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14 * textScaleFactor, // Adjusted font size
          ),
        ),
      ),
    );
  }
}