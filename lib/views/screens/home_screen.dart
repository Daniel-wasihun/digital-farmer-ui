import 'dart:io' show Platform;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart' as services;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/chat/chat_controller.dart';
import '../../controllers/market_controller.dart';
import '../../utils/constants.dart';

// Placeholder AppDrawerController with optimized animation duration
class AppDrawerController extends GetxController with SingleGetTickerProviderMixin {
  late material.AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    // Optimized animation duration: 200ms for smoother drawer open/close
    animationController = material.AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void toggleDrawer() {
    if (animationController.isDismissed) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class HomeScreen extends material.StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends material.State<HomeScreen> {
  void _setStatusBarColor() {
    if (Platform.isAndroid) {
      // Ensure status bar is set after frame rendering
      material.WidgetsBinding.instance.addPostFrameCallback((_) {
        services.SystemChrome.setSystemUIOverlayStyle(
          const services.SystemUiOverlayStyle(
            statusBarColor: material.Color(0xFF0A3D2A), // Always dark green
            statusBarIconBrightness: material.Brightness.light, // White icons
            statusBarBrightness: material.Brightness.dark, // Ensure dark background for iOS
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Set status bar color during initialization
    _setStatusBarColor();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply status bar color on theme or context changes
    _setStatusBarColor();
  }

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
    final width = size.width;
    final isTablet = width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final textScaleFactor = isTablet ? 1.0 : 0.85;
    final appBarHeight = (height * 0.06 * scaleFactor).clamp(48.0, 64.0);
    final bottomBarHeight = (height * 0.08 * scaleFactor).clamp(60.0, 80.0);
    final isDarkMode = material.Theme.of(context).brightness == material.Brightness.dark;
    final cardColor = isDarkMode ? const material.Color(0xFF1A252F) : material.Colors.white;
    final backgroundColor = isDarkMode ? const material.Color(0xFF263544) : material.Colors.grey[200]!;

    // Ensure status bar color is applied during build
    _setStatusBarColor();

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
                                    elevation: 4,
                                    shadowColor: material.Colors.black.withOpacity(0.3),
                                    title: Obx(() => material.Text(
                                          appController.pageTitles[appController.selectedIndex.value].tr,
                                          style: material.TextStyle(
                                            fontSize: 20 * scaleFactor,
                                            color: material.Colors.white,
                                            fontWeight: material.FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          textScaler: material.TextScaler.linear(textScaleFactor),
                                        )),
                                    leading: material.IconButton(
                                      icon: material.Icon(
                                        material.Icons.menu,
                                        size: 28 * scaleFactor,
                                        color: material.Colors.white,
                                      ),
                                      onPressed: drawerController.toggleDrawer,
                                    ),
                                    actions: [
                                      material.SizedBox(width: 8 * scaleFactor),
                                    ],
                                    flexibleSpace: material.Container(
                                      decoration: material.BoxDecoration(
                                        gradient: material.LinearGradient(
                                          colors: [
                                            material.Color(0xFF0A3D2A),
                                            material.Color(0xFF145C3F).withOpacity(0.8),
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
                                            height: size.height - appBarHeight - bottomBarHeight,
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
                                                size: 28 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.agriculture,
                                              size: 28 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'cropTips'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.cloud,
                                                size: 28 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.cloud,
                                              size: 28 * scaleFactor,
                                              color: material.Theme.of(context).colorScheme.primary,
                                            ),
                                            label: 'weather'.tr,
                                          ),
                                          material.BottomNavigationBarItem(
                                            icon: material.Icon(
                                                material.Icons.store,
                                                size: 28 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.store,
                                              size: 28 * scaleFactor,
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
                                                        size: 28 * scaleFactor),
                                                    if (chatController.totalUnseenMessageCount > 0)
                                                      material.Positioned(
                                                        right: -6 * scaleFactor,
                                                        top: -6 * scaleFactor,
                                                        child: material.Container(
                                                          padding: material.EdgeInsets.all(4 * scaleFactor),
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
                                                              fontSize: 12 * scaleFactor,
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
                                                      size: 28 * scaleFactor,
                                                      color: material.Theme.of(context).colorScheme.primary,
                                                    ),
                                                    if (chatController.totalUnseenMessageCount > 0)
                                                      material.Positioned(
                                                        right: -6 * scaleFactor,
                                                        top: -6 * scaleFactor,
                                                        child: material.Container(
                                                          padding: material.EdgeInsets.all(4 * scaleFactor),
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
                                                              fontSize: 12 * scaleFactor,
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
                                                size: 28 * scaleFactor),
                                            activeIcon: material.Icon(
                                              material.Icons.settings,
                                              size: 28 * scaleFactor,
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
                                        onTap: (index) {
                                          appController.changePage(index);
                                          _setStatusBarColor(); // Re-apply status bar on page change
                                        },
                                        type: material.BottomNavigationBarType.fixed,
                                        backgroundColor: material.Colors.transparent,
                                        elevation: 0,
                                        selectedLabelStyle: material.TextStyle(
                                          fontSize: 14 * scaleFactor,
                                          fontWeight: material.FontWeight.w600,
                                        ),
                                        unselectedLabelStyle: material.TextStyle(
                                          fontSize: 12 * scaleFactor,
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
            // Drawer with visibility control
            material.AnimatedBuilder(
              animation: drawerController.animationController,
              builder: (context, child) {
                final slideValue = drawerController.animationController.value;
                // Only render drawer when slideValue > 0 to ensure it's hidden when closed
                return slideValue > 0
                    ? material.Opacity(
                        opacity: slideValue,
                        child: material.Transform.translate(
                          offset: material.Offset(slideValue * 280 - 280, 0),
                          child: child,
                        ),
                      )
                    : const material.SizedBox.shrink();
              },
              child: _ProfessionalDrawer(
                appController: appController,
                authController: authController,
                chatController: chatController,
                drawerController: drawerController,
                height: height,
                width: width,
                scaleFactor: scaleFactor,
                textScaleFactor: textScaleFactor,
                setStatusBarColor: _setStatusBarColor,
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
  final double width;
  final double scaleFactor;
  final double textScaleFactor;
  final void Function() setStatusBarColor;

  const _ProfessionalDrawer({
    required this.appController,
    required this.authController,
    required this.chatController,
    required this.drawerController,
    required this.height,
    required this.width,
    required this.scaleFactor,
    required this.textScaleFactor,
    required this.setStatusBarColor,
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
              setStatusBarColor();
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
    final drawerWidth = width * 0.75;
    return material.Container(
      width: drawerWidth.clamp(280, 360),
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
            height: (height * 0.18 * scaleFactor).clamp(120, 160),
            padding: material.EdgeInsets.all(16 * scaleFactor),
            decoration: const material.BoxDecoration(
              color: material.Color(0xFF0A3D2A),
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
                          padding: material.EdgeInsets.all(8 * scaleFactor),
                          child: material.ClipOval(
                            child: material.Image.asset(
                              'assets/logo.png',
                              width: 80 * scaleFactor,
                              height: 80 * scaleFactor,
                              fit: material.BoxFit.cover,
                            ),
                          ),
                        ),
                        material.SizedBox(width: 12 * scaleFactor),
                        material.Flexible(
                          child: material.Column(
                            crossAxisAlignment: material.CrossAxisAlignment.start,
                            mainAxisAlignment: material.MainAxisAlignment.center,
                            children: [
                              material.Text(
                                'Digital Farmers',
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
              FadeEffect(duration: 200.ms),
              ScaleEffect(
                begin: const material.Offset(0.95, 0.95),
                end: const material.Offset(1.0, 1.0),
                duration: 200.ms,
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
                        setStatusBarColor();
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
                        setStatusBarColor();
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
                        setStatusBarColor();
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
                        setStatusBarColor();
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
                        setStatusBarColor();
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
                      onTap: () {
                        appController.toggleTheme();
                        setStatusBarColor();
                      },
                      index: 5,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: material.Icons.language_outlined,
                      title: 'Toggle Language'.tr,
                      isSelected: false,
                      onTap: () {
                        appController.toggleLanguage();
                        setStatusBarColor();
                      },
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
      delay: (index * 50).ms,
      effects: [
        SlideEffect(
          begin: const material.Offset(-0.2, 0),
          end: const material.Offset(0, 0),
          duration: 200.ms,
          curve: material.Curves.easeOutQuad,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 200.ms,
        ),
      ],
    );
  }
}