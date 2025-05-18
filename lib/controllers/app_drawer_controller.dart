import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class AppDrawerController extends GetxController with GetSingleTickerProviderStateMixin {
  final isDrawerOpen = false.obs;
  late AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  void toggleDrawer() {
    isDrawerOpen.toggle();
    if (isDrawerOpen.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}