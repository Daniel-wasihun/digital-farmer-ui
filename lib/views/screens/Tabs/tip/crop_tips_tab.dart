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
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isSmallPhone = size.width < 360;

    // Adjusted scaleFactor for smaller UI
    final double scaleFactor = isLargeTablet ? 1.1 : isTablet ? 0.9 : isSmallPhone ? 0.7 : 0.8;

    // Reduced padding for smaller UI
    final double padding = isLargeTablet ? 16.0 : isTablet ? 12.0 : isSmallPhone ? 8.0 : 10.0;

    // Reduced base font sizes for smaller UI
    const double baseTitleFontSize = 16.0;
    const double baseSubtitleFontSize = 14.0;
    const double baseDetailFontSize = 12.0;

    // Calculate responsive font sizes
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    // Use theme
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Font fallbacks for Amharic
    const fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    // Pre-translate labels
    final cropTipsLabel = 'Crop Tips'.tr;
    final cropInfoLabel = 'Crop Info'.tr;
    final searchHintLabel = 'Search Crops'.tr;
    final selectCropForDetailLabel = 'Select Crop for Detail'.tr;

    // Filtered crops based on search query (cached to avoid recomputation)
    List<MapEntry<String, Map<String, dynamic>>> getFilteredCrops(String query) {
      if (query.isEmpty) {
        return cropData.entries.toList();
      }
      return cropData.entries.where((entry) {
        final translatedCropName = entry.key.tr.toLowerCase();
        return translatedCropName.contains(query.toLowerCase());
      }).toList();
    }

    // Ensure the default value is set in the controller
    if (controller.selectedCrop.value.isEmpty) {
      controller.selectedCrop.value = '';
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.green[50]!.withOpacity(0.8), Colors.green[200]!.withOpacity(0.9)],
          ),
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Header Section with TabBar
                Container(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850]!.withOpacity(0.9) : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: detailFontSize + 2,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                          unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: detailFontSize + 2,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
                          indicator: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 3.0,
                              ),
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: [
                            Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Text(
                                  cropTipsLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Tab(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Text(
                                  cropInfoLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 6.0),
                            child: SizedBox(
                              height: 40 * scaleFactor,
                              child: TextField(
                                controller: controller.searchController,
                                decoration: InputDecoration(
                                  hintText: searchHintLabel,
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: detailFontSize - 1,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: theme.colorScheme.primary,
                                    size: 18 * scaleFactor,
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                                  suffixIcon: Obx(
                                    () => controller.searchQuery.value.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: theme.colorScheme.onSurface,
                                              size: 18 * scaleFactor,
                                            ),
                                            onPressed: controller.clearSearch,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                style: TextStyle(fontSize: detailFontSize - 1),
                                onChanged: (value) {
                                  controller.searchQuery.value = value;
                                },
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(() {
                              final filteredCrops = getFilteredCrops(controller.searchQuery.value);
                              if (filteredCrops.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Crops Found'.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: detailFontSize,
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      fontFamilyFallback: fontFamilyFallbacks,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                );
                              }
                              return Stack(
                                children: [
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: filteredCrops.map<Widget>((entry) {
                                          return _buildCropData(
                                            entry.key.tr,
                                            entry.value,
                                            theme,
                                            detailFontSize,
                                            padding,
                                            scaleFactor,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8 * scaleFactor,
                                    right: 8 * scaleFactor,
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const AIChatScreen(),
                                            transitionsBuilder:
                                                (context, animation, secondaryAnimation, child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;
                                              var tween = Tween(begin: begin, end: end)
                                                  .chain(CurveTween(curve: curve));
                                              var offsetAnimation = animation.drive(tween);
                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(milliseconds: 300),
                                          ),
                                        );
                                      },
                                      backgroundColor: Colors.green[600],
                                      tooltip: 'AI Chat'.tr,
                                      mini: true,
                                      child: Icon(
                                        Icons.psychology,
                                        color: Colors.white,
                                        size: 16 * scaleFactor,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select a Crop for Detailed Info'.tr,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                child: SizedBox(
                                  height: 40 * scaleFactor,
                                  child: DropdownButtonFormField<String>(
                                    value: controller.selectedCrop.value.isEmpty ? '' : controller.selectedCrop.value,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    ),
                                    menuMaxHeight: 200 * scaleFactor,
                                    items: [
                                      // Default option
                                      DropdownMenuItem<String>(
                                        value: '',
                                        child: Text(
                                          selectCropForDetailLabel,
                                          style: TextStyle(
                                            fontSize: detailFontSize,
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                            fontFamilyFallback: fontFamilyFallbacks,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ),
                                      // Crop options
                                      ...cropData.keys.map<DropdownMenuItem<String>>((crop) {
                                        return DropdownMenuItem<String>(
                                          value: crop,
                                          child: Text(
                                            crop.tr,
                                            style: TextStyle(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface,
                                              fontFamilyFallback: fontFamilyFallbacks,
                                            ),
                                            textDirection: TextDirection.ltr,
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
                              const SizedBox(height: 8),
                              Obx(() {
                                if (controller.isCropInfoLoading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (controller.cropInfo.value == null) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AnimatedScale(
                                          scale: controller.selectedCrop.value.isEmpty ? 1.2 : 1.0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                          child: Icon(
                                            Icons.eco,
                                            size: 80 * scaleFactor,
                                            color: theme.colorScheme.primary.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please select a crop to view details'.tr,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: detailFontSize,
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            fontFamilyFallback: fontFamilyFallbacks,
                                          ),
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                final sections = _parsePlainTextResponse(controller.cropInfo.value!);
                                final isAmharicContent = RegExp(r'[\u1200-\u137F]').hasMatch(controller.cropInfo.value!);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isAmharicContent)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.orange, width: 0.5),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber,
                                              color: Colors.orange,
                                              size: 16 * scaleFactor,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Amharic text may not render properly on this device. For best results, use a device with Amharic support.'.tr,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontSize: detailFontSize - 2,
                                                  color: Colors.orange,
                                                ),
                                                textDirection: TextDirection.ltr,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                            offset: const Offset(2, 2),
                                            blurRadius: 6,
                                            spreadRadius: 0.5,
                                          ),
                                          BoxShadow(
                                            color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                            offset: const Offset(-2, -2),
                                            blurRadius: 6,
                                            spreadRadius: 0.5,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(padding),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: sections.asMap().entries.map<Widget>((entry) {
                                            final section = entry.value;
                                            final textDirection = TextDirection.ltr;

                                            if (section['type'] == 'header') {
                                              return Padding(
                                                padding: EdgeInsets.only(bottom: 12 * scaleFactor),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      section['content'],
                                                      style: theme.textTheme.headlineSmall?.copyWith(
                                                        fontSize: titleFontSize,
                                                        fontWeight: FontWeight.bold,
                                                        color: theme.colorScheme.primary,
                                                        fontFamilyFallback: fontFamilyFallbacks,
                                                      ),
                                                      textDirection: textDirection,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Divider(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                                                      thickness: 0.8,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (section['type'] == 'subheader') {
                                              return Padding(
                                                padding: EdgeInsets.only(top: 12 * scaleFactor, bottom: 6 * scaleFactor),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      section['content'],
                                                      style: theme.textTheme.titleLarge?.copyWith(
                                                        fontSize: subtitleFontSize,
                                                        fontWeight: FontWeight.w600,
                                                        color: theme.colorScheme.onSurface,
                                                        fontFamilyFallback: fontFamilyFallbacks,
                                                      ),
                                                      textDirection: textDirection,
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Divider(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                                                      thickness: 0.4,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (section['type'] == 'paragraph') {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 6 * scaleFactor, bottom: 8 * scaleFactor),
                                                child: Text(
                                                  section['content'],
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: detailFontSize,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                                                    fontFamilyFallback: fontFamilyFallbacks,
                                                    height: 1.4,
                                                  ),
                                                  textDirection: textDirection,
                                                  softWrap: true,
                                                ),
                                              );
                                            } else if (section['type'] == 'bullet') {
                                              return Padding(
                                                padding: EdgeInsets.only(left: 6 * scaleFactor, bottom: 6 * scaleFactor),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  textDirection: TextDirection.ltr,
                                                  children: [
                                                    Text(
                                                      '• ',
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: detailFontSize,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                      textDirection: textDirection,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Flexible(
                                                      child: Text(
                                                        section['content'],
                                                        style: theme.textTheme.bodyMedium?.copyWith(
                                                          fontSize: detailFontSize,
                                                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                                                          fontFamilyFallback: fontFamilyFallbacks,
                                                          height: 1.4,
                                                        ),
                                                        textDirection: textDirection,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildCropData(
    String cropName,
    Map<String, dynamic> data,
    ThemeData theme,
    double fontSize,
    double padding,
    double scaleFactor,
  ) {
    return Card(
      elevation: 3,
      color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grass,
                  color: theme.colorScheme.primary,
                  size: 20 * scaleFactor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cropName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: fontSize + 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
            Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              height: 12,
              thickness: 0.8,
            ),
            _buildDataRow(
              icon: Icons.thermostat,
              label: 'Optimal Temp Range'.tr,
              value: '${data['temp_range'][0]}${'degree_celsius'.tr} - ${data['temp_range'][1]}${'degree_celsius'.tr}',
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.water_drop,
              label: 'Weekly Water'.tr,
              value: '${data['weekly_water_mm'][0]} ${'millimeters'.tr} - ${data['weekly_water_mm'][1]} ${'millimeters'.tr}',
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.opacity,
              label: 'Optimal Humidity'.tr,
              value: '${data['humidity_range'][0]}${'percent'.tr} - ${data['humidity_range'][1]}${'percent'.tr}',
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.height,
              label: 'Altitude Range'.tr,
              value: '${data['altitude_range_m'][0]} ${'meters'.tr} - ${data['altitude_range_m'][1]} ${'meters'.tr}',
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.landscape,
              label: 'Soil Type'.tr,
              value: (data['soil_type'] as List<String>).map((soil) => soil.tr).join(', '),
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.calendar_today,
              label: 'Growing Season'.tr,
              value: (data['growing_season'] as List<String>).map((season) => season.tr).join(', '),
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
            _buildDataRow(
              icon: Icons.category,
              label: 'Category'.tr,
              value: (data['category'] as String).tr,
              theme: theme,
              fontSize: fontSize,
              scaleFactor: scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required double fontSize,
    required double scaleFactor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.8),
            size: 16 * scaleFactor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}