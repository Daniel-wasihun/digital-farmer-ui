import 'package:agri/controllers/market_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

    // Increase content sizes slightly for larger appearance
    final adjustedScaleFactor = scaleFactor * 1.1; // 10% larger for all scaled elements
    final adjustedPadding = (padding * 1.2).clamp(16.0, 32.0); // Slightly larger padding
    final adjustedTitleFontSize = (titleFontSize * 1.2).clamp(18.0, 26.0); // Larger title
    final adjustedSubtitleFontSize = (subtitleFontSize * 1.2).clamp(14.0, 18.0); // Larger subtitle
    final adjustedDetailFontSize = (detailFontSize * 1.2).clamp(12.0, 16.0); // Larger details
    final iconSize = (18.0 * adjustedScaleFactor).clamp(20.0, 26.0); // Larger icons
    final buttonHeight = (36.0 * adjustedScaleFactor).clamp(40.0, 48.0); // Larger button height

    // Define input field colors to match ChangePasswordScreen
    final inputFillColor = theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05);
    final selectedInputFillColor = theme.colorScheme.primary.withOpacity(isDarkMode ? 0.2 : 0.15);

    // Generate list of previous weeks (excluding current week)
    final List<DateTime> weeks = [];
    final now = _normalizeDate(DateTime.now());
    final currentMonday = _getMondayOfWeek(now);

    for (int i = 1; i <= 6; i++) {
      final weekMonday = _normalizeDate(currentMonday.subtract(Duration(days: i * 7)));
      weeks.add(weekMonday);
    }

    final weekLabels = weeks.map((week) {
      final weekStart = _normalizeDate(week);
      final weekEnd = _normalizeDate(weekStart.add(const Duration(days: 6)));
      if (_isSameWeek(weekStart, currentMonday.subtract(const Duration(days: 7)))) {
        return 'Last Week'.tr;
      }
      return '${_formatDate(weekStart, 'dd MMM')} - ${_formatDate(weekEnd, 'dd MMM')}';
    }).toList();

    List<DateTime> getDaysOfWeek(DateTime? monday) {
      if (monday == null) return [];
      return List.generate(7, (index) => _normalizeDate(monday.add(Duration(days: index))));
    }

    final selectedWeek = Rxn<DateTime>();
    final selectedDays = RxList<DateTime>([]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * adjustedScaleFactor)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: adjustedPadding, vertical: adjustedPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: screenWidth * 0.9,
          maxWidth: screenWidth * 0.9,
          maxHeight: (MediaQuery.of(context).size.height * 0.75 * adjustedScaleFactor).clamp(400.0, 600.0),
        ),
        child: Card(
          elevation: isDarkMode ? 6.0 : 10.0, // Match ChangePasswordScreen elevation
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * adjustedScaleFactor),
          ),
          clipBehavior: Clip.antiAlias, // Match ChangePasswordScreen clip behavior
          child: Padding(
            padding: EdgeInsets.all(adjustedPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.copy,
                        size: iconSize,
                        color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                      ),
                      SizedBox(width: 8 * adjustedScaleFactor),
                      Expanded(
                        child: Text(
                          'Clone Prices'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: adjustedTitleFontSize,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary, // Use primary color
                            shadows: isDarkMode
                                ? null
                                : [
                                    Shadow(
                                      blurRadius: 6.0,
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * adjustedScaleFactor),
                  Text(
                    'Select a week and one or more days to clone prices to today:'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: adjustedSubtitleFontSize,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12 * adjustedScaleFactor),
                  Text(
                    'Week:'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: adjustedSubtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 8 * adjustedScaleFactor),
                  SizedBox(
                    height: buttonHeight,
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
                              padding: EdgeInsets.symmetric(horizontal: 6 * adjustedScaleFactor),
                              child: GestureDetector(
                                onTap: () {
                                  selectedWeek.value = week;
                                  selectedDays.clear();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * adjustedScaleFactor,
                                    vertical: 6 * adjustedScaleFactor,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? selectedInputFillColor : inputFillColor,
                                    borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                      width: 1 * adjustedScaleFactor,
                                    ),
                                  ),
                                  child: Text(
                                    weekLabels[index],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: adjustedSubtitleFontSize,
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
                  SizedBox(height: 16 * adjustedScaleFactor),
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
                                fontSize: adjustedSubtitleFontSize,
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
                                  fontSize: adjustedSubtitleFontSize,
                                  color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * adjustedScaleFactor),
                        SizedBox(
                          height: buttonHeight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: days.asMap().entries.map((entry) {
                                final index = entry.key;
                                final day = entry.value;
                                final isSelected = selectedDays.contains(day);
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6 * adjustedScaleFactor),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isSelected) {
                                        selectedDays.remove(day);
                                      } else {
                                        selectedDays.add(day);
                                      }
                                    },
                                    child: Semantics(
                                      label: 'Select ${_formatDate(day, 'EEEE, dd MMMM')} for cloning',
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12 * adjustedScaleFactor,
                                          vertical: 6 * adjustedScaleFactor,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected ? selectedInputFillColor : inputFillColor,
                                          borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                                          border: Border.all(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                            width: 1 * adjustedScaleFactor,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _formatDate(day, 'EEE, dd MMM'),
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: adjustedSubtitleFontSize,
                                                color: isSelected
                                                    ? (isDarkMode ? Colors.white : Colors.grey[900])
                                                    : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              SizedBox(width: 4 * adjustedScaleFactor),
                                              Icon(
                                                Icons.check,
                                                size: 16 * adjustedScaleFactor,
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
                  SizedBox(height: 24 * adjustedScaleFactor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Cancel'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: adjustedSubtitleFontSize,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * adjustedScaleFactor),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedWeek.value == null || selectedDays.isEmpty) {
                            Get.snackbar('Error'.tr, 'Please select a week and at least one day to clone'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Get.theme.colorScheme.error,
                                colorText: Colors.white);
                            return;
                          }
                          final daysText = selectedDays
                              .map((day) => _formatDate(day, 'dd MMM'))
                              .join(', ');
                          final confirm = await Get.dialog<bool>(
                            Material(
                              color: Colors.transparent,
                              child: AlertDialog(
                                backgroundColor: theme.cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                ),
                                title: Text('Confirm Clone'.tr, style: TextStyle(fontSize: adjustedTitleFontSize)),
                                content: Text(
                                  'Clone prices from $daysText to today?'.tr,
                                  style: TextStyle(fontSize: adjustedSubtitleFontSize),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: Text('Cancel'.tr, style: TextStyle(fontSize: adjustedSubtitleFontSize)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: Text('Clone'.tr, style: TextStyle(fontSize: adjustedSubtitleFontSize)),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (confirm != true) return;
                          try {
                            final result = await controller.clonePrices(selectedDays.toList(), DateTime.now());
                            final totalCloned = int.parse(RegExp(r'(\d+)').firstMatch(result['message'])?.group(0) ?? '0');
                            final clonedPriceIds = List<String>.from(result['clonedPriceIds'] ?? []);

                            await controller.fetchPrices();
                            Get.back();
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
                          backgroundColor: theme.elevatedButtonTheme.style?.backgroundColor?.resolve({WidgetState.pressed}) ?? theme.colorScheme.primary,
                          foregroundColor: theme.elevatedButtonTheme.style?.foregroundColor?.resolve({WidgetState.pressed}) ?? theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16 * adjustedScaleFactor, vertical: 8 * adjustedScaleFactor),
                          elevation: 4.0,
                          textStyle: TextStyle(fontSize: adjustedSubtitleFontSize, fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          'Clone'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: adjustedSubtitleFontSize,
                            color: theme.colorScheme.onPrimary,
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

  String _formatDate(DateTime date, String format) {
    final monthKeys = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    final monthName = monthKeys[date.month - 1].tr;

    final dayKeys = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    final dayIndex = date.weekday % 7;
    final dayName = dayKeys[dayIndex].tr;

    if (format == 'dd MMM') {
      return '${DateFormat('dd').format(date)} $monthName';
    } else if (format == 'EEE, dd MMM') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName';
    } else if (format == 'EEEE, dd MMMM') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName';
    }
    return DateFormat(format).format(date);
  }
}