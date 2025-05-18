import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // Helper function to launch URLs with error handling
  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar(context, 'Could not find an app to open the URL.');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error launching URL: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      colorText: Theme.of(context).colorScheme.onError,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;

    // --- Responsive Calculations ---

    // Breakpoints
    const double verySmallPhoneMaxWidth = 265;
    const double smallPhoneMaxWidth = 350;
    const double mediumPhoneMaxWidth = 500;
    const double tabletMinWidth = 600;
    const double largeTabletMinWidth = 900;

    final bool isVerySmallPhone = size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone =
        size.width < smallPhoneMaxWidth && size.width >= verySmallPhoneMaxWidth;
    final bool isMediumPhone =
        size.width < mediumPhoneMaxWidth && size.width >= smallPhoneMaxWidth;
    final bool isTablet = size.width >= tabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth;

    // Dynamic scaleFactor
    final double scaleFactor = isLargeTablet
        ? 1.25
        : isTablet
            ? 1.1
            : isMediumPhone
                ? 1.0
                : isSmallPhone
                    ? 0.9
                    : 0.8;

    // Responsive constraints
    final double maxWidth = isLargeTablet
        ? 600
        : isTablet
            ? 500
            : size.width * 0.95;
    final double maxHeight = size.height *
        (isVerySmallPhone ? 0.7 : isSmallPhone ? 0.65 : 0.7);

    // Responsive padding for the Dialog/Card
    final double cardPadding = isLargeTablet
        ? 24.0
        : isTablet
            ? 20.0
            : (isSmallPhone || isMediumPhone)
                ? 16.0
                : 10.0;

    // Base sizes
    const double baseIconSize = 22.0;
    const double baseTitleSize = 16.0;
    const double basePlatformTextSize = 10.0;

    // Calculate responsive sizes with clamping
    final double iconSize = (baseIconSize * scaleFactor).clamp(16.0, 28.0);
    final double titleFontSize =
        (baseTitleSize * scaleFactor).clamp(13.0, 20.0);
    final double platformTextSize =
        (basePlatformTextSize * scaleFactor).clamp(8.0, 12.0);
    final double closeIconSize =
        (20.0 * scaleFactor).clamp(16.0, 24.0);

    // Determine crossAxisCount based on available width
    final int crossAxisCount;
    if (isVerySmallPhone) {
      crossAxisCount = 1;
    } else if (isSmallPhone) {
      crossAxisCount = 2;
    } else if (isMediumPhone) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    // Grid Spacing
    final double gridSpacing = math.max(6.0, 10.0 * scaleFactor);

    // Grid Child Aspect Ratio
    final double childAspectRatio;
    if (crossAxisCount == 1) {
      childAspectRatio = 4.5;
    } else if (crossAxisCount == 2) {
      childAspectRatio = 1.7;
    } else {
      childAspectRatio = 1.4;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(math.max(8.0, 16.0 * scaleFactor)),
      ),
      backgroundColor: Colors.transparent,
      insetPadding:
          EdgeInsets.symmetric(horizontal: cardPadding * 0.8, vertical: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth.clamp(240, 600),
          maxHeight: maxHeight.clamp(220, 450),
        ),
        child: Stack(
          children: [
            Card(
              elevation: theme.cardTheme.elevation ?? 4.0,
              color: cardColor,
              shape: theme.cardTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        math.max(8.0, 16.0 * scaleFactor)),
                  ),
              shadowColor: theme.cardTheme.shadowColor,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: closeIconSize * 1.2,
                        left: cardPadding,
                        right: cardPadding,
                        bottom: cardPadding * 0.5,
                      ),
                      child: Text(
                        'contact_us'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: isDarkMode
                                      ? Colors.black38
                                      : Colors.black12,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ) ??
                            TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: gridSpacing * 0.8,
                          mainAxisSpacing: gridSpacing,
                          childAspectRatio: childAspectRatio,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: cardPadding * 0.2,
                              vertical: gridSpacing * 0.5),
                          children: [
                            _buildSocialLink(
                              context,
                              icon: MdiIcons.linkedin,
                              name: 'LinkedIn',
                              url: 'https://linkedin.com/in/Daniel-Wasihun',
                              scaleFactor: scaleFactor,
                              iconSize: iconSize,
                              textSize: platformTextSize,
                              axis: crossAxisCount == 1
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              cardColor: cardColor,
                            ),
                            _buildSocialLink(
                              context,
                              icon: Icons.send,
                              name: 'Telegram',
                              url: 'https://t.me/DanielWasihun',
                              scaleFactor: scaleFactor,
                              iconSize: iconSize,
                              textSize: platformTextSize,
                              axis: crossAxisCount == 1
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              cardColor: cardColor,
                            ),
                            _buildSocialLink(
                              context,
                              icon: MdiIcons.github,
                              name: 'GitHub',
                              url: 'https://github.com/Daniel-wasihun',
                              scaleFactor: scaleFactor,
                              iconSize: iconSize,
                              textSize: platformTextSize,
                              axis: crossAxisCount == 1
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              cardColor: cardColor,
                            ),
                            _buildSocialLink(
                              context,
                              icon: MdiIcons.twitter,
                              name: 'X / Twitter',
                              url: 'https://x.com/Daniel_wasihun',
                              scaleFactor: scaleFactor,
                              iconSize: iconSize,
                              textSize: platformTextSize,
                              axis: crossAxisCount == 1
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              cardColor: cardColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -cardPadding * 0,
              right: -cardPadding * 0,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(cardPadding / 2),
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

  // Helper widget - Updated to take cardColor parameter
  Widget _buildSocialLink(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String url,
    required double scaleFactor,
    required double iconSize,
    required double textSize,
    required Axis axis,
    required Color cardColor,
  }) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final double itemInternalPadding =
        (4.0 * scaleFactor).clamp(2.0, 5.0);
    final double iconContainerPadding =
        (5.0 * scaleFactor).clamp(3.0, 7.0);
    final double iconBorderRadius =
        (7.0 * scaleFactor).clamp(5.0, 9.0);
    final double spacingBetweenElements =
        itemInternalPadding * (axis == Axis.horizontal ? 2.5 : 1.5);

    Widget iconWidget = Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(iconBorderRadius),
      shadowColor: isDarkMode ? Colors.black45 : Colors.black.withOpacity(0.15),
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(iconContainerPadding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(iconBorderRadius),
          border: Border.all(
            color: theme.colorScheme.secondary
                .withOpacity(isDarkMode ? 0.4 : 0.25),
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.secondary,
          size: iconSize,
        ),
      ),
    );

    Widget textWidget = Flexible(
      flex: axis == Axis.horizontal ? 1 : 0,
      child: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: textSize,
              fontWeight: FontWeight.w500,
            ),
        textAlign:
            axis == Axis.horizontal ? TextAlign.start : TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    Widget content = (axis == Axis.horizontal)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: spacingBetweenElements),
              textWidget,
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: spacingBetweenElements),
              textWidget,
            ],
          );

    return Tooltip(
      message: 'Open $name profile',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => _launchURL(url, context),
          borderRadius: BorderRadius.circular(iconBorderRadius),
          hoverColor: theme.colorScheme.secondary.withOpacity(0.1),
          splashColor: theme.colorScheme.secondary.withOpacity(0.15),
          highlightColor: theme.colorScheme.secondary.withOpacity(0.15),
          child: Padding(
            padding: axis == Axis.horizontal
                ? EdgeInsets.symmetric(
                    horizontal: itemInternalPadding * 2,
                    vertical: itemInternalPadding)
                : EdgeInsets.all(itemInternalPadding * 0.8),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}