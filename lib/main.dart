import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth/auth_controller.dart';
import 'utils/translations.dart';
import 'routes/app_routes.dart';
import 'controllers/theme_controller.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize services and controllers
  final storageService = StorageService();
  Get.put(storageService);
  Get.put(ThemeController());
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'auth_app'.tr,
        translations: AppTranslations(),
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppRoutes.getInitialRoute(),
        getPages: AppRoutes.routes,
        theme: themeController.getTheme(),
      ),
    );
  }
}