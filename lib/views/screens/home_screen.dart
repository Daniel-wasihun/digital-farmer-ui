import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/chat/chat_controller.dart'; // Added for ChatController
import '../../utils/constants.dart'; // Added for AppConstants.primaryColor

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppController controller = Get.find<AppController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;

    final appBarHeight = (height * 0.07 * scaleFactor).clamp(48.0, 64.0);

    // Access ChatController for badge count
    final ChatController chatController = Get.find<ChatController>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            elevation: 2,
            title: Obx(() => Text(
                  controller.pageTitles[controller.selectedIndex.value].tr,
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
              Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 6 * scaleFactor),
                        child: Text(
                          Get.locale?.languageCode == 'am' ? 'አማ' : 'En',
                          style: TextStyle(
                            fontSize: height * 0.018 * scaleFactor,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.language,
                          size: height * 0.028 * scaleFactor,
                          color: Colors.white,
                        ),
                        onPressed: () => controller.toggleLanguage(),
                        tooltip: 'toggle_language'.tr,
                      ),
                      IconButton(
                        icon: Icon(
                          controller.themeController.isDarkMode.value
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          size: height * 0.028 * scaleFactor,
                          color: Colors.white,
                        ),
                        onPressed: () => controller.toggleTheme(),
                        tooltip: controller.themeController.isDarkMode.value
                            ? 'switch_to_light_mode'.tr
                            : 'switch_to_dark_mode'.tr,
                      ),
                      SizedBox(width: 6 * scaleFactor),
                    ],
                  )),
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
          width: 160,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Menu'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: height * 0.032 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'App Name'.tr,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: height * 0.018 * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: 'Home'.tr,
                  onTap: () {
                    controller.changePage(0);
                    Get.back();
                  },
                  height: height,
                  scaleFactor: scaleFactor,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.brightness_4,
                  title: controller.themeController.isDarkMode.value
                      ? 'Light Mode'.tr
                      : 'Dark Mode'.tr,
                  onTap: () {
                    controller.toggleTheme();
                    Get.back();
                  },
                  height: height,
                  scaleFactor: scaleFactor,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'logout'.tr,
                  onTap: () {
                    controller.logout();
                    Get.back();
                  },
                  height: height,
                  scaleFactor: scaleFactor,
                ),
              ],
            ),
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
                index: controller.selectedIndex.value,
                children: controller.pageFactories.map((factory) => factory()).toList(),
              )),
        ),
        bottomNavigationBar: Obx(
          () => Container(
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
                  activeIcon: Icon(Icons.agriculture, size: height * 0.028 * scaleFactor, color: Theme.of(context).colorScheme.primary),
                  label: 'cropTips'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(Icons.cloud, size: height * 0.028 * scaleFactor, color: Theme.of(context).colorScheme.primary),
                  label: 'weather'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store, size: height * 0.028 * scaleFactor),
                  activeIcon: Icon(Icons.store, size: height * 0.028 * scaleFactor, color: Theme.of(context).colorScheme.primary),
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
                          Icon(Icons.chat, size: height * 0.028 * scaleFactor, color: Theme.of(context).colorScheme.primary),
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
                  activeIcon: Icon(Icons.settings, size: height * 0.028 * scaleFactor, color: Theme.of(context).colorScheme.primary),
                  label: 'settings'.tr,
                ),
              ],
              currentIndex: controller.selectedIndex.value,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor?.withOpacity(0.6),
              onTap: controller.changePage,
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
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double height,
    required double scaleFactor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: height * 0.015 * scaleFactor),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor.withOpacity(0.8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: height * 0.028 * scaleFactor,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: height * 0.018 * scaleFactor,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}