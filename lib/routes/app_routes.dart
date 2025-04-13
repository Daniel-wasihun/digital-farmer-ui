import 'package:get/get.dart';
import '../views/screens/Tabs/settings/change_password_screen.dart';
import '../views/screens/Tabs/settings/contact_us_screen.dart';
import '../views/screens/Tabs/settings/faq_screen.dart';
import '../views/screens/Tabs/settings/feedback_screen.dart';
import '../views/screens/Tabs/settings/security_question_screen.dart';
import '../views/screens/Tabs/settings/update_profile_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/signin_screen.dart';
import '../views/screens/signup_screen.dart';
import '../services/storage_service.dart';
class AppRoutes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String changePassword = '/change-password';
  static const String updateProfile = '/update-profile';
  static const String securityQuestion = '/security-question';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String feedback = '/feedback';

  static String getSignInPage() => signin;
  static String getSignUpPage() => signup;
  static String getHomePage() => home;
  static String getChangePasswordPage() => changePassword;
  static String getUpdateProfilePage() => updateProfile;
  static String getSecurityQuestionPage() => securityQuestion;
  static String getFaqPage() => faq;
  static String getContactUsPage() => contactUs;
  static String getFeedbackPage() => feedback;

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
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: updateProfile,
      page: () => const UpdateProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: securityQuestion,
      page: () => const SecurityQuestionScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: faq,
      page: () => const FaqScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: contactUs,
      page: () => const ContactUsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: feedback,
      page: () => const FeedbackScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}