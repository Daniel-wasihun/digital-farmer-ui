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
    final appController = Get.find<AppController>();
    final storageService = Get.find<StorageService>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.0 : 0.85;

    final settingsOptions = [
      {
        'icon': Icons.lock,
        'title': 'change_password'.tr,
        'route': AppRoutes.getChangePasswordPage(),
      },
      {
        'icon': Icons.person,
        'title': 'update_profile'.tr,
        'route': AppRoutes.getUpdateProfilePage(),
      },
      {
        'icon': Icons.language,
        'title': 'language_preference'.tr,
        'action': () {
          appController.toggleLanguage();
          Get.snackbar('success'.tr, 'language_changed'.tr,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              colorText: Theme.of(context).colorScheme.onSecondary);
        },
        'trailing': Obx(() => Text(
              appController.currentLanguage.value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12 * scaleFactor,
                    fontWeight: FontWeight.w400,
                  ),
            )),
        'showArrow': false,
      },
      {
        'icon': Icons.security,
        'title': 'security_question'.tr,
        'route': AppRoutes.getSecurityQuestionPage(),
      },
      {
        'icon': Icons.help,
        'title': 'faq'.tr,
        'route': AppRoutes.getFaqPage(),
      },
      {
        'icon': Icons.contact_support,
        'title': 'contact_us'.tr,
        'route': AppRoutes.getContactUsPage(),
      },
      {
        'icon': Icons.feedback,
        'title': 'feedback'.tr,
        'route': AppRoutes.getFeedbackPage(),
      },
      {
        'icon': Icons.share,
        'title': 'invite_friend'.tr,
        'action': () {
          Get.snackbar('info'.tr, 'Share feature not implemented yet',
              backgroundColor: Theme.of(context).colorScheme.secondary,
              colorText: Theme.of(context).colorScheme.onSecondary);
        },
      },
    ];

    // Estimate content height
    final profileCardHeight = 60 * scaleFactor; // Padding (12*2) + avatar (24*2)
    final tileHeight = 40 * scaleFactor; // Padding (8*2) + icon (20) + margin (4*2)
    final spacingHeight = 12 * scaleFactor * 2; // Between profile and list, list and button
    final contentHeightWithoutButton = profileCardHeight +
        (settingsOptions.length * tileHeight) +
        spacingHeight;
    final buttonHeight = 40 * scaleFactor; // Logout button
    final totalContentHeight = contentHeightWithoutButton + buttonHeight;

    return SafeArea(
      bottom: false, // Handle bottom padding manually
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final needsScroll = totalContentHeight > availableHeight;

          // Calculate space to push button to bottom in no-scroll case
          final spaceToBottom = availableHeight -
              contentHeightWithoutButton -
              buttonHeight -
              MediaQuery.of(context).padding.bottom -
              20 * scaleFactor; // Increased margin

          print(
              'AvailableHeight: $availableHeight, ContentHeight: $totalContentHeight, '
              'NeedsScroll: $needsScroll, SpaceToBottom: $spaceToBottom, '
              'BottomPadding: ${MediaQuery.of(context).padding.bottom + 24 * scaleFactor}');

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : size.width * 0.85,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildProfileCard(context, storageService, scaleFactor),
                      SizedBox(height: 12 * scaleFactor),
                      ...settingsOptions.asMap().entries.map((entry) {
                        final option = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4 * scaleFactor),
                          child: _buildSettingsTile(
                            context,
                            icon: option['icon'] as IconData,
                            title: option['title'] as String,
                            onTap: option['route'] != null
                                ? () {
                                    print('Navigating to ${option['route']}');
                                    Get.toNamed(option['route'] as String);
                                  }
                                : option['action'] as VoidCallback?,
                            scaleFactor: scaleFactor,
                            trailing: option['trailing'] as Widget?,
                            showArrow: option['showArrow'] != false,
                          ),
                        );
                      }),
                      SizedBox(height: 12 * scaleFactor),
                      needsScroll
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: 12 * scaleFactor,
                                right: 12 * scaleFactor,
                                bottom: MediaQuery.of(context).padding.bottom +
                                    24 * scaleFactor, // Increased margin
                              ),
                              child: _buildLogoutButton(context, authController, scaleFactor),
                            )
                          : Column(
                              children: [
                                if (spaceToBottom > 0)
                                  SizedBox(height: spaceToBottom),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 12 * scaleFactor,
                                    right: 12 * scaleFactor,
                                    bottom: MediaQuery.of(context).padding.bottom +
                                        24 * scaleFactor, // Increased margin
                                  ),
                                  child: _buildLogoutButton(context, authController, scaleFactor),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, StorageService storageService, double scaleFactor) {
    return Obx(() {
      final user = storageService.user.value ?? storageService.getUser();
      final username = user?['username'] ?? 'User';
      final email = user?['email'] ?? 'email@example.com';
      final profilePicture = user?['profilePicture']?.replaceFirst(
            RegExp(r'[/\\]?[uU][pP][lL][oO][aA][dD][sS][/\\]?'),
            '',
          ) ??
          '';

      print(
          'SettingsTab user: username=$username, email=$email, profilePicture=$profilePicture');
      print('Profile URL: ${ApiService.imageBaseUrl}/Uploads/$profilePicture');

      return Container(
        padding: EdgeInsets.all(12 * scaleFactor),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardTheme.shadowColor!,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24 * scaleFactor,
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: profilePicture.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        '${ApiService.imageBaseUrl}/uploads/$profilePicture?ts=${DateTime.now().millisecondsSinceEpoch}',
                        width: 48 * scaleFactor,
                        height: 48 * scaleFactor,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image error: $error');
                          return Icon(
                            Icons.person,
                            size: 24 * scaleFactor,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 24 * scaleFactor,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
            SizedBox(width: 10 * scaleFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14 * scaleFactor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12 * scaleFactor,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(0.7),
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
    Widget? trailing,
    bool showArrow = true,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8 * scaleFactor,
            horizontal: 12 * scaleFactor,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20 * scaleFactor,
                color: Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 10 * scaleFactor),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 13 * scaleFactor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (trailing != null) trailing,
              if (showArrow && trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14 * scaleFactor,
                  color: Theme.of(context).colorScheme.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, AuthController authController, double scaleFactor) {
    return ElevatedButton(
      onPressed: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text('logout'.tr, style: Theme.of(context).textTheme.titleMedium),
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
                child: Text('yes'.tr),
              ),
            ],
          ),
        );
      },
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
            minimumSize: WidgetStateProperty.all(
              Size(double.infinity, 40 * scaleFactor),
            ),
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 10 * scaleFactor),
            ),
          ),
      child: Text('logout'.tr),
    );
  }
}