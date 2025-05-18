import 'package:agri/controllers/market_controller.dart';
import 'package:agri/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;

    final adjustedScaleFactor = scaleFactor * 1.1;
    final adjustedPadding = (padding * 1.2).clamp(16.0, 32.0);
    final adjustedTitleFontSize = (titleFontSize * 1.2).clamp(18.0, 26.0);
    final adjustedSubtitleFontSize = (subtitleFontSize * 1.2).clamp(14.0, 18.0);
    final adjustedDetailFontSize = (detailFontSize * 1.2).clamp(12.0, 16.0);
    final iconSize = (18.0 * adjustedScaleFactor).clamp(20.0, 26.0);
    final buttonHeight = (36.0 * adjustedScaleFactor).clamp(40.0, 48.0);

    final inputFillColor = theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05);
    final selectedInputFillColor = theme.colorScheme.primary.withOpacity(isDarkMode ? 0.2 : 0.15);

    final weeks = List.generate(
        6, (i) => AppUtils.normalizeDate(AppUtils.getMondayOfWeek(DateTime.now()).subtract(Duration(days: (i + 1) * 7))));
    final weekLabels = weeks.map((week) {
      final weekStart = AppUtils.normalizeDate(week);
      final weekEnd = AppUtils.normalizeDate(weekStart.add(const Duration(days: 6)));
      if (AppUtils.isSameWeek(weekStart, AppUtils.getMondayOfWeek(DateTime.now().subtract(const Duration(days: 7))))) {
        return 'Last Week'.tr;
      }
      return '${AppUtils.formatDate(weekStart, 'dd MMM')} - ${AppUtils.formatDate(weekEnd, 'dd MMM')}';
    }).toList();

    final selectedWeek = Rxn<DateTime>();
    final selectedDays = RxList<DateTime>([]);

    List<DateTime> getDaysOfWeek(DateTime? monday) =>
        monday == null ? [] : List.generate(7, (index) => AppUtils.normalizeDate(monday.add(Duration(days: index))));

    Widget buildSelectionChip({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
      IconData? trailingIcon,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
              horizontal: 12 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: adjustedSubtitleFontSize,
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.grey[900])
                      : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: 4 * adjustedScaleFactor),
                Icon(trailingIcon,
                    size: 16 * adjustedScaleFactor,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[500]),
              ],
            ],
          ),
        ),
      );
    }

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
          elevation: isDarkMode ? 6.0 : 10.0,
          color: cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * adjustedScaleFactor)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(adjustedPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.copy,
                          size: iconSize, color: isDarkMode ? Colors.blue[300] : Colors.blue[500]),
                      SizedBox(width: 8 * adjustedScaleFactor),
                      Expanded(
                        child: Text(
                          'Clone Prices'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: adjustedTitleFontSize,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
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
                      child: Obx(() => Row(
                            children: weeks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final week = entry.value;
                              final isSelected = selectedWeek.value != null &&
                                  AppUtils.normalizeDate(selectedWeek.value!) ==
                                      AppUtils.normalizeDate(week);
                              return Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 6 * adjustedScaleFactor),
                                child: buildSelectionChip(
                                  label: weekLabels[index],
                                  isSelected: isSelected,
                                  onTap: () {
                                    selectedWeek.value = week;
                                    selectedDays.clear();
                                  },
                                ),
                              );
                            }).toList(),
                          )),
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
                                final day = entry.value;
                                final isSelected = selectedDays.contains(day);
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6 * adjustedScaleFactor),
                                  child: buildSelectionChip(
                                    label: AppUtils.formatDate(day, 'EEE, dd MMM'),
                                    isSelected: isSelected,
                                    onTap: () {
                                      if (isSelected) {
                                        selectedDays.remove(day);
                                      } else {
                                        selectedDays.add(day);
                                      }
                                    },
                                    trailingIcon: isSelected ? Icons.check : null,
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
                        onPressed: () => Get.back(),
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
                            AppUtils.showSnackbar(
                              title: 'Error'.tr,
                              message: 'Please select a week and at least one day to clone'.tr,
                              position: SnackPosition.BOTTOM,
                              backgroundColor: Get.theme.colorScheme.error,
                              textColor: Colors.white,
                            );
                            return;
                          }
                          final daysText = selectedDays
                              .map((day) => AppUtils.formatDate(day, 'dd MMM'))
                              .join(', ');
                          final confirm = await Get.dialog<bool>(
                            Material(
                              color: Colors.transparent,
                              child: AlertDialog(
                                backgroundColor: cardColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12 * adjustedScaleFactor)),
                                title: Text('Confirm Clone'.tr,
                                    style: TextStyle(fontSize: adjustedTitleFontSize)),
                                content: Text(
                                  'Clone prices from $daysText to today?'.tr,
                                  style: TextStyle(fontSize: adjustedSubtitleFontSize),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: Text('Cancel'.tr,
                                        style: TextStyle(fontSize: adjustedSubtitleFontSize)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    child: Text('Clone'.tr,
                                        style: TextStyle(fontSize: adjustedSubtitleFontSize)),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (confirm != true) return;
                          try {
                            final result =
                                await controller.clonePrices(selectedDays.toList(), DateTime.now());
                            final totalCloned = int.parse(
                                RegExp(r'(\d+)').firstMatch(result['message'])?.group(0) ?? '0');
                            final clonedPriceIds = List<String>.from(result['clonedPriceIds'] ?? []);

                            await controller.fetchPrices();
                            Get.back();
                            if (totalCloned > 0) {
                              AppUtils.showSnackbar(
                                title: 'Success'.tr,
                                message: '$totalCloned prices cloned successfully'.tr,
                                position: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 5),
                                backgroundColor: Get.theme.colorScheme.primary,
                                textColor: Colors.white,
                                mainButton: TextButton(
                                  onPressed: () async {
                                    await controller.undoClonePrices(
                                        clonedPriceIds, DateTime.now());
                                  },
                                  child: const Text('Undo', style: TextStyle(color: Colors.white)),
                                ),
                              );
                            } else {
                              String message;
                              if (result['message']
                                  .contains('No new prices to clone after filtering duplicates')) {
                                message = 'No new prices to clone due to duplicates'.tr;
                              } else if (result['message'].contains('No prices found')) {
                                message = 'No prices found for the selected days'.tr;
                              } else {
                                message = 'No prices available to clone'.tr;
                              }
                              AppUtils.showSnackbar(
                                title: 'Info'.tr,
                                message: message,
                                position: SnackPosition.BOTTOM,
                                backgroundColor: Get.theme.colorScheme.primary,
                                textColor: Colors.white,
                              );
                            }
                          } catch (e) {
                            AppUtils.showSnackbar(
                              title: 'Error'.tr,
                              message: 'Failed to clone prices: $e'.tr,
                              position: SnackPosition.BOTTOM,
                              backgroundColor: Get.theme.colorScheme.error,
                              textColor: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.elevatedButtonTheme.style?.backgroundColor
                              ?.resolve({WidgetState.pressed}) ??
                              theme.colorScheme.primary,
                          foregroundColor: theme.elevatedButtonTheme.style?.foregroundColor
                              ?.resolve({WidgetState.pressed}) ??
                              theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16 * adjustedScaleFactor,
                              vertical: 8 * adjustedScaleFactor),
                          elevation: 4.0,
                          textStyle: TextStyle(
                              fontSize: adjustedSubtitleFontSize, fontWeight: FontWeight.bold),
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
}