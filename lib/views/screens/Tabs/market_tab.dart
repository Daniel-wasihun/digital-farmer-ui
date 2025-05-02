import 'package:agri/controllers/market_controller.dart';
import 'package:agri/routes/app_routes.dart';
import 'package:agri/views/widgets/clone_price_dialog.dart';
import 'package:agri/views/widgets/price_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketController());
    // Set defaults
    controller.setSelectedDay(null);
    controller.setNameOrder('Default');
    controller.setPriceOrder('Default');
    controller.setMarketFilter('All');

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive scaling factor (aligned with PriceList and CropTipsTab)
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Font sizes (aligned with PriceList)
    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    final double headerFontSize = (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final double titleFontSize = (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final double subtitleFontSize = (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final double detailFontSize = (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    // Theme
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Font fallbacks for Amharic
    const List<String> fontFamilyFallback = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    // Search controller
    final searchController = TextEditingController();

    // Clear search
    void clearSearch() {
      searchController.clear();
      controller.setSearchQuery('');
    }

    // Reset filters
    void resetFilters() {
      clearSearch();
      controller.setSelectedDay(null);
      controller.setNameOrder('Default');
      controller.setPriceOrder('Default');
      controller.setMarketFilter('All');
    }

    // Week list
    final List<DateTime?> weeks = List.generate(7, (index) {
      if (index == 0) return _getMondayOfWeek(DateTime.now());
      return _getMondayOfWeek(DateTime.now().subtract(Duration(days: index * 7)));
    });

    // Month translations
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

    // Get translated month
    String getTranslatedMonth(DateTime date) {
      return monthKeys[date.month - 1].tr;
    }

    // Week labels
    final weekLabels = [
      'All'.tr,
      ...weeks.map((week) {
        if (week == null) return 'All'.tr;
        final weekStart = _normalizeDate(week);
        final weekEnd = _normalizeDate(weekStart.add(const Duration(days: 6)));
        if (_isSameWeek(weekStart, _getMondayOfWeek(DateTime.now()))) {
          return 'This Week'.tr;
        }
        if (_isSameWeek(weekStart, _getMondayOfWeek(DateTime.now().subtract(const Duration(days: 7))))) {
          return 'Last Week'.tr;
        }
        final startDay = weekStart.day.toString().padLeft(2, '0');
        final endDay = weekEnd.day.toString().padLeft(2, '0');
        final startMonth = getTranslatedMonth(weekStart);
        final endMonth = getTranslatedMonth(weekEnd);
        return '$startDay $startMonth - $endDay $endMonth';
      }),
    ];

    // Day labels
    final dayLabels = [
      'All'.tr,
      'monday'.tr,
      'tuesday'.tr,
      'wednesday'.tr,
      'thursday'.tr,
      'friday'.tr,
      'saturday'.tr,
      'sunday'.tr
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available height
            final availableHeight = constraints.maxHeight;

            // Estimate filters section height
            final filtersSectionHeight = (40 * adjustedScaleFactor) * 3 + // Three filter rows
                (8 * adjustedScaleFactor) * 2 + // Spacings between rows
                padding * 0.8 * 2 + // Vertical padding
                (8 * adjustedScaleFactor); // Top spacing and bottom margin

            return ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8 * adjustedScaleFactor),
                      // Filters Section
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: padding * 0.8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Week Selection
                            SizedBox(
                              height: 40 * adjustedScaleFactor,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                  child: Obx(() {
                                    String selectedWeekLabel = 'All'.tr;
                                    if (controller.selectedWeek.value != null) {
                                      final selectedWeek = _normalizeDate(controller.selectedWeek.value!);
                                      final weekStart = selectedWeek;
                                      final weekEnd = _normalizeDate(weekStart.add(const Duration(days: 6)));
                                      if (_isSameWeek(weekStart, _getMondayOfWeek(DateTime.now()))) {
                                        selectedWeekLabel = 'This Week'.tr;
                                      } else if (_isSameWeek(weekStart, _getMondayOfWeek(DateTime.now().subtract(const Duration(days: 7))))) {
                                        selectedWeekLabel = 'Last Week'.tr;
                                      } else {
                                        final startDay = weekStart.day.toString().padLeft(2, '0');
                                        final endDay = weekEnd.day.toString().padLeft(2, '0');
                                        final startMonth = getTranslatedMonth(weekStart);
                                        final endMonth = getTranslatedMonth(weekEnd);
                                        selectedWeekLabel = '$startDay $startMonth - $endDay $endMonth';
                                      }
                                    }

                                    return Row(
                                      children: weekLabels.map((label) {
                                        final isSelected = label == selectedWeekLabel;
                                        return GestureDetector(
                                          onTap: () {
                                            if (label == 'All'.tr) {
                                              controller.setSelectedWeek(null);
                                              resetFilters();
                                            } else {
                                              final index = weekLabels.indexOf(label);
                                              controller.setSelectedWeek(weeks[index - 1]);
                                              resetFilters();
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: EdgeInsets.symmetric(horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
                                            margin: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                            decoration: BoxDecoration(
                                              color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                              borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (isDarkMode ? Colors.green[300]! : Colors.green[500]!)
                                                    : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                                width: 1.2 * adjustedScaleFactor,
                                              ),
                                            ),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: subtitleFontSize,
                                                color: isSelected
                                                    ? (isDarkMode ? Colors.white : Colors.grey[900]!)
                                                    : (isDarkMode ? Colors.grey[300] : Colors.grey[700]!),
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                fontFamilyFallback: fontFamilyFallback,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * adjustedScaleFactor),
                            // Search
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: padding),
                              child: SizedBox(
                                height: 40 * adjustedScaleFactor,
                                child: TextField(
                                  controller: searchController,
                                  onChanged: controller.setSearchQuery,
                                  style: TextStyle(
                                    fontSize: detailFontSize,
                                    color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                    fontFamilyFallback: fontFamilyFallback,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter crop name...'.tr,
                                    hintStyle: TextStyle(
                                      fontSize: detailFontSize,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                      fontFamilyFallback: fontFamilyFallback,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 18 * adjustedScaleFactor,
                                      color: theme.colorScheme.primary,
                                    ),
                                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              size: 18 * adjustedScaleFactor,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            onPressed: clearSearch,
                                          )
                                        : const SizedBox.shrink()),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2 * adjustedScaleFactor),
                                    ),
                                    filled: true,
                                    fillColor: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10 * adjustedScaleFactor,
                                      horizontal: 10 * adjustedScaleFactor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8 * adjustedScaleFactor),
                            // Order By
                            SizedBox(
                              height: 40 * adjustedScaleFactor,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                  child: Row(
                                    children: [
                                      // Day Filter Dropdown
                                      Obx(() {
                                        String selectedDayLabel = 'All'.tr;
                                        if (controller.selectedWeek.value != null && controller.selectedDay.value != null) {
                                          final selectedDay = _normalizeDate(controller.selectedDay.value!);
                                          final weekStart = _normalizeDate(controller.selectedWeek.value!);
                                          final dayIndex = selectedDay.difference(weekStart).inDays;
                                          if (dayIndex >= 0 && dayIndex < 7) {
                                            selectedDayLabel = dayLabels[dayIndex + 1];
                                          }
                                        }
                                        final displayLabel = 'day_label'.trParams({'dayLabel': selectedDayLabel});
                                        final labelText = 'date'.tr;
                                        final dayText = displayLabel.contains('{dayLabel}') ? '$labelText: $selectedDayLabel' : displayLabel;

                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                          decoration: BoxDecoration(
                                            color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                            borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1.2 * adjustedScaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 200 * adjustedScaleFactor,
                                            ),
                                            onSelected: (value) {
                                              if (controller.selectedWeek.value == null) {
                                                Get.snackbar(
                                                  'Error'.tr,
                                                  'Please select a week first'.tr,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  duration: const Duration(seconds: 2),
                                                );
                                                return;
                                              }
                                              if (value == 'All'.tr) {
                                                controller.setSelectedDay(null);
                                              } else {
                                                final dayIndex = dayLabels.indexOf(value) - 1;
                                                final weekStart = _normalizeDate(controller.selectedWeek.value!);
                                                final selectedDay = weekStart.add(Duration(days: dayIndex));
                                                controller.setSelectedDay(selectedDay);
                                              }
                                            },
                                            itemBuilder: (context) => dayLabels
                                                .map((day) => PopupMenuItem<String>(
                                                      value: day,
                                                      child: Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.symmetric(
                                                          vertical: 6 * adjustedScaleFactor,
                                                          horizontal: 10 * adjustedScaleFactor,
                                                        ),
                                                        child: Text(
                                                          day,
                                                          style: TextStyle(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                            fontFamilyFallback: fontFamilyFallback,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      dayText,
                                                      style: TextStyle(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                        fontFamilyFallback: fontFamilyFallback,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4 * adjustedScaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18 * adjustedScaleFactor,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      // Name Order Dropdown
                                      Obx(() {
                                        final nameOrder = controller.nameOrder.value.tr;
                                        final displayLabel = 'name_order'.trParams({'nameOrder': nameOrder});
                                        final labelText = 'name'.tr;
                                        final nameText = displayLabel.contains('{nameOrder}') ? '$labelText: $nameOrder' : displayLabel;

                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                          decoration: BoxDecoration(
                                            color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                            borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1.2 * adjustedScaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 200 * adjustedScaleFactor,
                                            ),
                                            onSelected: controller.setNameOrder,
                                            itemBuilder: (context) => controller.nameSortOptions
                                                .map((option) => PopupMenuItem<String>(
                                                      value: option,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 6 * adjustedScaleFactor, horizontal: 10 * adjustedScaleFactor),
                                                        child: Text(
                                                          option.tr,
                                                          style: TextStyle(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                            fontFamilyFallback: fontFamilyFallback,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      nameText,
                                                      style: TextStyle(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                        fontFamilyFallback: fontFamilyFallback,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4 * adjustedScaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18 * adjustedScaleFactor,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      // Price Order Dropdown
                                      Obx(() {
                                        final priceOrder = controller.priceOrder.value.tr;
                                        final displayLabel = 'price_order'.trParams({'priceOrder': priceOrder});
                                        final labelText = 'price'.tr;
                                        final priceText = displayLabel.contains('{priceOrder}') ? '$labelText: $priceOrder' : displayLabel;

                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                          decoration: BoxDecoration(
                                            color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                            borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1.2 * adjustedScaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 200 * adjustedScaleFactor,
                                            ),
                                            onSelected: controller.setPriceOrder,
                                            itemBuilder: (context) => controller.priceSortOptions
                                                .map((option) => PopupMenuItem<String>(
                                                      value: option,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 6 * adjustedScaleFactor, horizontal: 10 * adjustedScaleFactor),
                                                        child: Text(
                                                          option.tr,
                                                          style: TextStyle(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                            fontFamilyFallback: fontFamilyFallback,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      priceText,
                                                      style: TextStyle(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                        fontFamilyFallback: fontFamilyFallback,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4 * adjustedScaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18 * adjustedScaleFactor,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      // Market Filter Dropdown
                                      Obx(() {
                                        final marketFilter = controller.marketFilter.value.isEmpty ? 'All'.tr : controller.marketFilter.value.tr;
                                        final displayLabel = 'market_filter'.trParams({'marketFilter': marketFilter});
                                        final labelText = 'market'.tr;
                                        final marketText = displayLabel.contains('{marketFilter}') ? '$labelText: $marketFilter' : displayLabel;

                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                          decoration: BoxDecoration(
                                            color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                                            borderRadius: BorderRadius.circular(10 * adjustedScaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1.2 * adjustedScaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 200 * adjustedScaleFactor,
                                            ),
                                            onSelected: controller.setMarketFilter,
                                            itemBuilder: (context) => ['All', ...controller.marketNames]
                                                .map((market) => PopupMenuItem<String>(
                                                      value: market,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 6 * adjustedScaleFactor, horizontal: 10 * adjustedScaleFactor),
                                                        child: Text(
                                                          market.tr,
                                                          style: TextStyle(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                            fontFamilyFallback: fontFamilyFallback,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      marketText,
                                                      style: TextStyle(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900]!,
                                                        fontFamilyFallback: fontFamilyFallback,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4 * adjustedScaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 18 * adjustedScaleFactor,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8 * adjustedScaleFactor), // Bottom margin
                    ],
                  ),
                  // Price List
                  Expanded(
                    child: PriceList(), // No parameters needed
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "clone_price",
            onPressed: () => Get.dialog(ClonePriceDialog(
              scaleFactor: adjustedScaleFactor,
              padding: padding,
              titleFontSize: titleFontSize,
              subtitleFontSize: subtitleFontSize,
              detailFontSize: detailFontSize,
            )),
            backgroundColor: isDarkMode ? Colors.blue[300] : Colors.blue[500],
            tooltip: 'Clone Prices'.tr,
            child: Icon(
              Icons.copy,
              color: Colors.white,
              size: 24 * adjustedScaleFactor,
            ),
          ),
          SizedBox(height: 12 * adjustedScaleFactor),
          FloatingActionButton(
            heroTag: "add_price",
            onPressed: () => Get.toNamed(AppRoutes.price),
            backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
            tooltip: 'Add Price'.tr,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 24 * adjustedScaleFactor,
            ),
          ),
          SizedBox(height: 16 * adjustedScaleFactor), // Bottom margin for FABs
        ],
      ),
    );
  }

  // Helper functions
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