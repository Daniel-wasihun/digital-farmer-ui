import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../controllers/market_controller.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize MarketController to ensure it's available for MarketPage
    Get.put(MarketController());
    // Initialize controllers
    final AppController appController = Get.put(AppController());
    final ChatController chatController = Get.put(ChatController());
    final AuthController authController = Get.put(AuthController());

    // Use TweenAnimationBuilder for stateless fade animation
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: _HomeScreenContent(
        appController: appController,
        chatController: chatController,
        authController: authController,
      ),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  final AppController appController;
  final ChatController chatController;
  final AuthController authController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _HomeScreenContent({
    required this.appController,
    required this.chatController,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final textScaleFactor = isTablet ? 1.0 : 0.9;
    final appBarHeight = (height * 0.07 * scaleFactor).clamp(48.0, 64.0);
    final drawerWidth = (size.width * 0.75).clamp(250.0, 400.0);

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          elevation: 2,
          title: Obx(() => Text(
                appController.pageTitles[appController.selectedIndex.value].tr,
                style: TextStyle(
                  fontSize: height * 0.024 * scaleFactor,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              )),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              size: height * 0.028 * scaleFactor,
              color: Colors.white,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            SizedBox(width: 6 * scaleFactor),
          ],
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        width: drawerWidth,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        ),
        child: _ProfessionalDrawer(
          appController: appController,
          authController: authController,
          height: height,
          scaleFactor: scaleFactor,
          textScaleFactor: textScaleFactor,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Obx(() => IndexedStack(
              index: appController.selectedIndex.value,
              children: appController.pageFactories.map((factory) => factory()).toList(),
            )),
      ),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.agriculture, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(
                    Icons.agriculture,
                    size: height * 0.028 * scaleFactor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'cropTips'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(
                    Icons.cloud,
                    size: height * 0.028 * scaleFactor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'weather'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(
                    Icons.store,
                    size: height * 0.028 * scaleFactor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'market'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Obx(() => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.chat, size: height * 0.028 * scaleFactor),
                          if (chatController.totalUnseenMessageCount > 0)
                            Positioned(
                              right: -5 * scaleFactor,
                              top: -5 * scaleFactor,
                              child: Container(
                                padding: EdgeInsets.all(3 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chatController.totalUnseenMessageCount > 99
                                      ? '99+'
                                      : chatController.totalUnseenMessageCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height * 0.012 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                  activeIcon: Obx(() => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.chat,
                            size: height * 0.028 * scaleFactor,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          if (chatController.totalUnseenMessageCount > 0)
                            Positioned(
                              right: -5 * scaleFactor,
                              top: -5 * scaleFactor,
                              child: Container(
                                padding: EdgeInsets.all(3 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chatController.totalUnseenMessageCount > 99
                                      ? '99+'
                                      : chatController.totalUnseenMessageCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height * 0.012 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                  label: 'chat'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(
                    Icons.settings,
                    size: height * 0.028 * scaleFactor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'settings'.tr,
                ),
              ],
              currentIndex: appController.selectedIndex.value,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).bottomNavigationBarTheme.unselectedItemColor?.withOpacity(0.6),
              onTap: appController.changePage,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedLabelStyle: TextStyle(
                fontSize: height * 0.016 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: height * 0.014 * scaleFactor,
                fontWeight: FontWeight.w400,
              ),
            ),
          )),
    );
  }
}

class _ProfessionalDrawer extends StatelessWidget {
  final AppController appController;
  final AuthController authController;
  final double height;
  final double scaleFactor;
  final double textScaleFactor;

  const _ProfessionalDrawer({
    required this.appController,
    required this.authController,
    required this.height,
    required this.scaleFactor,
    required this.textScaleFactor,
  });

  // Show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
              Get.back(); // Close dialog
              Get.back(); // Close drawer
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1A252F)
            : theme.drawerTheme.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: height * 0.22 * scaleFactor,
            padding: EdgeInsets.all(16 * scaleFactor),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // App Logo/Icon
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.all(8 * scaleFactor),
                    child: Icon(
                      Icons.agriculture,
                      size: 40 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12 * scaleFactor),
                  // App Name and User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Agri App'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24 * scaleFactor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Obx(() => Text(
                              authController.userName.value.isNotEmpty
                                  ? '${'Hello'.tr}, ${authController.userName.value}'
                                  : 'Welcome'.tr,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16 * scaleFactor,
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
              children: [
                // Navigation Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
                  child: Text(
                    'Navigation'.tr,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : theme.textTheme.bodySmall!.color?.withOpacity(0.6),
                      fontSize: 14 * scaleFactor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.agriculture_outlined,
                  title: 'Crop Tips'.tr,
                  isSelected: appController.selectedIndex.value == 0,
                  onTap: () {
                    appController.changePage(0);
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.cloud_outlined,
                  title: 'weather'.tr,
                  isSelected: appController.selectedIndex.value == 1,
                  onTap: () {
                    appController.changePage(1);
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.store_outlined,
                  title: 'Market'.tr,
                  isSelected: appController.selectedIndex.value == 2,
                  onTap: () {
                    appController.changePage(2);
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.chat_outlined,
                  title: 'chat'.tr,
                  isSelected: appController.selectedIndex.value == 3,
                  onTap: () {
                    appController.changePage(3);
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'settings'.tr,
                  isSelected: appController.selectedIndex.value == 4,
                  onTap: () {
                    appController.changePage(4);
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                // Preferences Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
                  child: Text(
                    'Preferences'.tr,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : theme.textTheme.bodySmall!.color?.withOpacity(0.6),
                      fontSize: 14 * scaleFactor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: appController.themeController.isDarkMode.value
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  title: appController.themeController.isDarkMode.value
                      ? 'Light Mode'.tr
                      : 'Dark Mode'.tr,
                  isSelected: false,
                  onTap: () {
                    appController.toggleTheme();
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.language_outlined,
                  title: 'Toggle Language'.tr,
                  isSelected: false,
                  onTap: () {
                    appController.toggleLanguage();
                    Get.back();
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
                // Account Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
                  child: Text(
                    'Account'.tr,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : theme.textTheme.bodySmall!.color?.withOpacity(0.6),
                      fontSize: 14 * scaleFactor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout_outlined,
                  title: 'logout'.tr,
                  isSelected: false,
                  onTap: () {
                    _showLogoutConfirmationDialog(context);
                  },
                  scaleFactor: scaleFactor,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: EdgeInsets.all(16 * scaleFactor),
            child: Text(
              'Version 1.0.0'.tr,
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : theme.textTheme.bodySmall!.color?.withOpacity(0.5),
                fontSize: 12 * scaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double scaleFactor,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 2 * scaleFactor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * scaleFactor),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24 * scaleFactor,
            color: isSelected
                ? theme.colorScheme.primary
                : isDarkMode
                    ? Colors.white70
                    : theme.iconTheme.color?.withOpacity(0.7),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16 * scaleFactor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDarkMode
                      ? Colors.white70
                      : theme.textTheme.bodyMedium!.color,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
          ),
          tileColor: Colors.transparent,
          hoverColor: theme.colorScheme.primary.withOpacity(0.05),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scaleFactor,
            vertical: 4 * scaleFactor,
          ),
          minVerticalPadding: 8 * scaleFactor,
          visualDensity: VisualDensity.standard,
        ),
      ),
    );
  }
}