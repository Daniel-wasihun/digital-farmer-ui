import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/constants.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final baseScale = screenSize.width / 1920;
    final heightScale = screenSize.height / 1080;
    final scaleFactor = (baseScale * heightScale).clamp(0.4, 0.8);

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final username = args?['username'] ?? 'Unknown';
    final email = args?['email'] ?? 'N/A';
    final profilePicture = args?['profilePicture'] as String?;
    final bio = args?['bio'] as String? ?? 'No bio available';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20 * scaleFactor),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width * 0.8,
        padding: EdgeInsets.all(24 * scaleFactor),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Color(0xFF1A2B1F), Color(0xFF263238)]
                : [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12 * scaleFactor,
              offset: Offset(0, 6 * scaleFactor),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'profile'.tr,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24 * scaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white, size: 26 * scaleFactor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 16 * scaleFactor),
            // Larger square profile picture
            Container(
              width: 300 * scaleFactor,
              height: 300 * scaleFactor,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(16 * scaleFactor),
                image: profilePicture != null && profilePicture.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage('${BaseApi.imageBaseUrl}$profilePicture'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profilePicture == null || profilePicture.isEmpty
                  ? Center(
                      child: Text(
                        username[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 120 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 16 * scaleFactor),
            Text(
              username,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 28 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * scaleFactor),
            Text(
              email,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 20 * scaleFactor,
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            Container(
              padding: EdgeInsets.all(16 * scaleFactor),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16 * scaleFactor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10 * scaleFactor,
                    offset: Offset(0, 4 * scaleFactor),
                  ),
                ],
              ),
              child: Text(
                bio,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18 * scaleFactor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to show the modal
  static Future<void> show(BuildContext context, Map<String, dynamic> args) async {
    await showDialog(
      context: context,
      builder: (context) => UserProfileScreen(),
      routeSettings: RouteSettings(arguments: args),
    );
  }
}