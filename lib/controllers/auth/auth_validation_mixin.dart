import 'package:get/get.dart';

/// A mixin providing authentication-related validation methods.
/// Requires the class using this mixin to have observable error states
/// corresponding to the validation methods (e.g., `usernameError`, `emailError`, etc.).
mixin AuthValidationMixin {
  // Abstract observables that the implementing class must provide
  RxString get usernameError;
  RxString get emailError;
  RxString get passwordError;
  RxString get confirmPasswordError;
  RxString get currentPasswordError;
  RxString get newPasswordError;
  RxString get bioError;
  RxString get securityQuestionError;
  RxString get securityAnswerError;

  void validateUsername(String value) {
    print('Validating username: $value');
    if (value.isEmpty) {
      usernameError.value = 'username_required'.tr;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      usernameError.value = 'username_invalid'.tr;
    } else {
      usernameError.value = '';
    }
  }

  void validateEmail(String value) {
    print('Validating email: $value');
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value.isEmpty) {
      emailError.value = 'email_required'.tr;
    } else if (!emailRegex.hasMatch(value.toLowerCase())) {
      emailError.value = 'email_invalid'.tr;
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String value) {
    print('Validating password: ${value.isEmpty ? "empty" : "non-empty"}');
    if (value.isEmpty) {
      passwordError.value = 'password_required'.tr;
    } else if (value.length < 6) {
      passwordError.value = 'password_too_short'.tr;
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String password, String confirmPassword) {
    print('Validating confirm password: ${confirmPassword.isEmpty ? "empty" : "non-empty"}');
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'confirm_password_required'.tr;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'passwords_do_not_match'.tr;
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateCurrentPassword(String value) {
    if (value.isEmpty) {
      currentPasswordError.value = 'current_password_required'.tr;
    } else {
      currentPasswordError.value = '';
    }
  }

  void validateNewPassword(String value) {
    if (value.isEmpty) {
      newPasswordError.value = 'new_password_required'.tr;
    } else if (value.length < 6) {
      newPasswordError.value = 'password_too_short'.tr;
    } else {
      newPasswordError.value = '';
    }
  }

  void validateBio(String value) {
    if (value.length > 150) {
      bioError.value = 'bio_too_long'.tr;
    } else {
      bioError.value = '';
    }
  }

  void validateSecurityQuestion(String question) {
    if (question.trim().isEmpty) {
      securityQuestionError.value = 'question_required'.tr;
    } else {
      securityQuestionError.value = '';
    }
  }

  void validateSecurityAnswer(String answer) {
    if (answer.trim().isEmpty) {
      securityAnswerError.value = 'answer_required'.tr;
    } else if (answer.trim().length < 3) {
      securityAnswerError.value = 'answer_too_short'.tr;
    } else {
      securityAnswerError.value = '';
    }
  }
}