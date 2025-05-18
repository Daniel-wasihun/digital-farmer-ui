import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../../controllers/update_profile_controller.dart';
import '../../../widgets/custom_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../services/api/base_api.dart';

class UpdateProfileModal extends GetView<UpdateProfileController> {
  const UpdateProfileModal({super.key});

  static void show() {
    Get.put(UpdateProfileController());
    Get.dialog(
      const UpdateProfileModal(),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;

    const double tinyPhoneMaxWidth = 300;
    const double verySmallPhoneMaxWidth = 360;
    const double smallPhoneMaxWidth = 480;
    const double compactTabletMinWidth = 600;
    const double largeTabletMinWidth = 800;
    const double desktopMinWidth = 1000;

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone =
        size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone =
        size.width >= verySmallPhoneMaxWidth && size.width < smallPhoneMaxWidth;
    final bool isCompactTablet = size.width >= compactTabletMinWidth &&
        size.width < largeTabletMinWidth;
    final bool isLargeTablet =
        size.width >= largeTabletMinWidth && size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    final double scaleFactor = isDesktop
        ? 1.2
        : isLargeTablet
            ? 1.1
            : isCompactTablet
                ? 1.0
                : isSmallPhone
                    ? 0.9
                    : isVerySmallPhone
                        ? 0.75
                        : isTinyPhone
                            ? 0.6
                            : 1.0;

    final double maxFormWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width *
                    (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);
    final double maxFormHeight = size.height *
        (isTinyPhone
            ? 0.85
            : isVerySmallPhone
                ? 0.8
                : isSmallPhone
                    ? 0.75
                    : 0.7);

    final double dialogHorizontalPadding =
        (size.width * 0.05 * scaleFactor).clamp(16.0, 40.0);
    final double cardPadding =
        math.max(8.0, 16.0 * scaleFactor).clamp(16.0, 32.0);

    final double baseTitleFontSize = 18.0;
    final double baseAppBarFontSize = 16.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0;

    final double titleFontSize =
        (baseTitleFontSize * scaleFactor).clamp(16.0, 22.0);
    final double appBarFontSize =
        (baseAppBarFontSize * scaleFactor).clamp(14.0, 18.0);
    final double fieldLabelFontSize =
        (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize =
        (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);

    final double buttonFontSize =
        (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0);

    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);
    final double avatarIconSize = (40.0 * scaleFactor).clamp(35.0, 50.0);
    final double editIconSize = (16.0 * scaleFactor).clamp(14.0, 20.0);
    final double closeIconSize = (22.0 * scaleFactor).clamp(18.0, 24.0);

    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0);

    final double spacingMedium = math.max(10.0, 14 * scaleFactor);
    final double spacingLarge = math.max(16.0, 20 * scaleFactor);
    final double spacingExtraLarge = math.max(20.0, 24 * scaleFactor);

    final double consistentVerticalPadding = math.max(12.0, 14 * scaleFactor);

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scaleFactor)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: dialogHorizontalPadding,
        vertical: spacingLarge,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxFormWidth.clamp(300, 700),
          maxHeight: maxFormHeight.clamp(300, 600),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: isDarkMode ? 6.0 : 10.0,
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scaleFactor)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: spacingMedium,
                            left: spacingExtraLarge,
                            right: spacingExtraLarge,
                            bottom: spacingLarge,
                          ),
                          child: Text(
                            'update_profile'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ) ??
                                TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow
                                          .withOpacity(isDarkMode ? 0.5 : 0.2),
                                      blurRadius: 8 * scaleFactor,
                                      spreadRadius: 2 * scaleFactor,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 48 * scaleFactor,
                                  backgroundColor: theme.colorScheme.surface,
                                  child: ClipOval(
                                    child: Obx(() {
                                      if (controller.selectedImageFile.value != null) {
                                        return Image.file(
                                          controller.selectedImageFile.value!,
                                          fit: BoxFit.cover,
                                          width: 96 * scaleFactor,
                                          height: 96 * scaleFactor,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print('File image error: $error');
                                            return _buildAvatarPlaceholder(
                                                theme, avatarIconSize);
                                          },
                                        );
                                      }
                                      else if (controller
                                              .selectedImageBytes.value !=
                                          null) {
                                        return Image.memory(
                                          controller.selectedImageBytes.value!,
                                          fit: BoxFit.cover,
                                          width: 96 * scaleFactor,
                                          height: 96 * scaleFactor,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print('Memory image error: $error');
                                            return _buildAvatarPlaceholder(
                                                theme, avatarIconSize);
                                          },
                                        );
                                      }
                                      final profilePictureUrl =
                                          controller.profilePictureUrl.value;
                                      final hasProfilePicture =
                                          profilePictureUrl.isNotEmpty;

                                      if (hasProfilePicture) {
                                        final imageUrl =
                                            '${BaseApi.imageBaseUrl}/Uploads/${profilePictureUrl.split('/').last.split('\\').last}';
                                        return CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          width: 96 * scaleFactor,
                                          height: 96 * scaleFactor,
                                          placeholder: (context, url) =>
                                              _buildAvatarPlaceholder(
                                                  theme, avatarIconSize),
                                          errorWidget: (context, url, error) {
                                            print(
                                                'Network image error: $error, URL: $url');
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              controller.profilePictureUrl
                                                  .value = '';
                                            });
                                            return _buildAvatarPlaceholder(
                                                theme, avatarIconSize);
                                          },
                                        );
                                      }

                                      return _buildAvatarPlaceholder(
                                          theme, avatarIconSize);
                                    }),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: controller.isLoading.value
                                      ? null
                                      : () async {
                                          print('Picking image from gallery');
                                          try {
                                            await controller.pickImage();
                                          } catch (e) {
                                            print('Image picking error: $e');
                                            Get.snackbar(
                                              'error'.tr,
                                              'failed_to_pick_image'.tr,
                                              duration:
                                                  const Duration(seconds: 4),
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              colorText:
                                                  theme.colorScheme.onError,
                                              margin:
                                                  EdgeInsets.all(spacingMedium),
                                              borderRadius: math.max(
                                                  6.0, 8 * scaleFactor),
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          }
                                        },
                                  child: Container(
                                    padding: EdgeInsets.all(4 * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.onSecondary,
                                          width: 2),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: editIconSize,
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        AnimatedOpacity(
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'username'.tr,
                            controller: controller.usernameController,
                            prefixIcon: Icons.person,
                            errorText: controller.usernameError.value.isEmpty
                                ? null
                                : controller.usernameError.value,
                            enabled: !controller.isLoading.value,
                            onChanged: (value) {
                              controller.username.value = value;
                              controller.validateUsername(value);
                            },
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(10.0, 12 * scaleFactor),
                              vertical: consistentVerticalPadding,
                            ),
                            borderRadius: math.max(6.0, 8 * scaleFactor),
                            filled: true,
                            fillColor:
                                theme.colorScheme.onSurface.withOpacity(0.05),
                            keyboardType: TextInputType.text,
                            obscureText: false,
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        AnimatedOpacity(
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'bio'.tr,
                            controller: controller.bioController,
                            prefixIcon: Icons.info,
                            errorText: controller.bioError.value.isEmpty
                                ? null
                                : controller.bioError.value,
                            enabled: !controller.isLoading.value,
                            onChanged: (value) {
                              controller.bio.value = value;
                              controller.validateBio(value);
                            },
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(10.0, 12 * scaleFactor),
                              vertical: consistentVerticalPadding,
                            ),
                            borderRadius: math.max(6.0, 8 * scaleFactor),
                            filled: true,
                            fillColor:
                                theme.colorScheme.onSurface.withOpacity(0.05),
                            keyboardType: TextInputType.multiline,
                            obscureText: false,
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        AnimatedScale(
                          scale : controller.isLoading.value ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    print('Update profile button pressed');
                                    controller.updateProfile();
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: math.max(10.0, 14 * scaleFactor)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(6.0, 8 * scaleFactor)),
                              ),
                              elevation: 3,
                              textStyle: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w600),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: loaderSize,
                                    height: loaderSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          math.max(1.5, 2.0 * scaleFactor),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary),
                                    ),
                                  )
                                : Text(
                                    'update_profile'.tr.toUpperCase(),
                                    style: TextStyle(fontSize: buttonFontSize),
                                  ),
                        ),
                    )],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -spacingMedium * 0,
              right: -spacingMedium * 0,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(spacingMedium / 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: closeIconSize,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(ThemeData theme, double avatarIconSize) {
    return Icon(
      Icons.person,
      size: avatarIconSize,
      color: theme.colorScheme.onSurface.withOpacity(0.6),
    );
  }
}