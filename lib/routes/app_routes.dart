import 'package:get/get.dart';
import '../views/screens/signin_screen.dart';
import '../views/screens/signup_screen.dart';
import '../views/screens/home_screen.dart';
import '../services/storage_service.dart';

class AppRoutes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';

  static String getSignInPage() => signin;
  static String getSignUpPage() => signup;
  static String getHomePage() => home;

  static String getInitialRoute() {
    final storageService = Get.find<StorageService>();
    final isLoggedIn = storageService.getToken() != null;
    return isLoggedIn ? home : signin;
  }

  static List<GetPage> routes = [
    GetPage(
      name: signin,
      page: () => const SignInScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: signup,
      page: () => const SignUpScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}