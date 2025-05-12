import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppUtils {
  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static DateTime getMondayOfWeek(DateTime date) {
    final daysToSubtract = (date.weekday - 1) % 7;
    return normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  static bool isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = getMondayOfWeek(date1);
    final monday2 = getMondayOfWeek(date2);
    return monday1.year == monday2.year &&
        monday1.month == monday2.month &&
        monday1.day == monday2.day;
  }

  static String formatDate(DateTime date, String format) {
    final monthKeys = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december'
    ];
    final monthName = monthKeys[date.month - 1].tr;

    final dayKeys = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final dayIndex = date.weekday % 7;
    final dayName = dayKeys[dayIndex].tr;

    if (format == 'dd MMM') {
      return '${DateFormat('dd').format(date)} $monthName';
    } else if (format == 'EEE, dd MMM') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName';
    } else if (format == 'EEEE, dd MMMM') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName';
    } else if (format == 'EEE, dd MMM yyyy') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName ${DateFormat('yyyy').format(date)}';
    }
    return DateFormat(format).format(date);
  }

  static void showSnackbar({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    TextButton? mainButton,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      mainButton: mainButton,
    );
  }
}