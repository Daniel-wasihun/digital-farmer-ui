import 'package:agri/controllers/market_controller.dart';
import 'package:agri/routes/app_routes.dart';
import 'package:agri/utils/app_utils.dart';
import 'package:agri/views/widgets/clone_price_dialog.dart';
import 'package:agri/views/widgets/price_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketController>(); // Use Get.find since initialized elsewhere
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final scaleFactor =
        (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final adjustedScaleFactor = scaleFactor * 1.1;
    final padding =
        (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    final headerFontSize =
        (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final titleFontSize =
        (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final subtitleFontSize =
        (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final detailFontSize =
        (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const fontFamilyFallback = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    void clearSearch() {
      searchController.clear();
      controller.setSearchQuery('');
      searchFocusNode.unfocus();
    }

    void resetFilters() {
      clearSearch();
      controller
        ..setSelectedDay(null)
        ..setNameOrder('Default')
        ..setPriceOrder('Default')
        ..setMarketFilter('All');
    }

    final weeks = [
      AppUtils.getMondayOfWeek(DateTime.now()),
      ...List.generate(
          6,
          (index) => AppUtils.getMondayOfWeek(
              DateTime.now().subtract(Duration(days: (index + 1) * 7)))),
    ];

    final weekLabels = [
      'All'.tr,
      ...weeks.map((week) {
        final weekStart = AppUtils.normalizeDate(week);
        final weekEnd = AppUtils.normalizeDate(weekStart.add(const Duration(days: 6)));
        if (AppUtils.isSameWeek(weekStart, AppUtils.getMondayOfWeek(DateTime.now()))) {
          return 'This Week'.tr;
        } else if (AppUtils.isSameWeek(
            weekStart, AppUtils.getMondayOfWeek(DateTime.now().subtract(const Duration(days: 7))))) {
          return 'Last Week'.tr;
        }
        return '${AppUtils.formatDate(weekStart, 'dd MMM')} - ${AppUtils.formatDate(weekEnd, 'dd MMM')}';
      }),
    ];

    final dayLabels = [
      'All'.tr,
      'monday'.tr,
      'tuesday'.tr,
      'wednesday'.tr,
      'thursday'.tr,
      'friday'.tr,
      'saturday'.tr,
      'sunday'.tr,
    ];

    Widget buildFilterChip({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
              horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
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
    }

    Widget buildDropdown({
      required String label,
      required String displayLabel,
      required List<String> items,
      required void Function(String) onSelected,
    }) {
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
          constraints: BoxConstraints(maxHeight: 200 * adjustedScaleFactor),
          onSelected: onSelected,
          itemBuilder: (context) => items
              .map((item) => PopupMenuItem<String>(
                    value: item,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 6 * adjustedScaleFactor,
                        horizontal: 10 * adjustedScaleFactor,
                      ),
                      child: Text(
                        item.tr,
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
            padding: EdgeInsets.symmetric(
                horizontal: 10 * adjustedScaleFactor, vertical: 6 * adjustedScaleFactor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayLabel,
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
    }

    return GestureDetector(
      onTap: () => searchFocusNode.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final filtersSectionHeight = (40 * adjustedScaleFactor) * 3 +
                  (8 * adjustedScaleFactor) * 2 +
                  padding * 0.8 * 2 +
                  (8 * adjustedScaleFactor);

              return ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8 * adjustedScaleFactor),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: padding * 0.8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 40 * adjustedScaleFactor,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                    child: Obx(() {
                                      String selectedWeekLabel = 'All'.tr;
                                      if (controller.selectedWeek.value != null) {
                                        final selectedWeek =
                                            AppUtils.normalizeDate(controller.selectedWeek.value!);
                                        final weekStart = selectedWeek;
                                        final weekEnd = AppUtils.normalizeDate(
                                            weekStart.add(const Duration(days: 6)));
                                        if (AppUtils.isSameWeek(
                                            weekStart, AppUtils.getMondayOfWeek(DateTime.now()))) {
                                          selectedWeekLabel = 'This Week'.tr;
                                        } else if (AppUtils.isSameWeek(
                                            weekStart,
                                            AppUtils.getMondayOfWeek(
                                                DateTime.now().subtract(const Duration(days: 7))))) {
                                          selectedWeekLabel = 'Last Week'.tr;
                                        } else {
                                          selectedWeekLabel =
                                              '${AppUtils.formatDate(weekStart, 'dd MMM')} - ${AppUtils.formatDate(weekEnd, 'dd MMM')}';
                                        }
                                      }

                                      return Row(
                                        children: weekLabels.asMap().entries.map((entry) {
                                          final label = entry.value;
                                          final isSelected = label == selectedWeekLabel;
                                          return buildFilterChip(
                                            label: label,
                                            isSelected: isSelected,
                                            onTap: () {
                                              if (label == 'All'.tr) {
                                                controller.setSelectedWeek(null);
                                                resetFilters();
                                              } else {
                                                controller.setSelectedWeek(weeks[entry.key - 1]);
                                                resetFilters();
                                              }
                                            },
                                          );
                                        }).toList(),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8 * adjustedScaleFactor),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padding),
                                child: SizedBox(
                                  height: 40 * adjustedScaleFactor,
                                  child: ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: searchController,
                                    builder: (context, textValue, child) {
                                      return TextField(
                                        controller: searchController,
                                        focusNode: searchFocusNode,
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
                                          suffixIcon: textValue.text.isNotEmpty || searchFocusNode.hasFocus
                                              ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: 18 * adjustedScaleFactor,
                                                    color: theme.colorScheme.onSurface,
                                                  ),
                                                  onPressed: clearSearch,
                                                )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10 * adjustedScaleFactor),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10 * adjustedScaleFactor),
                                            borderSide: BorderSide(
                                                color: theme.colorScheme.primary,
                                                width: 1.2 * adjustedScaleFactor),
                                          ),
                                          filled: true,
                                          fillColor: theme.cardTheme.color ??
                                              (isDarkMode ? Colors.grey[850] : Colors.white),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10 * adjustedScaleFactor,
                                            horizontal: 10 * adjustedScaleFactor,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 8 * adjustedScaleFactor),
                              SizedBox(
                                height: 40 * adjustedScaleFactor,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4 * adjustedScaleFactor),
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          String selectedDayLabel = 'All'.tr;
                                          if (controller.selectedWeek.value != null &&
                                              controller.selectedDay.value != null) {
                                            final selectedDay = AppUtils.normalizeDate(
                                                controller.selectedDay.value!);
                                            final weekStart = AppUtils.normalizeDate(
                                                controller.selectedWeek.value!);
                                            final dayIndex =
                                                selectedDay.difference(weekStart).inDays;
                                            if (dayIndex >= 0 && dayIndex < 7) {
                                              selectedDayLabel = dayLabels[dayIndex + 1];
                                            }
                                          }
                                          final displayLabel =
                                              'day_label'.trParams({'dayLabel': selectedDayLabel});
                                          final labelText = 'date'.tr;
                                          final dayText = displayLabel.contains('{dayLabel}')
                                              ? '$labelText: $selectedDayLabel'
                                              : displayLabel;

                                          return buildDropdown(
                                            label: 'Date',
                                            displayLabel: dayText,
                                            items: dayLabels,
                                            onSelected: (value) {
                                              if (controller.selectedWeek.value == null) {
                                                AppUtils.showSnackbar(
                                                  title: 'Error'.tr,
                                                  message: 'Please select a week first'.tr,
                                                  position: SnackPosition.BOTTOM,
                                                  duration: const Duration(seconds: 2),
                                                );
                                                return;
                                              }
                                              if (value == 'All'.tr) {
                                                controller.setSelectedDay(null);
                                              } else {
                                                final dayIndex = dayLabels.indexOf(value) - 1;
                                                final weekStart = AppUtils.normalizeDate(
                                                    controller.selectedWeek.value!);
                                                final selectedDay =
                                                    weekStart.add(Duration(days: dayIndex));
                                                controller.setSelectedDay(selectedDay);
                                              }
                                            },
                                          );
                                        }),
                                        Obx(() {
                                          final nameOrder = controller.nameOrder.value.tr;
                                          final displayLabel =
                                              'name_order'.trParams({'nameOrder': nameOrder});
                                          final labelText = 'name'.tr;
                                          final nameText = displayLabel.contains('{nameOrder}')
                                              ? '$labelText: $nameOrder'
                                              : displayLabel;

                                          return buildDropdown(
                                            label: 'Name Order',
                                            displayLabel: nameText,
                                            items: controller.nameSortOptions,
                                            onSelected: controller.setNameOrder,
                                          );
                                        }),
                                        Obx(() {
                                          final priceOrder = controller.priceOrder.value.tr;
                                          final displayLabel =
                                              'price_order'.trParams({'priceOrder': priceOrder});
                                          final labelText = 'price'.tr;
                                          final priceText = displayLabel.contains('{priceOrder}')
                                              ? '$labelText: $priceOrder'
                                              : displayLabel;

                                          return buildDropdown(
                                            label: 'Price Order',
                                            displayLabel: priceText,
                                            items: controller.priceSortOptions,
                                            onSelected: controller.setPriceOrder,
                                          );
                                        }),
                                        Obx(() {
                                          final marketFilter = controller.marketFilter.value.isEmpty
                                              ? 'All'.tr
                                              : controller.marketFilter.value.tr;
                                          final displayLabel = 'market_filter'
                                              .trParams({'marketFilter': marketFilter});
                                          final labelText = 'market'.tr;
                                          final marketText = displayLabel.contains('{marketFilter}')
                                              ? '$labelText: $marketFilter'
                                              : displayLabel;

                                          return buildDropdown(
                                            label: 'Market Filter',
                                            displayLabel: marketText,
                                            items: ['All', ...controller.marketNames],
                                            onSelected: controller.setMarketFilter,
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
                        SizedBox(height: 8 * adjustedScaleFactor),
                      ],
                    ),
                    Expanded(child: PriceList()),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Obx(() => controller.isAdmin.value
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 48 * adjustedScaleFactor,
                    height: 48 * adjustedScaleFactor,
                    child: FloatingActionButton(
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
                        size: 22 * adjustedScaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * adjustedScaleFactor),
                  SizedBox(
                    width: 48 * adjustedScaleFactor,
                    height: 48 * adjustedScaleFactor,
                    child: FloatingActionButton(
                      heroTag: "add_price",
                      onPressed: () => Get.toNamed(AppRoutes.price),
                      backgroundColor: isDarkMode ? Colors.green[300] : Colors.green[500],
                      tooltip: 'Add Price'.tr,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22 * adjustedScaleFactor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * adjustedScaleFactor),
                ],
              )
            : const SizedBox.shrink()),
      ),
    );
  }
}