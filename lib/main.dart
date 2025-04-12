import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'utils/translations.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize services and controllers
  final storageService = StorageService();
  Get.put(storageService); // Singleton instance
  Get.put(AuthController()); // Depends on StorageService implicitly

  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'auth_app'.tr,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.getInitialRoute(),
      getPages: AppRoutes.routes,
    );
  }
}