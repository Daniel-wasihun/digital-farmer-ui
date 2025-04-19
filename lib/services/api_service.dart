import 'package:get/get.dart';
import 'api/auth_api.dart';
import 'api/feedback_api.dart';
import 'api/message_api.dart';
import 'api/user_api.dart';

class ApiService {
  final AuthApi auth = Get.put(AuthApi());
  final FeedbackApi feedback = Get.put(FeedbackApi());
  final MessageApi message = Get.put(MessageApi());
  final UserApi user = Get.put(UserApi());

  static ApiService create() {
    return ApiService();
  }
}