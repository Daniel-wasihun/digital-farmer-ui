import 'package:get/get.dart';
import '../views/screens/signin_screen.dart';
import '../views/screens/signup_screen.dart';
import '../views/screens/home_screen.dart';
import '../services/storage_service.dart';

class AppRoutes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';

  static String getSignInPage() => signin; // Returns "/signin"
  static String getSignUpPage() => signup; // Returns "/signup"
  static String getHomePage() => home;      // Returns "/home"

  static String getInitialRoute() {
    final storageService = Get.find<StorageService>();
    final isLoggedIn = storageService.getToken() != null;
    return isLoggedIn ? home : signin;
  }

  static List<GetPage> routes = [
    GetPage(name: signin, page: () => SignInScreen()),
    GetPage(name: signup, page: () => SignUpScreen()),
    GetPage(name: home, page: () => HomeScreen()),
  ];
}