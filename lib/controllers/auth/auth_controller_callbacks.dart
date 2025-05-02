import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef SetLoadingCallback = void Function(bool value);
typedef ShowSnackbarCallback = void Function(
  String title,
  String message, {
  Color? backgroundColor,
  Color? colorText,
  SnackPosition? snackPosition,
  double? borderRadius,
  EdgeInsets? margin,
});
typedef NavigateToCallback = Future<dynamic>? Function(
  String pageName, {
  dynamic arguments,
  int? id,
  bool preventDuplicates,
  Map<String, String>? parameters,
});
typedef NavigateOffAllCallback = Future<dynamic>? Function(
  String pageName, {
  dynamic arguments,
  int? id,
  Map<String, String>? parameters,
});
typedef ResetPasswordErrorsCallback = void Function();
typedef UpdatePasswordChangeSuccessCallback = void Function(bool value);
typedef SetCurrentPasswordErrorCallback = void Function(String value);
typedef SetSecurityAnswerErrorCallback = void Function(String value);

class AuthControllerCallbacks {
  final SetLoadingCallback setIsLoading;
  final ShowSnackbarCallback showSnackbar;
  final NavigateToCallback navigateTo;
  final NavigateOffAllCallback navigateOffAll;
  final ResetPasswordErrorsCallback resetPasswordErrors;
  final UpdatePasswordChangeSuccessCallback updatePasswordChangeSuccess;
  final SetCurrentPasswordErrorCallback setCurrentPasswordError;
  final SetSecurityAnswerErrorCallback setSecurityAnswerError;
  bool _setCurrentPasswordErrorCalled = false;

  AuthControllerCallbacks({
    required this.setIsLoading,
    required this.showSnackbar,
    required this.navigateTo,
    required this.navigateOffAll,
    required this.resetPasswordErrors,
    required this.updatePasswordChangeSuccess,
    required this.setCurrentPasswordError,
    required this.setSecurityAnswerError,
  });

  bool get setCurrentPasswordErrorCalled => _setCurrentPasswordErrorCalled;

  void updateCurrentPasswordError(String value) {
    _setCurrentPasswordErrorCalled = true;
    setCurrentPasswordError(value);
  }

  void resetCallbackState() {
    _setCurrentPasswordErrorCalled = false;
  }
}