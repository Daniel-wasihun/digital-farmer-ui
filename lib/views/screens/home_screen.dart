import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../services/storage_service.dart';
import '../widgets/glassmorphic_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final StorageService storageService = Get.find<StorageService>();
  final RxInt _currentIndex = 0.obs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeTabIndex();
  }

  void _initializeTabIndex() {
    try {
      final savedIndex = storageService.getTabIndex();
      if (savedIndex >= 0 && savedIndex < _tabData.length) {
        _currentIndex.value = savedIndex;
      } else {
        _currentIndex.value = 0;
        storageService.saveTabIndex(0);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tab index: $e',
          backgroundColor: Colors.red.shade300);
      _currentIndex.value = 0;
    }
  }

  final List<Map<String, dynamic>> _tabData = [
    {
      'key': 'cropTips',
      'content': const CropTipsTab(),
    },
    {
      'key': 'weather',
      'content': const WeatherTab(),
    },
    {
      'key': 'market',
      'content': const MarketTab(),
    },
    {
      'key': 'chat',
      'content': const ChatTab(),
    },
    {
      'key': 'settings',
      'content': const SettingsTab(),
    },
  ];

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
              _tabData[_currentIndex.value]['key'].toString().tr,
              style: TextStyle(
                fontSize: height * 0.03 * scaleFactor,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )),
        leading: IconButton(
          icon: Icon(Icons.menu, size: height * 0.035 * scaleFactor, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, size: height * 0.035 * scaleFactor, color: Colors.white),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
          IconButton(
            icon: Icon(Icons.logout, size: height * 0.035 * scaleFactor, color: Colors.white),
            onPressed: () {
              try {
                authController.logout();
              } catch (e) {
                Get.snackbar('Error', 'Logout failed: $e',
                    backgroundColor: Colors.red.shade300);
              }
            },
            tooltip: 'logout'.tr,
          ),
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
              leading: Icon(Icons.home, size: height * 0.03 * scaleFactor),
              title: Text(
                'Home'.tr,
                style: TextStyle(fontSize: height * 0.02 * scaleFactor),
              ),
              onTap: () {
                _currentIndex.value = 0;
                storageService.saveTabIndex(0);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.brightness_4, size: height * 0.03 * scaleFactor),
              title: Obx(() => Text(
                    themeController.isDarkMode.value
                        ? 'Light Mode'.tr
                        : 'Dark Mode'.tr,
                    style: TextStyle(fontSize: height * 0.02 * scaleFactor),
                  )),
              onTap: () {
                themeController.toggleTheme();
                Get.back();
              },
            ),
          ],
        ),
      ),
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: ConstrainedBox(
            key: ValueKey<int>(_currentIndex.value),
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : width * 0.9,
            ),
            child: Center(
              child: _tabData[_currentIndex.value]['content'] as Widget,
            ),
          ),
        ),
      ),
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
          currentIndex: _currentIndex.value,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index >= 0 && index < _tabData.length) {
              _currentIndex.value = index;
              try {
                storageService.saveTabIndex(index);
              } catch (e) {
                Get.snackbar('Error', 'Failed to save tab index: $e',
                    backgroundColor: Colors.red.shade300);
              }
            }
          },
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

// Tab widgets for modularity
class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;

    return GlassmorphicCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'cropTips'.tr,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 40,
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14 * scaleFactor,
                  ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                hintText: 'Search crops...'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    return GlassmorphicCard(
      child: Text(
        'weather'.tr,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    return GlassmorphicCard(
      child: Text(
        'market'.tr,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    return GlassmorphicCard(
      child: Text(
        'chat'.tr,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    return GlassmorphicCard(
      child: Text(
        'settings'.tr,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 20 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}