import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static void show(BuildContext context, Map<String, dynamic> args) => Get.dialog(
        const UserProfileScreen(),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        transitionCurve: Curves.easeInOut,
        arguments: args,
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final username = args?['username'] ?? 'Unknown';
    final email = args?['email'] ?? 'N/A';
    final profilePicture = args?['profilePicture'] as String?;
    final bio = args?['bio'] ?? 'No bio available';

    // Responsive scale factor
    final scaleFactor = (size.width / 600).clamp(0.6, 1.2);
    final double maxWidth = size.width * 0.95 > 800 ? 800 : size.width * 0.95;
    final maxHeight = (size.height * 0.8).clamp(400.0, 700.0);

    // Responsive sizes
    final profileWidth = (size.width * 0.5).clamp(300.0, 450.0);
    final profileHeight = profileWidth / 1.2;
    final titleFontSize = (24.0 * scaleFactor).clamp(20.0, 28.0);
    final subtitleFontSize = (18.0 * scaleFactor).clamp(16.0, 22.0);
    final bodyFontSize = (16.0 * scaleFactor).clamp(14.0, 18.0);
    final spacing = (16.0 * scaleFactor).clamp(12.0, 24.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor, vertical: spacing),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Card(
                elevation: isDarkMode ? 6.0 : 10.0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scaleFactor)),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.cardColor,
                        isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.all(16.0 * scaleFactor),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'profile'.tr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        SizedBox(height: spacing),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            width: profileWidth,
                            height: profileHeight,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12 * scaleFactor),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.4),
                                  blurRadius: 20 * scaleFactor,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12 * scaleFactor),
                              child: profilePicture?.isNotEmpty ?? false
                                  ? Image.network(
                                      '${BaseApi.imageBaseUrl}$profilePicture',
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) => progress == null
                                          ? child
                                          : CircularProgressIndicator(
                                              value: progress.expectedTotalBytes != null
                                                  ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                                  : null,
                                              color: theme.colorScheme.onPrimary,
                                            ),
                                      errorBuilder: (context, error, stackTrace) => _buildInitial(context, username, profileHeight, theme),
                                    )
                                  : _buildInitial(context, username, profileHeight, theme),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing),
                        Text(
                          username,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing * 0.5),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: bodyFontSize,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: spacing),
                        Container(
                          padding: EdgeInsets.all(spacing),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12 * scaleFactor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8 * scaleFactor,
                                offset: Offset(0, 4 * scaleFactor),
                              ),
                            ],
                          ),
                          child: Text(
                            bio,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: bodyFontSize,
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -spacing,
              right: -spacing,
              child: InkWell(
                onTap: Get.back,
                hoverColor: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(spacing / 2),
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
                    size: 24 * scaleFactor,
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

  Widget _buildInitial(BuildContext context, String username, double size, ThemeData theme) => Center(
        child: Text(
          username[0].toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}