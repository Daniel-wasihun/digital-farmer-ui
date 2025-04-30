import 'package:agri/controllers/market_controller.dart';
import 'package:agri/views/widgets/clone_price_dialog.dart';
import 'package:agri/views/widgets/price_dialog.dart';
import 'package:agri/views/widgets/price_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketController());
    // Explicitly set defaults to ensure UI reflects them
    controller.setSelectedDay(null); // Default Day: "All"
    controller.setNameOrder('Default'); // Default Name: "Default"
    controller.setPriceOrder('Default'); // Default Price: "Default"
    controller.setMarketFilter('All'); // Default Market: "All"

    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isSmallPhone = size.width < 360;

    // Responsive scaling factor for UI elements
    final double scaleFactor = isLargeTablet ? 1.2 : isTablet ? 1.1 : isSmallPhone ? 0.9 : 1.0;
    // Responsive padding (minimal for left, right)
    final double edgePadding = isLargeTablet ? 8.0 : isTablet ? 6.0 : isSmallPhone ? 4.0 : 5.0;
    // Internal card padding
    final double innerPadding = isLargeTablet ? 14.4 : isTablet ? 12.0 : isSmallPhone ? 7.2 : 9.6;

    // Reduced base font sizes for smaller content
    const double baseTitleFontSize = 12.0;
    const double baseSubtitleFontSize = 9.0;
    const double baseDetailFontSize = 7.0;

    // Scaled font sizes
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Search controller
    final searchController = TextEditingController();

    // Clear search
    void clearSearch() {
      searchController.clear();
      controller.setSearchQuery('');
    }

    // Reset all filters
    void resetFilters() {
      clearSearch();
      controller.setSelectedDay(null); // Reset Day to "All"
      controller.setNameOrder('Default'); // Reset Name to "Default"
      controller.setPriceOrder('Default'); // Reset Price to "Default"
      controller.setMarketFilter('All'); // Reset Market to "All"
    }

    // Generate list of weeks (This Week, Last Week, and previous 5 weeks)
    final List<DateTime?> weeks = List.generate(7, (index) {
      if (index == 0) return _getMondayOfWeek(DateTime.now()); // This Week
      return _getMondayOfWeek(DateTime.now().subtract(Duration(days: index * 7)));
    });

    // Convert weeks to display labels
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
        return '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
      }),
    ];

    // List of days for dropdown
    final dayLabels = ['All'.tr, 'Monday'.tr, 'Tuesday'.tr, 'Wednesday'.tr, 'Thursday'.tr, 'Friday'.tr, 'Saturday'.tr, 'Sunday'.tr];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: edgePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add space at the top of the screen
                SizedBox(height: 8 * scaleFactor),
                // Combined Filters Card
                Card(
                  elevation: 3,
                  color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.only(bottom: 6 * scaleFactor), // Minimal bottom margin, no top
                  child: Container(
                    width: double.infinity, // Full width
                    padding: EdgeInsets.all(innerPadding * 0.6), // Reduced internal padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Week Selection
                        SizedBox(
                          height: 32 * scaleFactor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Obx(() {
                              // Determine the currently selected week label
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
                                  selectedWeekLabel = '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
                                }
                              }

                              return Row(
                                children: weekLabels.map((label) {
                                  final isSelected = label == selectedWeekLabel;
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4 * scaleFactor),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (label == 'All'.tr) {
                                          controller.setSelectedWeek(null);
                                          resetFilters(); // Reset filters on week change
                                        } else {
                                          final index = weekLabels.indexOf(label);
                                          controller.setSelectedWeek(weeks[index - 1]);
                                          resetFilters(); // Reset filters on week change
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: EdgeInsets.symmetric(horizontal: 10 * scaleFactor, vertical: 5 * scaleFactor),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDarkMode ? Colors.green[300]!.withOpacity(0.3) : Colors.green[500]!.withOpacity(0.3))
                                              : (isDarkMode ? Colors.grey[700] : Colors.grey[100]),
                                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                                          border: Border.all(
                                            color: isSelected
                                                ? (isDarkMode ? Colors.green[300]! : Colors.green[500]!)
                                                : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                                            width: 1 * scaleFactor,
                                          ),
                                        ),
                                        child: Text(
                                          label,
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
                        SizedBox(height: 8 * scaleFactor),
                        // Search
                        SizedBox(
                          height: 32 * scaleFactor,
                          child: TextField(
                            controller: searchController,
                            onChanged: controller.setSearchQuery,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: detailFontSize,
                              color: isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter crop name...'.tr,
                              hintStyle: TextStyle(
                                fontSize: detailFontSize,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 16 * scaleFactor,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        size: 16 * scaleFactor,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                      onPressed: clearSearch,
                                    )
                                  : const SizedBox.shrink()),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10 * scaleFactor),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 6 * scaleFactor,
                                horizontal: 10 * scaleFactor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        // Order By
                        SizedBox(
                          height: 28 * scaleFactor,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            child: Row(
                              children: [
                                // Day Filter Dropdown
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3 * scaleFactor),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 90 * scaleFactor,
                                    ),
                                    child: Obx(() {
                                      String selectedDayLabel = 'All'.tr;
                                      if (controller.selectedDay.value != null && controller.selectedWeek.value != null) {
                                        final selectedDay = _normalizeDate(controller.selectedDay.value!);
                                        final weekStart = _normalizeDate(controller.selectedWeek.value!);
                                        final dayIndex = selectedDay.difference(weekStart).inDays;
                                        if (dayIndex >= 0 && dayIndex < 7) {
                                          selectedDayLabel = dayLabels[dayIndex + 1];
                                        }
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                                          border: Border.all(
                                            color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                            width: 1 * scaleFactor,
                                          ),
                                        ),
                                        child: PopupMenuButton<String>(
                                          constraints: BoxConstraints(
                                            maxHeight: 160 * scaleFactor,
                                            minWidth: 90 * scaleFactor,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'All'.tr) {
                                              controller.setSelectedDay(null);
                                            } else if (controller.selectedWeek.value != null) {
                                              final dayIndex = dayLabels.indexOf(value) - 1;
                                              final weekStart = _normalizeDate(controller.selectedWeek.value!);
                                              final selectedDay = weekStart.add(Duration(days: dayIndex));
                                              controller.setSelectedDay(selectedDay);
                                            }
                                          },
                                          itemBuilder: (context) => dayLabels
                                              .map((day) => PopupMenuItem<String>(
                                                    value: day,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 8 * scaleFactor),
                                                      child: Text(
                                                        day,
                                                        style: theme.textTheme.bodyMedium?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: isDarkMode ? Colors.white : Colors.grey[900],
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Day: $selectedDayLabel'.tr,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontSize: detailFontSize,
                                                      color: isDarkMode ? Colors.white : Colors.grey[900],
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                SizedBox(width: 3 * scaleFactor),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 16 * scaleFactor,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                // Name Order Dropdown
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3 * scaleFactor),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 90 * scaleFactor,
                                    ),
                                    child: Obx(() => Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1 * scaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 160 * scaleFactor,
                                              minWidth: 90 * scaleFactor,
                                            ),
                                            onSelected: (value) => controller.setNameOrder(value),
                                            itemBuilder: (context) => controller.nameSortOptions
                                                .map((option) => PopupMenuItem<String>(
                                                      value: option,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 8 * scaleFactor),
                                                        child: Text(
                                                          option,
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900],
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Name: ${controller.nameOrder.value}'.tr,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3 * scaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 16 * scaleFactor,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                // Price Order Dropdown
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3 * scaleFactor),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 90 * scaleFactor,
                                    ),
                                    child: Obx(() => Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1 * scaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 160 * scaleFactor,
                                              minWidth: 90 * scaleFactor,
                                            ),
                                            onSelected: (value) => controller.setPriceOrder(value),
                                            itemBuilder: (context) => controller.priceSortOptions
                                                .map((option) => PopupMenuItem<String>(
                                                      value: option,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 8 * scaleFactor),
                                                        child: Text(
                                                          option,
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900],
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Price: ${controller.priceOrder.value}'.tr,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3 * scaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 16 * scaleFactor,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                                // Market Filter Dropdown
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3 * scaleFactor),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 90 * scaleFactor,
                                    ),
                                    child: Obx(() => Container(
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                                              width: 1 * scaleFactor,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: 160 * scaleFactor,
                                              minWidth: 90 * scaleFactor,
                                            ),
                                            onSelected: (value) => controller.setMarketFilter(value),
                                            itemBuilder: (context) => ['All', ...controller.marketNames]
                                                .map((market) => PopupMenuItem<String>(
                                                      value: market,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 8 * scaleFactor),
                                                        child: Text(
                                                          market,
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontSize: detailFontSize,
                                                            color: isDarkMode ? Colors.white : Colors.grey[900],
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Market: ${controller.marketFilter.value.isEmpty ? 'All' : controller.marketFilter.value}'.tr,
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: detailFontSize,
                                                        color: isDarkMode ? Colors.white : Colors.grey[900],
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3 * scaleFactor),
                                                  Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 16 * scaleFactor,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Price List
                PriceList(
                  scaleFactor: scaleFactor,
                  padding: edgePadding,
                  detailFontSize: detailFontSize,
                  subtitleFontSize: subtitleFontSize,
                  screenWidth: size.width,
                ),
                SizedBox(height: edgePadding * 2),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => Get.dialog(ClonePriceDialog(
              scaleFactor: scaleFactor,
              padding: innerPadding,
              titleFontSize: titleFontSize,
              subtitleFontSize: subtitleFontSize,
              detailFontSize: detailFontSize,
            )),
            backgroundColor: isDarkMode ? Colors.blue[300] : Colors.blue[500],
            tooltip: 'Clone Prices'.tr,
            mini: true,
            child: Icon(
              Icons.copy,
              color: Colors.white,
              size: 16 * scaleFactor,
            ),
          ),
          SizedBox(height: 8 * scaleFactor),
          FloatingActionButton(
            onPressed: () => Get.dialog(PriceDialog(
              scaleFactor: scaleFactor,
              padding: innerPadding,
              titleFontSize: titleFontSize,
              subtitleFontSize: subtitleFontSize,
              detailFontSize: detailFontSize,
            )),
            backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
            tooltip: 'Add Price'.tr,
            mini: true,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 16 * scaleFactor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get the Monday of the week for a given date
  DateTime _getMondayOfWeek(DateTime date) {
    final daysToSubtract = (date.weekday - 1) % 7;
    return _normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  // Helper function to check if two dates are in the same week
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);
    return monday1.year == monday2.year && monday1.month == monday2.month && monday1.day == monday2.day;
  }

  // Helper function to normalize DateTime to midnight UTC
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}