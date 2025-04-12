import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import 'package:animated_background/animated_background.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final StorageService storageService = Get.find<StorageService>();
  var _currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    // Load persisted tab index
    _currentIndex.value = storageService.getTabIndex();
  }

  // List of tab contents
  final List<Widget> _tabs = [
    Center(child: Text('home'.tr, style: const TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('profile'.tr, style: const TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('messages'.tr, style: const TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('notifications'.tr, style: const TextStyle(fontSize: 24, color: Colors.white))),
    Center(child: Text('settings'.tr, style: const TextStyle(fontSize: 24, color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('app_title'.tr, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authController.logout(),
            tooltip: 'logout'.tr,
          ),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            baseColor: Colors.teal,
            spawnMinSpeed: 10.0,
            spawnMaxSpeed: 50.0,
            particleCount: 50,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.blueAccent.withOpacity(0.7), Colors.teal.withOpacity(0.9)],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
          child: Obx(() => _tabs[_currentIndex.value]),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _currentIndex.value,
          onTap: (index) {
            _currentIndex.value = index;
            storageService.saveTabIndex(index); // Persist tab index
          },
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.black.withOpacity(0.8),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.message),
              label: 'messages'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications),
              label: 'notifications'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}