import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/crop_tips_controller.dart';
import '../../../../utils/crop_data.dart';
import 'ai_chat_screen.dart';

class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final CropTipsController controller = Get.put(CropTipsController());
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // Responsive scaling factor
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Font sizes
    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    final double headerFontSize = (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final double titleFontSize = (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final double subtitleFontSize = (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final double detailFontSize = (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    // Dynamic grid columns
    final int crossAxisCount = screenWidth < 360
        ? 1
        : screenWidth < 600
            ? 2
            : screenWidth < 900
                ? 3
                : 4;

    // Font fallbacks for Amharic
    const List<String> fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    // Ensure default value for selected crop
    if (controller.selectedCrop.value.isEmpty) {
      controller.selectedCrop.value = '';
    }

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            controller.currentTabIndex.value = tabController.index;
          });

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ??
                          (Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: 'Crop Tips'.tr),
                            Tab(text: 'Crop Info'.tr),
                          ],
                          labelStyle: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontFamilyFallback: fontFamilyFallbacks,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            fontFamilyFallback: fontFamilyFallbacks,
                          ),
                          indicatorColor: Colors.green[700],
                          labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          unselectedLabelColor: Colors.grey[500],
                        ),
                        Obx(() => controller.currentTabIndex.value == 0
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
                                    child: AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: SizedBox(
                                        height: 36 * adjustedScaleFactor,
                                        child: TextField(
                                          controller: controller.searchController,
                                          decoration: InputDecoration(
                                            hintText: 'Search Crops'.tr,
                                            hintStyle: TextStyle(
                                              fontSize: detailFontSize,
                                              color: Colors.grey[500],
                                              fontFamilyFallback: fontFamilyFallbacks,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                                              borderSide: BorderSide(color: Colors.grey, width: 1 * adjustedScaleFactor),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                                              borderSide: BorderSide(color: Colors.grey, width: 1 * adjustedScaleFactor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                                              borderSide: BorderSide(color: Colors.grey, width: 1 * adjustedScaleFactor),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context).cardTheme.color ??
                                                (Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.grey[850]
                                                    : Colors.white),
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: Colors.green[700],
                                              size: 18 * adjustedScaleFactor,
                                            ),
                                            suffixIcon: Obx(
                                              () => controller.searchQuery.value.isNotEmpty
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.clear,
                                                        color: Colors.green[700],
                                                        size: 18 * adjustedScaleFactor,
                                                      ),
                                                      onPressed: controller.clearSearch,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 8 * adjustedScaleFactor,
                                              horizontal: 10 * adjustedScaleFactor,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: detailFontSize,
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.grey[900],
                                            fontFamilyFallback: fontFamilyFallbacks,
                                          ),
                                          onChanged: (value) {
                                            controller.searchQuery.value = value;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
                                    child: SizedBox(
                                      height: 36 * adjustedScaleFactor,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: controller.getCategories().length,
                                        itemBuilder: (context, index) {
                                          final category = controller.getCategories()[index];
                                          return Obx(() {
                                            final isSelected = controller.selectedCategory.value == category;
                                            return Padding(
                                              padding: EdgeInsets.only(right: 8 * adjustedScaleFactor),
                                              child: GestureDetector(
                                                onTap: () => controller.selectedCategory.value = category,
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12 * adjustedScaleFactor,
                                                    vertical: 6 * adjustedScaleFactor,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.green[700]
                                                        : (Theme.of(context).cardTheme.color ??
                                                            (Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.grey[850]
                                                                : Colors.white)),
                                                    borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                                    border: Border.all(
                                                      color: isSelected ? Colors.green[700]! : Colors.grey[500]!,
                                                      width: 1 * adjustedScaleFactor,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      category.tr,
                                                      style: TextStyle(
                                                        fontSize: detailFontSize * 0.9,
                                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : (Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.grey[300]
                                                                : Colors.grey[800]),
                                                        fontFamilyFallback: fontFamilyFallbacks,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * adjustedScaleFactor),
                  Expanded(
                    child: TabBarView(
                      children: [
                        CropTipsView(
                          controller: controller,
                          adjustedScaleFactor: adjustedScaleFactor,
                          padding: padding,
                          headerFontSize: headerFontSize,
                          titleFontSize: titleFontSize,
                          subtitleFontSize: subtitleFontSize,
                          detailFontSize: detailFontSize,
                          crossAxisCount: crossAxisCount,
                          fontFamilyFallbacks: fontFamilyFallbacks,
                        ),
                        CropInfoView(
                          controller: controller,
                          adjustedScaleFactor: adjustedScaleFactor,
                          padding: padding,
                          detailFontSize: detailFontSize,
                          fontFamilyFallbacks: fontFamilyFallbacks,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'ai_chat_page', // Unique tag to avoid Hero conflict
              onPressed: () {
                Get.to(
                  () => const AIChatScreen(),
                  transition: Transition.noTransition,
                );
              },
              backgroundColor: Colors.green[700],
              tooltip: 'AI Chat'.tr,
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24 * adjustedScaleFactor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CropTipsView extends StatelessWidget {
  final CropTipsController controller;
  final double adjustedScaleFactor;
  final double padding;
  final double headerFontSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;
  final int crossAxisCount;
  final List<String> fontFamilyFallbacks;

  const CropTipsView({
    super.key,
    required this.controller,
    required this.adjustedScaleFactor,
    required this.padding,
    required this.headerFontSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.crossAxisCount,
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
      ),
      child: Obx(() {
        final filteredCrops = controller.getFilteredCrops();
        if (filteredCrops.isEmpty) {
          return Center(
            child: Text(
              'No Crops Found'.tr,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontFamilyFallback: fontFamilyFallbacks,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 3 / 1.95,
          ),
          itemCount: filteredCrops.length,
          itemBuilder: (context, index) {
            final entry = filteredCrops[index];
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CropDetailSheet(
                    cropName: entry.key.tr,
                    data: entry.value,
                    theme: theme,
                    isDarkMode: isDarkMode,
                    scaleFactor: adjustedScaleFactor,
                    padding: padding,
                    headerFontSize: headerFontSize,
                    titleFontSize: titleFontSize,
                    subtitleFontSize: subtitleFontSize,
                    detailFontSize: detailFontSize,
                    fontFamilyFallbacks: fontFamilyFallbacks,
                  ),
                );
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                ),
                color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding * 0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.eco,
                                color: Colors.green[700],
                                size: 32 * adjustedScaleFactor,
                              ),
                              SizedBox(width: 8 * adjustedScaleFactor),
                              Expanded(
                                child: Text(
                                  entry.key.tr,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                    fontFamilyFallback: fontFamilyFallbacks,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * adjustedScaleFactor),
                          Text(
                            'Temp: ${entry.value['temp_range'][0]}${'degree_celsius'.tr} - ${entry.value['temp_range'][1]}${'degree_celsius'.tr}',
                            style: TextStyle(
                              fontSize: detailFontSize,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              fontFamilyFallback: fontFamilyFallbacks,
                            ),
                          ),
                          Text(
                            'Category: ${(entry.value['category'] as String).tr}',
                            style: TextStyle(
                              fontSize: detailFontSize,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              fontFamilyFallback: fontFamilyFallbacks,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8 * adjustedScaleFactor,
                      bottom: (100 * adjustedScaleFactor - 20 * adjustedScaleFactor) / 2,
                      child: Icon(
                        Icons.chevron_right,
                        size: 20 * adjustedScaleFactor,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class CropInfoView extends StatelessWidget {
  final CropTipsController controller;
  final double adjustedScaleFactor;
  final double padding;
  final double detailFontSize;
  final List<String> fontFamilyFallbacks;

  const CropInfoView({
    super.key,
    required this.controller,
    required this.adjustedScaleFactor,
    required this.padding,
    required this.detailFontSize,
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 36 * adjustedScaleFactor,
                child: DropdownButtonFormField<String>(
                  value: controller.selectedCrop.value.isEmpty ? '' : controller.selectedCrop.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Select Crop for Detail'.tr,
                    hintStyle: TextStyle(
                      fontSize: detailFontSize,
                      color: Colors.grey[500],
                      fontFamilyFallback: fontFamilyFallbacks,
                    ),
                    filled: true,
                    fillColor: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8 * adjustedScaleFactor,
                      horizontal: 10 * adjustedScaleFactor,
                    ),
                  ),
                  menuMaxHeight: 200 * adjustedScaleFactor,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(
                        'Select Crop for Detail'.tr,
                        style: TextStyle(
                          fontSize: detailFontSize * 0.9,
                          color: Colors.grey[500],
                          fontFamilyFallback: fontFamilyFallbacks,
                        ),
                      ),
                    ),
                    ...cropData.keys.map<DropdownMenuItem<String>>((crop) {
                      return DropdownMenuItem<String>(
                        value: crop,
                        child: Text(
                          crop.tr,
                          style: TextStyle(
                            fontSize: detailFontSize * 0.9,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                            fontFamilyFallback: fontFamilyFallbacks,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null && value.isNotEmpty) {
                      controller.selectedCrop.value = value;
                      controller.fetchCropInfo(value);
                    } else {
                      controller.selectedCrop.value = '';
                      controller.cropInfo.value = null;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropDetailSheet extends StatelessWidget {
  final String cropName;
  final Map<String, dynamic> data;
  final ThemeData theme;
  final bool isDarkMode;
  final double scaleFactor;
  final double padding;
  final double headerFontSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;
  final List<String> fontFamilyFallbacks;

  const CropDetailSheet({
    super.key,
    required this.cropName,
    required this.data,
    required this.theme,
    required this.isDarkMode,
    required this.scaleFactor,
    required this.padding,
    required this.headerFontSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scaleFactor),
        ),
        color: theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
              child: Container(
                width: 40 * scaleFactor,
                height: 4 * scaleFactor,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2 * scaleFactor),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cropName,
                          style: TextStyle(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                            fontFamilyFallback: fontFamilyFallbacks,
                          ),
                        ),
                        Icon(
                          Icons.eco,
                          color: Colors.green[700],
                          size: 44 * scaleFactor,
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scaleFactor),
                    Text(
                      (data['category'] as String).tr,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontFamilyFallback: fontFamilyFallbacks,
                      ),
                    ),
                    Divider(
                      color: isDarkMode ? Colors.grey[600]!.withOpacity(0.2) : Colors.grey[200]!.withOpacity(0.2),
                      height: 16 * scaleFactor,
                    ),
                    _buildDetailRow(
                      'Optimal Temp Range'.tr,
                      '${data['temp_range'][0]}${'degree_celsius'.tr} - ${data['temp_range'][1]}${'degree_celsius'.tr}',
                      icon: Icons.thermostat,
                    ),
                    _buildDetailRow(
                      'Weekly Water'.tr,
                      '${data['weekly_water_mm'][0]} ${'millimeters'.tr} - ${data['weekly_water_mm'][1]} ${'millimeters'.tr}',
                      icon: Icons.water_drop,
                    ),
                    _buildDetailRow(
                      'Optimal Humidity'.tr,
                      '${data['humidity_range'][0]}${'percent'.tr} - ${data['humidity_range'][1]}${'percent'.tr}',
                      icon: Icons.opacity,
                    ),
                    _buildDetailRow(
                      'Altitude Range'.tr,
                      '${data['altitude_range_m'][0]} ${'meters'.tr} - ${data['altitude_range_m'][1]} ${'meters'.tr}',
                      icon: Icons.height,
                    ),
                    _buildDetailRow(
                      'Soil Type'.tr,
                      (data['soil_type'] as List<String>).map((soil) => soil.tr).join(', '),
                      icon: Icons.landscape,
                    ),
                    _buildDetailRow(
                      'Growing Season'.tr,
                      (data['growing_season'] as List<String>).map((season) => season.tr).join(', '),
                      icon: Icons.calendar_today,
                    ),
                    _buildDetailRow(
                      'Category'.tr,
                      (data['category'] as String).tr,
                      icon: Icons.category,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8 * scaleFactor),
                  child: Icon(
                    icon,
                    size: 18 * scaleFactor,
                    color: Colors.green[700],
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: detailFontSize,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.grey[900],
                  fontFamilyFallback: fontFamilyFallbacks,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: detailFontSize,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontFamilyFallback: fontFamilyFallbacks,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _parsePlainTextResponse(String response) {
  final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final sections = <Map<String, dynamic>>[];
  String? currentSubheader;

  final headerTranslationMap = {
    'General Information': 'general_information',
    'Growth Recommendations': 'growth_recommendations',
    'Current Weather Impact and Advice': 'current_weather_impact_and_advice',
  };

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('Header: ')) {
      final headerContent = line.replaceFirst('Header: ', '');
      sections.add({
        'type': 'header',
        'content': headerContent,
      });
      currentSubheader = null;
    } else if (line.startsWith('Subheader: ')) {
      var subheaderContent = line.replaceFirst('Subheader: ', '');
      if (headerTranslationMap.containsKey(subheaderContent)) {
        subheaderContent = headerTranslationMap[subheaderContent]!.tr;
      }
      currentSubheader = subheaderContent;
      sections.add({
        'type': 'subheader',
        'content': currentSubheader,
      });
    } else if (line.startsWith('Conclusion: ')) {
      sections.add({
        'type': 'paragraph',
        'content': line.replaceFirst('Conclusion: ', ''),
      });
    } else if (line.startsWith('- ')) {
      sections.add({
        'type': 'bullet',
        'content': line.substring(2),
      });
    } else {
      sections.add({
        'type': 'paragraph',
        'content': line,
      });
    }
  }
  return sections;
}