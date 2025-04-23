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
    final double scaleFactor = isLargeTablet ? 1.3 : isTablet ? 1.1 : isSmallPhone ? 0.85 : 1.0;

    // Responsive padding
    final double padding = isLargeTablet ? 24.0 : isTablet ? 20.0 : isSmallPhone ? 12.0 : 16.0;

    // Base font sizes
    const double baseTitleFontSize = 20.0;
    const double baseSubtitleFontSize = 18.0;
    const double baseDetailFontSize = 16.0;

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
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.green[50]!.withOpacity(0.8), Colors.green[200]!.withOpacity(0.9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture,
                      color: theme.colorScheme.primary,
                      size: 28 * scaleFactor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Teff'.tr,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 26 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontFamilyFallback: fontFamilyFallbacks,
                      ),
                      textDirection: Get.locale?.languageCode == 'am' ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              DefaultTabController(
                length: 2,
                child: Expanded(
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: detailFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: detailFontSize,
                            fontWeight: FontWeight.w400,
                          ),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                          indicator: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tabs: [
                            Tab(text: cropTipsLabel),
                            Tab(text: cropInfoLabel),
                          ],
                        ),
                      ),
                      // Tab Bar View
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Crop Tips Tab with Search
                            Column(
                              children: [
                                // Search Bar
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12.0),
                                  child: TextField(
                                    controller: controller.searchController,
                                    decoration: InputDecoration(
                                      hintText: searchHintLabel,
                                      hintStyle: TextStyle(
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        fontSize: detailFontSize,
                                      ),
                                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                                      filled: true,
                                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                      ),
                                      suffixIcon: Obx(
                                        () => controller.searchQuery.value.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                                                onPressed: controller.clearSearch,
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.searchQuery.value = value;
                                    },
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                                // Crop List
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
                                              child: const Icon(
                                                Icons.psychology,
                                                color: Colors.white,
                                                size: 28,
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
                                        fontFamilyFallback: fontFamilyFallbacks,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                    SizedBox(height: 12 * scaleFactor),
                                    DropdownButtonFormField<String>(
                                      value: controller.selectedCrop.value,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                        ),
                                      ),
                                      items: cropData.keys.map<DropdownMenuItem<String>>((crop) {
                                        return DropdownMenuItem<String>(
                                          value: crop,
                                          child: Text(
                                            crop.tr,
                                            style: TextStyle(
                                              fontSize: detailFontSize,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.selectedCrop.value = value;
                                          controller.fetchCropInfo(value);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 12 * scaleFactor),
                                    Obx(
                                      () {
                                        if (controller.isCropInfoLoading.value) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: theme.colorScheme.primary,
                                            ),
                                          );
                                        }
                                        if (controller.cropInfo.value == null) {
                                          return Center(
                                            child: Text(
                                              'No Data Available'.tr,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: detailFontSize,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                fontFamilyFallback: fontFamilyFallbacks,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                          );
                                        }
                                        print('Crop Info Response: ${controller.cropInfo.value}');

                                        // Parse the plain text response
                                        final sections = _parsePlainTextResponse(controller.cropInfo.value!);
                                        final isAmharicContent = RegExp(r'[\u1200-\u137F]').hasMatch(controller.cropInfo.value!);

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Amharic rendering warning
                                            if (isAmharicContent)
                                              Container(
                                                margin: EdgeInsets.only(bottom: 12 * scaleFactor),
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.orange, width: 1),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warning_amber,
                                                      color: Colors.orange,
                                                      size: 20 * scaleFactor,
                                                    ),
                                                    SizedBox(width: 8),
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
                                            // Crop Info Content
                                            AnimatedContainer(
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
                                                  children: sections.asMap().entries.map<Widget>((entry) {
                                                    final index = entry.key;
                                                    final section = entry.value;
                                                    final isAmharic = RegExp(r'[\u1200-\u137F]').hasMatch(section['content']);
                                                    final textDirection = TextDirection.ltr; // Force LTR for all content

                                                    if (section['type'] == 'header') {
                                                      return Padding(
                                                        padding: EdgeInsets.only(bottom: 16 * scaleFactor),
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
                                                            SizedBox(height: 8 * scaleFactor),
                                                            Divider(
                                                              color: theme.colorScheme.onSurface.withOpacity(0.2),
                                                              thickness: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else if (section['type'] == 'subheader') {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 16 * scaleFactor, bottom: 8 * scaleFactor),
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
                                                            SizedBox(height: 4 * scaleFactor),
                                                            Divider(
                                                              color: theme.colorScheme.onSurface.withOpacity(0.1),
                                                              thickness: 0.5,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else if (section['type'] == 'paragraph') {
                                                      return Padding(
                                                        padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 12 * scaleFactor),
                                                        child: Text(
                                                          section['content'],
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontSize: detailFontSize,
                                                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                                                            fontFamilyFallback: fontFamilyFallbacks,
                                                            height: 1.5,
                                                          ),
                                                          textDirection: textDirection,
                                                          softWrap: true,
                                                        ),
                                                      );
                                                    } else if (section['type'] == 'bullet') {
                                                      return Padding(
                                                        padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 8 * scaleFactor),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          textDirection: TextDirection.ltr, // Force LTR for bullet points
                                                          children: [
                                                            Text(
                                                              '• ',
                                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                                fontSize: detailFontSize,
                                                                color: theme.colorScheme.onSurface,
                                                              ),
                                                              textDirection: textDirection,
                                                            ),
                                                            SizedBox(width: 4 * scaleFactor),
                                                            Flexible(
                                                              child: Text(
                                                                section['content'],
                                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                                  fontSize: detailFontSize,
                                                                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                                                                  fontFamilyFallback: fontFamilyFallbacks,
                                                                  height: 1.5,
                                                                ),
                                                                textDirection: textDirection,
                                                                softWrap: true,
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
                                            ),
                                          ],
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
      if (line.startsWith('Header: ')) {
        sections.add({
          'type': 'header',
          'content': line.replaceFirst('Header: ', ''),
        });
        currentSubheader = null;
      } else if (line.startsWith('Subheader: ')) {
        currentSubheader = line.replaceFirst('Subheader: ', '');
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
      elevation: 4,
      color: theme.cardTheme.color ?? (theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Name Header
            Row(
              children: [
                Icon(
                  Icons.grass,
                  color: theme.colorScheme.primary,
                  size: 24 * scaleFactor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cropName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL'],
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
            Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              height: 16,
              thickness: 1,
            ),
            // Crop Data Rows
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
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withOpacity(0.8),
            size: 20 * scaleFactor,
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL'],
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL'],
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