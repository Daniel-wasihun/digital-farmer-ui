import 'package:get/get.dart';
import 'auth_controller.dart';

class SignInController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Reactive inputs
  var email = ''.obs;
  var password = ''.obs;

  @override
  void onInit() {
    super.onInit();
    reset();
    print('SignInController initialized, errors reset');
  }

  void reset() {
    email.value = '';
    password.value = '';
    authController.resetErrors();
  }

  void onEmailChanged(String value) {
    email.value = value;
    authController.validateEmail(value);
  }

  void onPasswordChanged(String value) {
    password.value = value;
    authController.validatePassword(value);
  }

  void signIn() {
    authController.signin(email.value, password.value);
  }
}