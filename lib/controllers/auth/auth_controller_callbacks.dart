import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Define typedefs for callbacks
typedef SetLoadingCallback = void Function(bool value);
// Corrected margin type from EdgeInsetsGeometry? to EdgeInsets?
typedef ShowSnackbarCallback = void Function(String title, String message, {Color? backgroundColor, Color? colorText, SnackPosition? snackPosition, double? borderRadius, EdgeInsets? margin});
typedef NavigateToCallback = Future<dynamic>? Function(String pageName, {dynamic arguments, int? id, bool preventDuplicates, Map<String, String>? parameters});
typedef NavigateOffAllCallback = Future<dynamic>? Function(String pageName, {dynamic arguments, int? id, Map<String, String>? parameters});
typedef ResetPasswordErrorsCallback = void Function();
typedef UpdatePasswordChangeSuccessCallback = void Function(bool value);
typedef SetCurrentPasswordErrorCallback = void Function(String value);
typedef SetSecurityAnswerErrorCallback = void Function(String value);


/// A class to bundle the callbacks needed by auth feature managers.
class AuthControllerCallbacks {
  final SetLoadingCallback setIsLoading;
  // Updated signature with corrected margin type
  final ShowSnackbarCallback showSnackbar;
  final NavigateToCallback navigateTo;
  final NavigateOffAllCallback navigateOffAll;
  final ResetPasswordErrorsCallback resetPasswordErrors; // Specific reset for password errors
  final UpdatePasswordChangeSuccessCallback updatePasswordChangeSuccess; // Specific state update
  final SetCurrentPasswordErrorCallback setCurrentPasswordError; // Specific error update
  final SetSecurityAnswerErrorCallback setSecurityAnswerError; // Specific error update


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
}