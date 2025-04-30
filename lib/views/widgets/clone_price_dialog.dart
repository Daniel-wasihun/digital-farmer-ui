import 'package:agri/controllers/market_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class ClonePriceDialog extends StatelessWidget {
  final double scaleFactor;
  final double padding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;

  const ClonePriceDialog({
    super.key,
    required this.scaleFactor,
    required this.padding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Generate list of previous weeks (excluding current week)
    final List<DateTime> weeks = [];
    final now = _normalizeDate(DateTime.now());
    final currentMonday = _getMondayOfWeek(now);

    // Generate the last 6 weeks, starting from the Monday of the previous week
    for (int i = 1; i <= 6; i++) {
      final weekMonday = _normalizeDate(currentMonday.subtract(Duration(days: i * 7)));
      weeks.add(weekMonday);
    }

    // Convert weeks to display labels
    final weekLabels = weeks.map((week) {
      final weekStart = _normalizeDate(week);
      final weekEnd = _normalizeDate(weekStart.add(const Duration(days: 6)));
      if (_isSameWeek(weekStart, currentMonday.subtract(const Duration(days: 7)))) {
        return 'Last Week'.tr;
      }
      return '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
    }).toList();

    // Generate days for the selected week
    List<DateTime> getDaysOfWeek(DateTime? monday) {
      if (monday == null) return [];
      return List.generate(7, (index) => _normalizeDate(monday.add(Duration(days: index))));
    }

    final selectedWeek = Rxn<DateTime>();
    final selectedDays = RxList<DateTime>([]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      insetPadding: EdgeInsets.zero, // Remove default dialog padding
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: screenWidth, // Set width to full screen width
          maxWidth: screenWidth,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.copy,
                    size: 18 * scaleFactor,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  Text(
                    'Clone Prices'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scaleFactor),
              Text(
                'Select a week and one or more days to clone prices to today:'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: subtitleFontSize,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              Text(
                'Week:'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              SizedBox(height: 8 * scaleFactor),
              SizedBox(
                height: 36 * scaleFactor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: weeks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final week = entry.value;
                        final isSelected = selectedWeek.value != null &&
                            _normalizeDate(selectedWeek.value!) == _normalizeDate(week);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor),
                          child: GestureDetector(
                            onTap: () {
                              selectedWeek.value = week;
                              selectedDays.clear(); // Reset day selection
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 6 * scaleFactor),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDarkMode ? Colors.blue[300]!.withOpacity(0.3) : Colors.blue[500]!.withOpacity(0.3))
                                    : (isDarkMode ? Colors.grey[700] : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDarkMode ? Colors.blue[300]! : Colors.blue[500]!)
                                      : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                  width: 1 * scaleFactor,
                                ),
                              ),
                              child: Text(
                                weekLabels[index],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: subtitleFontSize,
                                  color: isSelected
                                      ? (isDarkMode ? Colors.white : Colors.grey[900])
                                      : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ),
              SizedBox(height: 16 * scaleFactor),
              Obx(() {
                final days = getDaysOfWeek(selectedWeek.value);
                if (days.isEmpty) return const SizedBox.shrink();
                final allSelected = selectedDays.length == days.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Days:'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (allSelected) {
                              selectedDays.clear();
                            } else {
                              selectedDays.assignAll(days);
                            }
                          },
                          child: Text(
                            allSelected ? 'Deselect All'.tr : 'Select All'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: subtitleFontSize,
                              color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scaleFactor),
                    SizedBox(
                      height: 36 * scaleFactor,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days.asMap().entries.map((entry) {
                            final index = entry.key;
                            final day = entry.value;
                            final isSelected = selectedDays.contains(day);
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor),
                              child: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    selectedDays.remove(day);
                                  } else {
                                    selectedDays.add(day);
                                  }
                                },
                                child: Semantics(
                                  label: 'Select ${DateFormat('EEEE, dd MMMM').format(day)} for cloning',
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 6 * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDarkMode ? Colors.blue[300]!.withOpacity(0.3) : Colors.blue[500]!.withOpacity(0.3))
                                          : (isDarkMode ? Colors.grey[700] : Colors.grey[100]),
                                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDarkMode ? Colors.blue[300]! : Colors.blue[500]!)
                                            : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                        width: 1 * scaleFactor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat('EEE, dd MMM').format(day),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: subtitleFontSize,
                                            color: isSelected
                                                ? (isDarkMode ? Colors.white : Colors.grey[900])
                                                : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          SizedBox(width: 4 * scaleFactor),
                                          Icon(
                                            Icons.check,
                                            size: 16 * scaleFactor,
                                            color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 24 * scaleFactor),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subtitleFontSize,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scaleFactor),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedWeek.value == null || selectedDays.isEmpty) {
                        Get.snackbar('Error'.tr, 'Please select a week and at least one day to clone'.tr);
                        return;
                      }
                      final daysText = selectedDays
                          .map((day) => DateFormat('dd MMM').format(day))
                          .join(', ');
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: Text('Confirm Clone'.tr),
                          content: Text(
                            'Clone prices from $daysText to today?'.tr,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('Cancel'.tr),
                            ),
                            ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              child: Text('Clone'.tr),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      Get.back(); // Close the modal
                      try {
                        final result = await controller.clonePrices(selectedDays.toList(), DateTime.now());
                        final totalCloned = int.parse(RegExp(r'(\d+)').firstMatch(result['message'])?.group(0) ?? '0');
                        final clonedPriceIds = List<String>.from(result['clonedPriceIds'] ?? []);

                        await controller.fetchPrices();
                        if (totalCloned > 0) {
                          Get.snackbar(
                            'Success'.tr,
                            '$totalCloned prices cloned successfully'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 5),
                            backgroundColor: Get.theme.colorScheme.primary,
                            colorText: Colors.white,
                            mainButton: TextButton(
                              onPressed: () async {
                                await controller.undoClonePrices(clonedPriceIds, DateTime.now());
                              },
                              child: Text('Undo'.tr, style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        } else {
                          // Map backend message to a translatable key
                          String message;
                          if (result['message'].contains('No new prices to clone after filtering duplicates')) {
                            message = 'No new prices to clone due to duplicates'.tr;
                          } else if (result['message'].contains('No prices found')) {
                            message = 'No prices found for the selected days'.tr;
                          } else {
                            message = 'No prices available to clone'.tr;
                          }
                          Get.snackbar(
                            'Info'.tr,
                            message,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Get.theme.colorScheme.primary,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.snackbar('Error'.tr, 'Failed to clone prices: $e'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Get.theme.colorScheme.error,
                            colorText: Colors.white);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
                    ),
                    child: Text(
                      'Clone'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subtitleFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final daysToSubtract = (date.weekday - 1) % 7;
    return _normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);
    return monday1.year == monday2.year && monday1.month == monday2.month && monday1.day == monday2.day;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}