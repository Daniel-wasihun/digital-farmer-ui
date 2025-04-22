import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // Helper function to launch URLs with error handling (no changes needed here)
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

    // --- Responsive Calculations ---

    // Breakpoints (Added very small)
    const double verySmallPhoneMaxWidth = 265; // Breakpoint for 1 column
    const double smallPhoneMaxWidth = 350;
    const double mediumPhoneMaxWidth = 500; // Breakpoint for 3 columns
    const double tabletMinWidth = 600;
    const double largeTabletMinWidth = 900;

    final bool isVerySmallPhone = size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone =
        size.width < smallPhoneMaxWidth && size.width >= verySmallPhoneMaxWidth;
    final bool isMediumPhone =
        size.width < mediumPhoneMaxWidth && size.width >= smallPhoneMaxWidth;
    final bool isTablet = size.width >= tabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth;

    // Dynamic scaleFactor (Adjusted for very small)
    final double scaleFactor = isLargeTablet
        ? 1.25
        : isTablet
            ? 1.1
            : isMediumPhone // Includes normal phones now
                ? 1.0
                : isSmallPhone
                    ? 0.9 // Slightly smaller for small phones
                    : 0.8; // Even smaller for very small phones

    // Responsive constraints (Min width adjusted slightly if needed)
    final double maxWidth = isLargeTablet
        ? 600
        : isTablet
            ? 500
            : size.width * 0.95;
    final double maxHeight = size.height *
        (isVerySmallPhone ? 0.7 : isSmallPhone ? 0.65 : 0.7); // Allow more height on very small

    // Responsive padding for the Dialog/Card (Adjusted min)
    final double cardPadding = isLargeTablet
        ? 24.0
        : isTablet
            ? 20.0
            : (isSmallPhone || isMediumPhone) // Merged small/medium phone padding
                ? 16.0
                : 10.0; // Minimum padding for very small

    // Base sizes (No changes here needed now)
    const double baseIconSize = 22.0;
    const double baseTitleSize = 16.0;
    const double basePlatformTextSize = 10.0;

    // Calculate responsive sizes with clamping (Adjusted min clamp slightly)
    final double iconSize = (baseIconSize * scaleFactor).clamp(16.0, 28.0); // Lowered min icon size
    final double titleFontSize =
        (baseTitleSize * scaleFactor).clamp(13.0, 20.0); // Lowered min title size
    final double platformTextSize =
        (basePlatformTextSize * scaleFactor).clamp(8.0, 12.0); // Lowered min platform text size
    final double closeIconSize =
        (20.0 * scaleFactor).clamp(16.0, 24.0); // Lowered min close icon size

    // Determine crossAxisCount based on available width (Added 1 column)
    final int crossAxisCount;
    if (isVerySmallPhone) {
      crossAxisCount = 1;
    } else if (isSmallPhone) {
      crossAxisCount = 2;
    } else if (isMediumPhone) {
      // Medium phones and potentially small tablets if below 600
      crossAxisCount = 3;
    } else {
      // Larger phones (>500), tablets
      crossAxisCount = 4;
    }

    // Grid Spacing (Adjusted min)
    final double gridSpacing = math.max(6.0, 10.0 * scaleFactor); // Lowered min spacing, reduced base slightly

    // Grid Child Aspect Ratio (Adjusted significantly for crossAxisCount = 1)
    // When 1 column, width is large, height should be relatively small -> large aspect ratio
    // When more columns, width is small, height is relatively larger -> smaller aspect ratio
    final double childAspectRatio;
    if (crossAxisCount == 1) {
      childAspectRatio = 4.5; // Item should be much wider than tall (adjust as needed)
    } else if (crossAxisCount == 2) {
      childAspectRatio = 1.7; // More height needed relative to width
    } else {
      // 3 or 4 columns
      childAspectRatio = 1.4;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(math.max(8.0, 16.0 * scaleFactor)),
        // Min radius
      ),
      backgroundColor: Colors.transparent,
      insetPadding:
          EdgeInsets.symmetric(horizontal: cardPadding * 0.8, vertical: 24.0),
      // Adjusted horizontal inset slightly
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth.clamp(240, 600),
          // Lowered min width constraint
          maxHeight: maxHeight.clamp(220, 450),
          // Lowered min height constraint
        ),
        child: Stack(
          children: [
            Card(
              elevation: theme.cardTheme.elevation ?? 4.0,
              color: theme.cardTheme.color ?? theme.colorScheme.surface,
              shape: theme.cardTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        math.max(8.0, 16.0 * scaleFactor)), // Match dialog shape
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
                        top: closeIconSize * 1.2, // Adjusted top padding
                        left: cardPadding,
                        right: cardPadding,
                        bottom: cardPadding * 0.5, // Add some bottom padding
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
                        maxLines: 2, // Allow title to wrap if needed
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Removed SizedBox, rely on padding

                    Flexible(
                      child: SingleChildScrollView(
                        // Keep for safety, though less likely needed now
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
                          // Reduced grid padding
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
                                  : Axis.vertical, // Pass axis
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
                                  : Axis.vertical, // Pass axis
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
                                  : Axis.vertical, // Pass axis
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
                                  : Axis.vertical, // Pass axis
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

  // Helper widget - NOW takes an Axis parameter
  Widget _buildSocialLink(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String url,
    required double scaleFactor,
    required double iconSize,
    required double textSize,
    required Axis axis, // Specify layout direction
  }) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final double itemInternalPadding =
        (4.0 * scaleFactor).clamp(2.0, 5.0); // Reduced min/max
    final double iconContainerPadding =
        (5.0 * scaleFactor).clamp(3.0, 7.0); // Reduced min/max
    final double iconBorderRadius =
        (7.0 * scaleFactor).clamp(5.0, 9.0); // Reduced min/max
    final double spacingBetweenElements =
        itemInternalPadding * (axis == Axis.horizontal ? 2.5 : 1.5); // More spacing for Row

    Widget iconWidget = Material(
      elevation: 1.5, // Slightly reduced elevation
      borderRadius: BorderRadius.circular(iconBorderRadius),
      shadowColor: isDarkMode ? Colors.black45 : Colors.black.withOpacity(0.15),
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(iconContainerPadding),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(iconBorderRadius),
          border: Border.all(
            color: theme.colorScheme.secondary
                .withOpacity(isDarkMode ? 0.4 : 0.25),
            width: 0.8, // Thinner border
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
      // Use Flexible within Row/Column
      flex: axis == Axis.horizontal ? 1 : 0, // Allow text to expand in Row
      child: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: textSize,
              fontWeight: FontWeight.w500,
            ),
        textAlign:
            axis == Axis.horizontal ? TextAlign.start : TextAlign.center, // Align text differently
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // Conditionally return Row or Column
    Widget content = (axis == Axis.horizontal)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            // Row takes minimum horizontal space needed
            crossAxisAlignment: CrossAxisAlignment.center,
            // Center vertically
            children: [
              iconWidget,
              SizedBox(width: spacingBetweenElements),
              textWidget, // Flexible handles width
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: spacingBetweenElements),
              textWidget, // Flexible not strictly needed here but harmless
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
            // Adjust padding based on axis to ensure content is centered
            padding: axis == Axis.horizontal
                ? EdgeInsets.symmetric(
                    horizontal: itemInternalPadding * 2,
                    vertical: itemInternalPadding)
                : EdgeInsets.all(itemInternalPadding * 0.8),
            child: Center(child: content),
            // Center the Row/Column within the InkWell area
          ),
        ),
      ),
    );
  }
}