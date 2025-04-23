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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Color(0xFF1A2B1F), Color(0xFF263238)]
                : [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        Color(0xFF2E7D32),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                elevation: 6,
                shadowColor: Colors.black38,
                title: Text(
                  'profile'.tr,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24 * scaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Colors.white, size: 26 * scaleFactor),
                  onPressed: () => Get.back(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(24 * scaleFactor),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60 * scaleFactor,
                        backgroundColor: AppConstants.primaryColor,
                        backgroundImage: profilePicture != null &&
                                profilePicture.isNotEmpty
                            ? NetworkImage('http://localhost:5000$profilePicture')
                            : null,
                        child: profilePicture == null || profilePicture.isEmpty
                            ? Text(
                                username[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40 * scaleFactor,
                                  fontWeight: FontWeight.bold,
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontSize: 20 * scaleFactor,
                        ),
                      ),
                      SizedBox(height: 16 * scaleFactor),
                      Container(
                        padding: EdgeInsets.all(16 * scaleFactor),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(16 * scaleFactor),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}