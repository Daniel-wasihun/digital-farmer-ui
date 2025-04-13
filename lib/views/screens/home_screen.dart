import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppController controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        title: Obx(() => Text(
              controller.pageTitles[controller.selectedIndex.value].tr,
              style: TextStyle(
                fontSize: height * 0.03 * scaleFactor,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: height * 0.035 * scaleFactor,
            color: Colors.white,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Obx(() => Row(
                children: [
                  IconButton(
                    icon: Icon(
                      controller.themeController.isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: height * 0.035 * scaleFactor,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.toggleTheme(),
                    tooltip: controller.themeController.isDarkMode.value
                        ? 'switch_to_light_mode'.tr
                        : 'switch_to_dark_mode'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8 * scaleFactor),
                    child: Text(
                      Get.locale?.languageCode == 'am' ? 'አማ' : 'En',
                      style: TextStyle(
                        fontSize: height * 0.025 * scaleFactor,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.language,
                      size: height * 0.035 * scaleFactor,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.toggleLanguage(),
                    tooltip: 'toggle_language'.tr,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: height * 0.035 * scaleFactor,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.logout(),
                    tooltip: 'logout'.tr,
                  ),
                  SizedBox(width: 8 * scaleFactor),
                ],
              )),
        ],
      ),
      drawer: Drawer(
        width: 150,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * 0.035 * scaleFactor,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                size: height * 0.03 * scaleFactor,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Home'.tr,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: height * 0.02 * scaleFactor,
                    ),
              ),
              onTap: () {
                controller.changePage(0);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.brightness_4,
                size: height * 0.03 * scaleFactor,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Obx(() => Text(
                    controller.themeController.isDarkMode.value
                        ? 'Light Mode'.tr
                        : 'Dark Mode'.tr,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: height * 0.02 * scaleFactor,
                        ),
                  )),
              onTap: () {
                controller.toggleTheme();
                Get.back();
              },
            ),
          ],
        ),
      ),
      body: Obx(() => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : width * 0.9,
              ),
              child: controller.currentPage.value,
            ),
          )),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture, size: height * 0.03 * scaleFactor),
              label: 'cropTips'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud, size: height * 0.03 * scaleFactor),
              label: 'weather'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store, size: height * 0.03 * scaleFactor),
              label: 'market'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: height * 0.03 * scaleFactor),
              label: 'chat'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: height * 0.03 * scaleFactor),
              label: 'settings'.tr,
            ),
          ],
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontSize: height * 0.018 * scaleFactor),
          unselectedLabelStyle: TextStyle(fontSize: height * 0.016 * scaleFactor),
        ),
      ),
    );
  }
}