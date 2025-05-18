import 'dart:ui';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../controllers/market_controller.dart';
import '../../utils/constants.dart';
import '../../controllers/app_drawer_controller.dart';

class HomeScreen extends material.StatelessWidget {
  const HomeScreen({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    // Initialize controllers
    Get.put(MarketController(), permanent: true);
    Get.put(AppController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(AppDrawerController(), permanent: true);

    final AppController appController = Get.find<AppController>();
    final ChatController chatController = Get.find<ChatController>();
    final AuthController authController = Get.find<AuthController>();
    final AppDrawerController drawerController = Get.find<AppDrawerController>();

    final size = material.MediaQuery.of(context).size;
    final height = size.height;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final textScaleFactor = isTablet ? 1.0 : 0.9;
    final appBarHeight = (height * 0.06 * scaleFactor).clamp(40.0, 56.0);
    final bottomBarHeight = (height * 0.08 * scaleFactor).clamp(56.0, 72.0);
    final isDarkMode = material.Theme.of(context).brightness == material.Brightness.dark;
    final cardColor = isDarkMode ? const material.Color(0xFF1A252F) : material.Colors.white;
    final backgroundColor = isDarkMode ? const material.Color(0xFF263544) : material.Colors.grey[200];

    // Set status bar color to dark green (green-black)
    services.SystemChrome.setSystemUIOverlayStyle(
      const services.SystemUiOverlayStyle(
        statusBarColor: material.Color(0xFF1A3C34),
        statusBarIconBrightness: material.Brightness.light,
      ),
    );

    return material.Scaffold(
      body: material.SafeArea(
        top: true,
        bottom: false,
        child: material.Stack(
          children: [
            // Main content with app bar and bottom bar
            material.AnimatedBuilder(
              animation: drawerController.animationController,
              builder: (context, child) {
                final slideValue = drawerController.animationController.value;
                return material.GestureDetector(
                  onTap: slideValue > 0 ? drawerController.toggleDrawer : null,
                  behavior: material.HitTestBehavior.opaque,
                  child: material.Stack(
                    children: [
                      material.IgnorePointer(
                        ignoring: slideValue > 0,
                        child: material.Transform.translate(
                          offset: material.Offset(slideTransform(slideValue) * 280, 0),
                          child: material.Transform.scale(
                            scale: 1.0 - (slideValue * 0.15),
                            child: material.ClipRRect(
                              borderRadius: material.BorderRadius.circular(slideValue * 20),
                              child: material.Scaffold(
                                extendBody: false,
                                appBar: material.PreferredSize(
                                  preferredSize: material.Size.fromHeight(appBarHeight),
                                  child: material.AppBar(
                                    elevation: 0,
                                    title: Obx(() => material.Text(
                                          appController.pageTitles[appController.selectedIndex.value].tr,
                                          style: material.TextStyle(
                                            fontSize: height * 0.024 * scaleFactor,
                                            color: material.Colors.white,
                                            fontWeight: material.FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          textScaler: material.TextScaler.linear(textScaleFactor),
                                        )),
                                    leading: material.IconButton(
                                      icon: material.Icon(
                                        material.Icons.menu,
                                        size: height * 0.028 * scaleFactor,
                                        color: material.Colors.white,
                                      ),
                                      onPressed: drawerController.toggleDrawer,
                                    ),
                                    actions: [
                                      material.SizedBox(width: 6 * scaleFactor),
                                    ],
                                    flexibleSpace: material.Container(
                                      decoration: material.BoxDecoration(
                                        gradient: material.LinearGradient(
                                          colors: [
                                            material.Theme.of(context).colorScheme.primary,
                                            material.Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                          ],
                                          begin: material.Alignment.topLeft,
                                          end: material.Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                body: material.Container(
                                  color: backgroundColor,
                                  child: Obx(() => material.IndexedStack(
                                        index: appController.selectedIndex.value,
                                        children: appController.pageFactories.asMap().entries.map((entry) {
                                          final factory = entry.value;
                                          return material.SizedBox(
                                            height: size.height -
                                                appBarHeight -
                                                bottomBarHeight -
                                                material.MediaQuery.of(context).padding.top,
                                            child: factory(),
                                          );
                                        }).toList(),
                                      )),
                                ),
                                bottomNavigationBar: Obx(() => material.Container(
                                      height: bottomBarHeight,
                                      decoration: material.BoxDecoration(
                                        color: cardColor,
                                        boxShadow: [
                                          material.BoxShadow(
                                            color: material.Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const material.Offset(0, -4),
                                          ),
                                        ],
                                      ),
                                      child: material.BottomNavigationBar(
                                        items: [
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.agriculture,
                                                size: height * 0.028 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.agriculture,
                                              size: height * 0.028 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'cropTips'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.cloud,
                                                size: height * 0.028 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.cloud,
                                              size: height * 0.028 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'weather'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.store,
                                                size: height * 0.028 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.store,
                                              size: height * 0.028 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'market'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: Obx(() => material.Stack(
                                                  clipBehavior: material.Clip.none,
                                                  children: [
                                                    material.Icon(
                                                        material.Icons.chat,
                                                        size: height * 0.028 * scaleFactor),
                                                    if (chatController.totalUnseenMessageCount > 0)
                                                      material.Positioned(
                                                        right: -5 * scaleFactor,
                                                        top: -5 * scaleFactor,
                                                        child: material.Container(
                                                          padding: material.EdgeInsets.all(3 * scaleFactor),
                                                          decoration: material.BoxDecoration(
                                                            color: AppConstants.primaryColor,
                                                            shape: material.BoxShape.circle,
                                                          ),
                                                          child: material.Text(
                                                            chatController.totalUnseenMessageCount > 99
                                                                ? '99+'
                                                                : chatController.totalUnseenMessageCount.toString(),
                                                            style: material.TextStyle(
                                                              color: material.Colors.white,
                                                              fontSize: height * 0.012 * scaleFactor,
                                                              fontWeight: material.FontWeight.bold,
                                                            ),
                                                            textScaler: material.TextScaler.linear(textScaleFactor),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                )),
                                            activeIcon: Obx(() => material.Stack(
                                                  clipBehavior: material.Clip.none,
                                                  children: [
                                                    material.Icon(
                                                      material.Icons.chat,
                                                      size: height * 0.028 * scaleFactor,
                                                      color: material.Theme.of(context).colorScheme.primary,
                                                    ),
                                                    if (chatController.totalUnseenMessageCount > 0)
                                                      material.Positioned(
                                                        right: -5 * scaleFactor,
                                                        top: -5 * scaleFactor,
                                                        child: material.Container(
                                                          padding: material.EdgeInsets.all(3 * scaleFactor),
                                                          decoration: material.BoxDecoration(
                                                            color: AppConstants.primaryColor,
                                                            shape: material.BoxShape.circle,
                                                          ),
                                                          child: material.Text(
                                                            chatController.totalUnseenMessageCount > 99
                                                                ? '99+'
                                                                : chatController.totalUnseenMessageCount.toString(),
                                                            style: material.TextStyle(
                                                              color: material.Colors.white,
                                                              fontSize: height * 0.012 * scaleFactor,
                                                              fontWeight: material.FontWeight.bold,
                                                            ),
                                                            textScaler: material.TextScaler.linear(textScaleFactor),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                )),
                                            label: 'chat'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.settings,
                                                size: height * 0.028 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.settings,
                                              size: height * 0.028 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'settings'.tr,
                                          ),
                                        ],
                                        currentIndex: appController.selectedIndex.value,
                                        selectedItemColor: material.Theme.of(context).colorScheme.primary,
                                        unselectedItemColor: material.Theme.of(context)
                                            .bottomNavigationBarTheme
                                            .unselectedItemColor
                                            ?.withOpacity(0.6),
                                        onTap: appController.changePage,
                                        type: material.BottomNavigationBarType.fixed,
                                        backgroundColor: material.Colors.transparent,
                                        elevation: 0,
                                        selectedLabelStyle: material.TextStyle(
                                          fontSize: height * 0.016 * scaleFactor,
                                          fontWeight: material.FontWeight.w600,
                                        ),
                                        unselectedLabelStyle: material.TextStyle(
                                          fontSize: height * 0.014 * scaleFactor,
                                          fontWeight: material.FontWeight.w400,
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (slideValue > 0)
                        material.Positioned.fill(
                          child: material.Container(
                            color: material.Colors.black.withOpacity(0.3 * slideValue),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            // Drawer
            material.AnimatedBuilder(
              animation: drawerController.animationController,
              builder: (context, child) {
                final slideValue = drawerController.animationController.value;
                return material.Transform.translate(
                  offset: material.Offset(slideValue * 280 - 280, 0),
                  child: child,
                );
              },
              child: _ProfessionalDrawer(
                appController: appController,
                authController: authController,
                chatController: chatController,
                drawerController: drawerController,
                height: height,
                scaleFactor: scaleFactor,
                textScaleFactor: textScaleFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double slideTransform(double slideValue) {
    return slideValue;
  }
}

class _ProfessionalDrawer extends material.StatelessWidget {
  final AppController appController;
  final AuthController authController;
  final ChatController chatController;
  final AppDrawerController drawerController;
  final double height;
  final double scaleFactor;
  final double textScaleFactor;

  const _ProfessionalDrawer({
    required this.appController,
    required this.authController,
    required this.chatController,
    required this.drawerController,
    required this.height,
    required this.scaleFactor,
    required this.textScaleFactor,
  });

  void _showLogoutConfirmationDialog(material.BuildContext context) {
    Get.dialog(
      material.AlertDialog(
        backgroundColor: material.Theme.of(context).colorScheme.surface,
        shape: material.RoundedRectangleBorder(
          borderRadius: material.BorderRadius.circular(12 * scaleFactor),
        ),
        title: material.Text(
          'logout'.tr,
          style: material.TextStyle(
            fontSize: 16 * scaleFactor,
            fontWeight: material.FontWeight.w600,
          ),
          textScaler: material.TextScaler.linear(textScaleFactor),
        ),
        content: material.Text(
          'are_you_sure_logout'.tr,
          style: material.TextStyle(
            color: material.Colors.black87,
            fontSize: 14 * scaleFactor,
          ),
          textScaler: material.TextScaler.linear(textScaleFactor),
        ),
        actions: [
          material.TextButton(
            onPressed: () => Get.back(),
            child: material.Text(
              'no'.tr,
              textScaler: material.TextScaler.linear(textScaleFactor),
            ),
          ),
          material.TextButton(
            onPressed: () {
              Get.back();
              drawerController.toggleDrawer();
              authController.logout();
            },
            style: material.TextButton.styleFrom(
              foregroundColor: material.Theme.of(context).colorScheme.error,
            ),
            child: material.Text(
              'yes'.tr,
              textScaler: material.TextScaler.linear(textScaleFactor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);
    final isDarkMode = theme.brightness == material.Brightness.dark;
    return material.Container(
      width: 280,
      decoration: material.BoxDecoration(
        color: isDarkMode
            ? const material.Color(0xFF1A252F)
            : theme.drawerTheme.backgroundColor ?? material.Colors.white,
        borderRadius: const material.BorderRadius.horizontal(right: material.Radius.circular(16)),
        boxShadow: [
          material.BoxShadow(
            color: material.Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const material.Offset(2, 0),
          ),
        ],
      ),
      child: material.Column(
        children: [
          material.Container(
            height: height * 0.18 * scaleFactor,
            padding: material.EdgeInsets.all(16 * scaleFactor),
            decoration: material.BoxDecoration(
              color: material.Theme.of(context).colorScheme.primary,
            ),
            child: material.SafeArea(
              top: true,
              child: material.Stack(
                children: [
                  material.Positioned.fill(
                    child: material.Row(
                      crossAxisAlignment: material.CrossAxisAlignment.center,
                      children: [
                        material.Container(
                          decoration: material.BoxDecoration(
                            shape: material.BoxShape.circle,
                            color: material.Colors.white.withOpacity(0.2),
                          ),
                          padding: material.EdgeInsets.all(8 * scaleFactor),
                          child: material.Icon(
                            material.Icons.agriculture,
                            size: 40 * scaleFactor,
                            color: material.Colors.white,
                          ),
                        ),
                        material.SizedBox(width: 12 * scaleFactor),
                        material.Flexible(
                          child: material.Column(
                            crossAxisAlignment: material.CrossAxisAlignment.start,
                            mainAxisAlignment: material.MainAxisAlignment.center,
                            children: [
                              material.Text(
                                'Agri App'.tr,
                                style: material.TextStyle(
                                  color: material.Colors.white,
                                  fontSize: 18 * scaleFactor,
                                  fontWeight: material.FontWeight.bold,
                                ),
                                textScaler: material.TextScaler.linear(textScaleFactor),
                              ),
                              material.SizedBox(height: 4 * scaleFactor),
                              Obx(() => material.Text(
                                    authController.userName.value.isNotEmpty
                                        ? '${'Hello'.tr}, ${authController.userName.value}'
                                        : 'Welcome'.tr,
                                    style: material.TextStyle(
                                      color: material.Colors.white70,
                                      fontSize: 14 * scaleFactor,
                                    ),
                                    textScaler: material.TextScaler.linear(textScaleFactor),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  material.Positioned(
                    top: 0,
                    right: 0,
                    child: material.IconButton(
                      icon: material.Icon(
                        material.Icons.close_rounded,
                        size: 28 * scaleFactor,
                        color: material.Colors.white,
                      ),
                      onPressed: drawerController.toggleDrawer,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(
            effects: [
              FadeEffect(duration: 600.ms),
              ScaleEffect(
                begin: const material.Offset(0.9, 0.9),
                end: const material.Offset(1.0, 1.0),
                duration: 600.ms,
              ),
            ],
          ),
          material.Expanded(
            child: Obx(() => material.ListView(
                  padding: material.EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                  children: [
                    material.Padding(
                      padding: material.EdgeInsets.symmetric(
                        horizontal: 16 * scaleFactor,
                        vertical: 8 * scaleFactor,
                      ),
                      child: material.Text(
                        'Navigation'.tr,
                        style: material.TextStyle(
                          color: isDarkMode
                              ? material.Colors.white70
                              : material.Theme.of(context).textTheme.bodySmall!.color?.withOpacity(0.6),
                          fontSize: 14 * scaleFactor,
                          fontWeight: material.FontWeight.w600,
                        ),
                        textScaler: material.TextScaler.linear(textScaleFactor),
                      ),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.agriculture_outlined,
                      title: 'Crop Tips'.tr,
                      isSelected: appController.selectedIndex.value == 0,
                      onTap: () {
                        appController.changePage(0);
                        drawerController.toggleDrawer();
                      },
                      index: 0,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.cloud_outlined,
                      title: 'weather'.tr,
                      isSelected: appController.selectedIndex.value == 1,
                      onTap: () {
                        appController.changePage(1);
                        drawerController.toggleDrawer();
                      },
                      index: 1,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.store_outlined,
                      title: 'Market'.tr,
                      isSelected: appController.selectedIndex.value == 2,
                      onTap: () {
                        appController.changePage(2);
                        drawerController.toggleDrawer();
                      },
                      index: 2,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.chat_outlined,
                      title: 'chat'.tr,
                      isSelected: appController.selectedIndex.value == 3,
                      onTap: () {
                        appController.changePage(3);
                        drawerController.toggleDrawer();
                      },
                      index: 3,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.settings_outlined,
                      title: 'settings'.tr,
                      isSelected: appController.selectedIndex.value == 4,
                      onTap: () {
                        appController.changePage(4);
                        drawerController.toggleDrawer();
                      },
                      index: 4,
                    ),
                    material.Padding(
                      padding: material.EdgeInsets.symmetric(
                        horizontal: 16 * scaleFactor,
                        vertical: 8 * scaleFactor,
                      ),
                      child: material.Text(
                        'Preferences'.tr,
                        style: material.TextStyle(
                          color: isDarkMode
                              ? material.Colors.white70
                              : material.Theme.of(context).textTheme.bodySmall!.color?.withOpacity(0.6),
                          fontSize: 14 * scaleFactor,
                          fontWeight: material.FontWeight.w600,
                        ),
                        textScaler: material.TextScaler.linear(textScaleFactor),
                      ),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: appController.themeController.isDarkMode.value
                          ? material.Icons.light_mode_outlined
                          : material.Icons.dark_mode_outlined,
                      title: appController.themeController.isDarkMode.value
                          ? 'Light Mode'.tr
                          : 'Dark Mode'.tr,
                      isSelected: false,
                      onTap: appController.toggleTheme,
                      index: 5,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.language_outlined,
                      title: 'Toggle Language'.tr,
                      isSelected: false,
                      onTap: appController.toggleLanguage,
                      index: 6,
                    ),
                    material.Padding(
                      padding: material.EdgeInsets.symmetric(
                        horizontal: 16 * scaleFactor,
                        vertical: 8 * scaleFactor,
                      ),
                      child: material.Text(
                        'Account'.tr,
                        style: material.TextStyle(
                          color: isDarkMode
                              ? material.Colors.white70
                              : material.Theme.of(context).textTheme.bodySmall!.color?.withOpacity(0.6),
                          fontSize: 14 * scaleFactor,
                          fontWeight: material.FontWeight.w600,
                        ),
                        textScaler: material.TextScaler.linear(textScaleFactor),
                      ),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.logout_outlined,
                      title: 'logout'.tr,
                      isSelected: false,
                      onTap: () => _showLogoutConfirmationDialog(context),
                      index: 7,
                    ),
                  ],
                )),
          ),
          material.Container(
            padding: material.EdgeInsets.all(16 * scaleFactor),
            child: material.Text(
              'Version 1.0.0'.tr,
              style: material.TextStyle(
                color: isDarkMode
                    ? material.Colors.white60
                    : material.Theme.of(context).textTheme.bodySmall!.color?.withOpacity(0.5),
                fontSize: 12 * scaleFactor,
              ),
              textScaler: material.TextScaler.linear(textScaleFactor),
            ),
          ),
        ],
      ),
    );
  }

  material.Widget _buildDrawerItem({
    required material.BuildContext context,
    required material.IconData icon,
    required String title,
    required bool isSelected,
    required material.VoidCallback onTap,
    required int index,
  }) {
    final theme = material.Theme.of(context);
    return material.Padding(
      padding: material.EdgeInsets.symmetric(
        horizontal: 8 * scaleFactor,
        vertical: 2 * scaleFactor,
      ),
      child: material.AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: material.Curves.easeInOut,
        decoration: material.BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : material.Colors.transparent,
          borderRadius: material.BorderRadius.circular(12 * scaleFactor),
        ),
        child: material.ListTile(
          leading: material.Icon(
            icon,
            size: 24 * scaleFactor,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.iconTheme.color?.withOpacity(0.7),
          ),
          title: material.Text(
            title,
            style: material.TextStyle(
              fontSize: 16 * scaleFactor,
              fontWeight: isSelected ? material.FontWeight.w600 : material.FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium!.color,
            ),
            textScaler: material.TextScaler.linear(textScaleFactor),
          ),
          onTap: onTap,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(12 * scaleFactor),
          ),
          tileColor: material.Colors.transparent,
          hoverColor: theme.colorScheme.primary.withOpacity(0.05),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          contentPadding: material.EdgeInsets.symmetric(
            horizontal: 16 * scaleFactor,
            vertical: 4 * scaleFactor,
          ),
        ),
      ),
    ).animate(
      delay: (100 * index).ms,
      effects: [
        SlideEffect(
          begin: const material.Offset(-0.5, 0),
          end: const material.Offset(0, 0),
          duration: 500.ms,
          curve: material.Curves.easeOutCubic,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
        ),
      ],
    );
  }
}