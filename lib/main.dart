import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/app_controller.dart';
import 'utils/translations.dart';
import 'routes/app_routes.dart';
import 'controllers/theme_controller.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage with simpler error handling
  try {
    await GetStorage.init('AppContainer');
    print('Main: GetStorage initialized successfully with container AppContainer');
  } catch (e) {
    print('Main: GetStorage init failed: $e');
    try {
      await GetStorage('AppContainer').erase();
      await GetStorage.init('AppContainer');
      print('Main: GetStorage cleared and reinitialized');
    } catch (eraseError) {
      print('Main: Failed to clear and reinitialize GetStorage: $eraseError');
    }
  }

  // Initialize services and controllers
  try {
    Get.put(StorageService());
    Get.put(ApiService());
    Get.put(AuthController());
    Get.put(ThemeController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.put(AppController());
    print('Main: All services and controllers initialized');
  } catch (e) {
    print('Main: Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    // Use GetBuilder to avoid early Obx reactivity
    return GetBuilder<ThemeController>(
      builder: (controller) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'auth_app'.tr,
        translations: AppTranslations(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppRoutes.getInitialRoute(),
        getPages: AppRoutes.routes,
        theme: controller.getTheme(),
      ),
    );
  }
}