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

    // Dynamic scaleFactor for better responsiveness
    final double scaleFactor = isLargeTablet
        ? 1.3
        : isTablet
            ? 1.1
            : isSmallPhone
                ? 0.85
                : 1.0;

    // Responsive padding
    final double padding = isLargeTablet
        ? 20.0
        : isTablet
            ? 16.0
            : isSmallPhone
                ? 12.0
                : 14.0;

    // Base font sizes
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

    // Determine font family based on locale
    final isAmharic = Get.locale?.languageCode == 'am';
    final fontFamily = isAmharic ? 'NotoSansEthiopic' : null; // Fallback to default (e.g., Roboto) for English

    // Pre-translate labels
    final cropTipsLabel = 'Crop Tips'.tr;
    final cropInfoLabel = 'Crop Info'.tr;
    final searchHintLabel = 'Search Crops'.tr;

    // Filtered crops based on search query
    List<MapEntry<String, Map<String, dynamic>>> getFilteredCrops() {
      if (controller.searchQuery.value.isEmpty) {
        return cropData.entries.toList();
      }
      return cropData.entries.where((entry) {
        final translatedCropName = entry.key.tr.toLowerCase();
        return translatedCropName.contains(controller.searchQuery.value.toLowerCase());
      }).toList();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.green[50]!, Colors.green[100]!],
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: detailFontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: fontFamily,
                ),
                unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: detailFontSize,
                  fontFamily: fontFamily,
                ),
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: theme.colorScheme.primary,
                tabs: [
                  Tab(text: cropTipsLabel),
                  Tab(text: cropInfoLabel),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Crop Tips Tab with Search
                    Column(
                      children: [
                        // Search bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8.0),
                          child: TextField(
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              hintText: searchHintLabel,
                              hintStyle: TextStyle(fontFamily: fontFamily),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: theme.colorScheme.primary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                              ),
                              suffixIcon: Obx(
                                () => controller.searchQuery.value.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: controller.clearSearch,
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                            onChanged: (value) {
                              controller.searchQuery.value = value;
                            },
                            style: TextStyle(fontFamily: fontFamily),
                          ),
                        ),
                        // Crop list
                        Expanded(
                          child: Obx(
                            () {
                              final filteredCrops = getFilteredCrops();
                              if (filteredCrops.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Crops Found'.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: detailFontSize,
                                      color: theme.colorScheme.onSurface,
                                      fontFamily: fontFamily,
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
                                            fontFamily,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16 * scaleFactor,
                                    right: 16 * scaleFactor,
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
                                      mini: true,
                                      child: const Icon(
                                        Icons.psychology,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Crop Info Tab
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
                                fontFamily: fontFamily,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            DropdownButton<String>(
                              value: controller.selectedCrop.value,
                              isExpanded: true,
                              items: cropData.keys.map<DropdownMenuItem<String>>((crop) {
                                return DropdownMenuItem<String>(
                                  value: crop,
                                  child: Text(
                                    crop.tr,
                                    style: TextStyle(fontFamily: fontFamily),
                                    textDirection: TextDirection.ltr,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCrop.value = value;
                                  controller.fetchCropInfo(value); // Fetch crop info from backend
                                }
                              },
                            ),
                            SizedBox(height: 8 * scaleFactor),
                            Obx(
                              () {
                                if (controller.isCropInfoLoading.value) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (controller.cropInfo.value == null) {
                                  return Center(
                                    child: Text(
                                      'No Data Available'.tr,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: detailFontSize,
                                        color: theme.colorScheme.onSurface,
                                        fontFamily: fontFamily,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  );
                                }
                                // Parse the plain text response
                                final sections = _parsePlainTextResponse(controller.cropInfo.value!);
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDarkMode ? Colors.black54 : Colors.grey[300]!,
                                        offset: Offset(4, 4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: isDarkMode ? Colors.grey[900]! : Colors.white,
                                        offset: Offset(-4, -4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(padding),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: sections.map<Widget>((section) {
                                        if (section['type'] == 'header') {
                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 8 * scaleFactor),
                                            child: Text(
                                              section['content'],
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                                fontFamily: fontFamily,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                          );
                                        } else if (section['type'] == 'subheader') {
                                          return Padding(
                                            padding: EdgeInsets.only(top: 12 * scaleFactor, bottom: 4 * scaleFactor),
                                            child: Text(
                                              section['content'],
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontSize: subtitleFontSize,
                                                fontWeight: FontWeight.bold, // Bold subheader
                                                color: theme.colorScheme.onSurface,
                                                fontFamily: fontFamily,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                          );
                                        } else if (section['type'] == 'paragraph') {
                                          return Padding(
                                            padding: EdgeInsets.only(left: 16 * scaleFactor, bottom: 4 * scaleFactor),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• ',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: detailFontSize,
                                                    color: theme.colorScheme.onSurface,
                                                    fontFamily: fontFamily,
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Text(
                                                    section['content'],
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontSize: detailFontSize,
                                                      color: theme.colorScheme.onSurface,
                                                      fontFamily: fontFamily,
                                                    ),
                                                    textDirection: TextDirection.ltr,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (section['type'] == 'bullet') {
                                          return Padding(
                                            padding: EdgeInsets.only(left: 16 * scaleFactor, bottom: 4 * scaleFactor),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• ',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: detailFontSize,
                                                    color: theme.colorScheme.onSurface,
                                                    fontFamily: fontFamily,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    section['content'],
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontSize: detailFontSize,
                                                      color: theme.colorScheme.onSurface,
                                                      fontFamily: fontFamily,
                                                    ),
                                                    textDirection: TextDirection.ltr,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return SizedBox.shrink();
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
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
    );
  }

  // Parser for the plain text response with Header:, Subheader:, and Conclusion:
  List<Map<String, dynamic>> _parsePlainTextResponse(String response) {
    final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final sections = <Map<String, dynamic>>[];
    String? currentSubheader;

    for (var line in lines) {
      line = line.trim();
      // Check for main header (Header: )
      if (line.startsWith('Header: ')) {
        sections.add({
          'type': 'header',
          'content': line.replaceFirst('Header: ', ''),
        });
        currentSubheader = null;
      }
      // Check for subheader (Subheader: )
      else if (line.startsWith('Subheader: ')) {
        currentSubheader = line.replaceFirst('Subheader: ', '');
        sections.add({
          'type': 'subheader',
          'content': currentSubheader,
        });
      }
      // Check for conclusion (Conclusion: )
      else if (line.startsWith('Conclusion: ')) {
        sections.add({
          'type': 'paragraph',
          'content': line.replaceFirst('Conclusion: ', ''),
        });
      }
      // Check for bullet points (- Item)
      else if (line.startsWith('- ')) {
        sections.add({
          'type': 'bullet',
          'content': line.substring(2),
        });
      }
      // Treat other lines as paragraphs
      else {
        sections.add({
          'type': 'paragraph',
          'content': line,
        });
      }
    }

    return sections;
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    double fontSize,
    String? fontFamily, {
    bool isTitle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: isTitle ? FontWeight.w600 : FontWeight.normal,
              color: isTitle ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontFamily: fontFamily,
            ),
            textDirection: TextDirection.ltr,
          ),
          if (!isTitle)
            Flexible(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCropData(
    String cropName,
    Map<String, dynamic> data,
    ThemeData theme,
    double fontSize,
    double padding,
    String? fontFamily,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      shadowColor: theme.cardTheme.shadowColor,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cropName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
                fontFamily: fontFamily,
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 4),
            _buildDetailRow(
              'Optimal Temp Range'.tr,
              '${data['temp_range'][0]}${'degree_celsius'.tr} - ${data['temp_range'][1]}${'degree_celsius'.tr}',
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Weekly Water'.tr,
              '${data['weekly_water_mm'][0]} ${'millimeters'.tr} - ${data['weekly_water_mm'][1]} ${'millimeters'.tr}',
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Optimal Humidity'.tr,
              '${data['humidity_range'][0]}${'percent'.tr} - ${data['humidity_range'][1]}${'percent'.tr}',
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Altitude Range'.tr,
              '${data['altitude_range_m'][0]} ${'meters'.tr} - ${data['altitude_range_m'][1]} ${'meters'.tr}',
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Soil Type'.tr,
              (data['soil_type'] as List<String>).map((soil) => soil.tr).join(', '),
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Growing Season'.tr,
              (data['growing_season'] as List<String>).map((season) => season.tr).join(', '),
              theme,
              fontSize,
              fontFamily,
            ),
            _buildDetailRow(
              'Category'.tr,
              (data['category'] as String).tr,
              theme,
              fontSize,
              fontFamily,
            ),
          ],
        ),
      ),
    );
  }
}