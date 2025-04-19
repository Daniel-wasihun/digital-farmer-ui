import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth/auth_controller.dart';
import 'controllers/app_controller.dart';
import 'controllers/chat/chat_controller.dart';
import 'controllers/feedback_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/api/auth_api.dart';
import 'services/api/feedback_api.dart';
import 'services/api/message_api.dart';
import 'services/api/user_api.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'utils/translations.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('AppContainer').catchError((e) async {
    await GetStorage('AppContainer').erase();
    await GetStorage.init('AppContainer');
  });
  Get.put(StorageService());
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        // Services
        Get.put(ApiService());
        Get.put(AuthApi());
        Get.put(FeedbackApi());
        Get.put(MessageApi());
        Get.put(UserApi());

        // Controllers
        Get.put(AuthController());
        Get.put(AppController());
        Get.lazyPut<ChatController>(() => ChatController());
        Get.put(FeedbackController());
      }),
      debugShowCheckedModeBanner: false,
      title: 'auth_app'.tr,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppRoutes.getInitialRoute(),
      getPages: AppRoutes.routes,
      theme: Get.find<ThemeController>().getTheme(),
      darkTheme: Get.find<ThemeController>().getDarkTheme(),
      themeMode: Get.find<ThemeController>().isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}