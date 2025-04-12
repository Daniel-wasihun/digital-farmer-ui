import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import 'dart:ui';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import '../widgets/glassmorphic_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final StorageService storageService = Get.find<StorageService>();
  final RxInt _currentIndex = 0.obs;

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
          backgroundColor: Colors.red.shade100);
      _currentIndex.value = 0;
    }
  }

  // Define tab data for content modularity
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
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final height = size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'app_title'.tr,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20 * scaleFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.grey.shade800, size: 24 * scaleFactor),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey.shade800, size: 24 * scaleFactor),
            onPressed: () {
              try {
                authController.logout();
              } catch (e) {
                Get.snackbar('Error', 'Logout failed: $e',
                    backgroundColor: Colors.red.shade100);
              }
            },
            tooltip: 'logout'.tr,
          ),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.blue.shade100,
            spawnMinSpeed: 6.0,
            spawnMaxSpeed: 30.0,
            particleCount: 50,
            spawnOpacity: 0.15,
            maxOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50.withOpacity(0.9),
                Colors.white.withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: ConstrainedBox(
                      key: ValueKey<int>(_currentIndex.value),
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : size.width * 0.9,
                      ),
                      child: Center(
                        child: _tabData[_currentIndex.value]['content'] as Widget,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex.value,
              onTap: (index) {
                if (index >= 0 && index < _tabData.length) {
                  _currentIndex.value = index;
                  try {
                    storageService.saveTabIndex(index);
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to save tab index: $e',
                        backgroundColor: Colors.red.shade100);
                  }
                }
              },
              selectedItemColor: Colors.blue.shade300,
              unselectedItemColor: Colors.grey.shade600,
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(fontSize: 12 * scaleFactor, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 12 * scaleFactor, fontWeight: FontWeight.w400),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.agriculture, size: height * 0.025),
                  label: 'cropTips'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud, size: height * 0.025),
                  label: 'weather'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store, size: height * 0.025),
                  label: 'market'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat, size: height * 0.025),
                  label: 'chat'.tr,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: height * 0.025),
                  label: 'settings'.tr,
                ),
              ],
            ),
          ),
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
    return GlassmorphicCard(
      child: Text(
        'cropTips'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Text(
        'weather'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Text(
        'market'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Text(
        'chat'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Text(
        'settings'.tr,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}