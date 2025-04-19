import 'package:get/get.dart';
import '../controllers/update_profile_controller.dart';
import '../services/storage_service.dart';
import '../views/screens/Tabs/settings/settings_tab.dart';
import '../views/screens/auth/request_password_reset_screen.dart';
import '../views/screens/auth/reset_password_screen.dart';
import '../views/screens/auth/security_question_verification_screen.dart';
import '../views/screens/auth/signin_screen.dart';
import '../views/screens/auth/signup_screen.dart';
import '../views/screens/auth/verify_otp_screen.dart';
import '../views/screens/tabs/chat/chat_screen.dart';
import '../views/screens/tabs/settings/change_password_screen.dart';
import '../views/screens/tabs/settings/contact_us_screen.dart';
import '../views/screens/tabs/settings/faq_screen.dart';
import '../views/screens/tabs/settings/feedback_screen.dart';
import '../views/screens/tabs/settings/security_question_screen.dart';
import '../views/screens/tabs/settings/update_profile_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/tabs/chat/user_profile_screen.dart';

class AppRoutes {
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String updateProfile = '/update-profile';
  static const String securityQuestion = '/security-question';
  static const String faq = '/faq';
  static const String contactUs = '/contact-us';
  static const String feedback = '/feedback';
  static const String chat = '/chat';
  static const String userProfile = '/user-profile';
  static const String verifyOTP = '/verify-otp';
  static const String requestPasswordReset = '/request-password-reset';
  static const String resetPassword = '/reset-password';
  static const String securityQuestionVerificationPage = '/security-question-verification';

  static String getSignInPage() => signin;
  static String getSignUpPage() => signup;
  static String getHomePage() => home;
  static String getSettingsPage() => settings;
  static String getChangePasswordPage() => changePassword;
  static String getUpdateProfilePage() => updateProfile;
  static String getSecurityQuestionPage() => securityQuestion;
  static String getFaqPage() => faq;
  static String getContactUsPage() => contactUs;
  static String getFeedbackPage() => feedback;
  static String getChatPage(String receiverId, String receiverUsername) =>
      '$chat?receiverId=$receiverId&receiverUsername=$receiverUsername';
  static String getUserProfilePage(String email, String username) =>
      '$userProfile?email=$email&username=$username';
  static String getVerifyOTPPage() => verifyOTP;
  static String getRequestPasswordResetPage() => requestPasswordReset;
  static String getResetPasswordPage() => resetPassword;
  static String getSecurityQuestionVerificationPage() =>securityQuestionVerificationPage;

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
      name: settings,
      page: () => const SettingsTab(),
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
    name: '/security-question-verification',
    page: () => const SecurityQuestionVerificationScreen(),
  ),
    GetPage(
      name: updateProfile,
      page: () => const UpdateProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(UpdateProfileController());
      }),
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
    GetPage(
      name: chat,
      page: () => ChatScreen(
        receiverId: Get.parameters['receiverId']!,
        receiverUsername: Get.parameters['receiverUsername']!,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: userProfile,
      page: () => const UserProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: verifyOTP,
      page: () => const VerifyOTPScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: requestPasswordReset,
      page: () => const RequestPasswordResetScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}