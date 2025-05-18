import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/crop_tips_controller.dart';
import '../../../../utils/crop_data.dart';
import 'ai_chat_screen.dart';

class CropTipsTab extends StatelessWidget {
  const CropTipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CropTipsController());
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final adjustedScaleFactor = scaleFactor * 1.1;
    final padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    final headerFontSize = (32.0 * adjustedScaleFactor).clamp(22.0, 38.0);
    final titleFontSize = (20.0 * adjustedScaleFactor).clamp(16.0, 28.0);
    final subtitleFontSize = (16.0 * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final detailFontSize = (14.0 * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    final crossAxisCount = screenWidth < 360 ? 1 : screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4;
    const fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    // Initialize selectedCrop only if not already set
    if (controller.selectedCrop.value.isEmpty) {
      controller.selectedCrop.value = 'select_crop';
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).cardTheme.color ??
                      (Theme.of(context).brightness == Brightness.dark ? Colors.blueGrey[900] : Colors.white),
                  child: TabBar(
                    tabs: [Tab(text: 'Crop Tips'.tr), Tab(text: 'Crop Info'.tr)],
                    labelStyle: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w700,
                        fontFamilyFallback: fontFamilyFallbacks),
                    unselectedLabelStyle: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        fontFamilyFallback: fontFamilyFallbacks),
                    indicatorColor: Colors.green[700],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      CropTipsView(
                        controller: controller,
                        scaleFactor: adjustedScaleFactor,
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
                        scaleFactor: adjustedScaleFactor,
                        padding: padding,
                        subtitleFontSize: subtitleFontSize,
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
            heroTag: 'ai_chat_page',
            onPressed: () => Get.to(() => const AIChatScreen(), transition: Transition.noTransition),
            backgroundColor: Colors.green[700],
            tooltip: 'Chat'.tr,
            shape: const CircleBorder(),
            child: Icon(Icons.message, color: Colors.white, size: 24 * adjustedScaleFactor),
          ),
        ),
      ),
    );
  }
}

class CropInfoView extends StatelessWidget {
  final CropTipsController controller;
  final double scaleFactor;
  final double padding;
  final double subtitleFontSize;
  final double detailFontSize;
  final List<String> fontFamilyFallbacks;

  const CropInfoView({
    super.key,
    required this.controller,
    required this.scaleFactor,
    required this.padding,
    required this.subtitleFontSize,
    required this.detailFontSize,
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDarkMode ? Colors.blueGrey[900] : Colors.white);

    return Container(
      color: cardColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedCrop.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'select_crop'.tr,
                      hintStyle: TextStyle(fontSize: detailFontSize, color: Colors.grey[500]),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'select_crop',
                        child: Text('select_crop'.tr,
                            style: TextStyle(
                                fontSize: detailFontSize, fontFamilyFallback: fontFamilyFallbacks)),
                      ),
                      ...cropData.keys.map((crop) => DropdownMenuItem<String>(
                            value: crop,
                            child: Text(crop.tr,
                                style: TextStyle(
                                    fontSize: detailFontSize, fontFamilyFallback: fontFamilyFallbacks)),
                          )),
                    ],
                    onChanged: (value) async {
                      if (value != null && value != 'select_crop') {
                        controller.selectedCrop.value = value;
                        await controller.fetchCropInfo(value);
                      } else {
                        controller.selectedCrop.value = 'select_crop';
                        controller.cropInfo.value = null; // Clear info if 'select_crop' is chosen
                      }
                    },
                  )),
            ),
            SizedBox(height: padding),
            Obx(() {
              if (controller.isCropInfoLoading.value) {
                return Center(child: CircularProgressIndicator(color: Colors.green[700]));
              }
              if (controller.cropInfo.value == null) {
                return Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco,
                          color: Colors.green[700],
                          size: 150 * scaleFactor,
                        ),
                        SizedBox(height: padding),
                        Text(
                          controller.selectedCrop.value == 'select_crop'
                              ? 'select_crop_to_view_details'.tr
                              : 'no_data_available'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1.1,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            fontFamilyFallback: fontFamilyFallbacks,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final sections = _parsePlainTextResponse(controller.cropInfo.value!);
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sections.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.all(padding * 0.8),
                  child: _buildSectionContent(
                      sections[index], isDarkMode, scaleFactor, fontFamilyFallbacks),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(
      Map<String, dynamic> section, bool isDarkMode, double scaleFactor, List<String> fontFamilyFallbacks) {
    final textColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];
    final accentColor = Colors.green[700]!;
    final fontSize = (14.0 * scaleFactor * 0.9).clamp(10.0, 18.0);

    switch (section['type']) {
      case 'header':
        return Row(
          children: [
            Icon(Icons.eco, color: accentColor, size: 24 * scaleFactor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section['content'].tr,
                style: TextStyle(
                    fontSize: (32.0 * scaleFactor).clamp(22.0, 38.0),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontFamilyFallback: fontFamilyFallbacks),
              ),
            ),
          ],
        );
      case 'subheader':
        return Row(
          children: [
            Container(width: 4, height: 20, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section['content'],
                style: TextStyle(
                    fontSize: (20.0 * scaleFactor).clamp(16.0, 28.0),
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontFamilyFallback: fontFamilyFallbacks),
              ),
            ),
          ],
        );
      case 'bullet':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.circle, size: 6, color: Colors.green)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section['content'],
                style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontFamilyFallback: fontFamilyFallbacks,
                    height: 1.4),
              ),
            ),
          ],
        );
      case 'paragraph':
        return Text(
          section['content'],
          style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontFamilyFallback: fontFamilyFallbacks,
              height: 1.4),
        );
      case 'bold':
        return Text(
          section['content'],
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[900],
              fontFamilyFallback: fontFamilyFallbacks),
        );
      case 'italic':
        return Text(
          section['content'],
          style: TextStyle(
              fontSize: fontSize,
              fontStyle: FontStyle.italic,
              color: textColor,
              fontFamilyFallback: fontFamilyFallbacks),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// CropTipsView, CropDetailSheet, and _parsePlainTextResponse remain unchanged
class CropTipsView extends StatelessWidget {
  final CropTipsController controller;
  final double scaleFactor;
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
    required this.scaleFactor,
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
    final searchFocusNode = FocusNode();

    void clearSearch() {
      controller.searchController.clear();
      controller.searchQuery.value = '';
      searchFocusNode.unfocus();
    }

    return Container(
      color: theme.cardTheme.color ?? (isDarkMode ? Colors.blueGrey[900] : Colors.white),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
            child: Column(
              children: [
                SizedBox(
                  height: 40 * scaleFactor,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchController,
                    builder: (context, textValue, _) => TextField(
                      controller: controller.searchController,
                      focusNode: searchFocusNode,
                      onChanged: (value) => controller.searchQuery.value = value,
                      style: TextStyle(
                          fontSize: detailFontSize,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                          fontFamilyFallback: fontFamilyFallbacks),
                      decoration: InputDecoration(
                        hintText: 'Search Crops'.tr,
                        hintStyle: TextStyle(
                            fontSize: detailFontSize,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                            fontFamilyFallback: fontFamilyFallbacks),
                        prefixIcon: Icon(Icons.search,
                            size: 18 * scaleFactor, color: theme.colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear,
                              size: 18 * scaleFactor, color: theme.colorScheme.onSurface),
                          onPressed: textValue.text.isNotEmpty || searchFocusNode.hasFocus
                              ? clearSearch
                              : null,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10 * scaleFactor),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary, width: 1.2 * scaleFactor),
                        ),
                        filled: true,
                        fillColor: theme.cardTheme.color ??
                            (isDarkMode ? Colors.blueGrey[900] : Colors.white),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10 * scaleFactor, horizontal: 10 * scaleFactor),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: padding * 0.5),
                SizedBox(
                  height: 32 * scaleFactor,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.getCategories().length,
                    itemBuilder: (context, index) {
                      final category = controller.getCategories()[index];
                      return Obx(() {
                        final isSelected = controller.selectedCategory.value == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => controller.selectedCategory.value = category,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green[700] : theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isSelected ? Colors.green[700]! : Colors.grey[500]!),
                              ),
                              child: Text(
                                category.tr,
                                style: TextStyle(
                                  fontSize: detailFontSize * 0.9,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : null,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredCrops = controller.getFilteredCrops();
              if (filteredCrops.isEmpty) {
                return Center(
                  child: Text(
                    'No Crops Found'.tr,
                    style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontFamilyFallback: fontFamilyFallbacks),
                  ),
                );
              }
              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3 / 1.6,
                ),
                itemCount: filteredCrops.length,
                itemBuilder: (context, index) {
                  final entry = filteredCrops[index];
                  return Card(
                    color: isDarkMode ? Colors.blueGrey[900] : Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CropDetailSheet(
                          cropName: entry.key.tr,
                          data: entry.value,
                          theme: theme,
                          isDarkMode: isDarkMode,
                          scaleFactor: scaleFactor,
                          padding: padding,
                          headerFontSize: headerFontSize,
                          titleFontSize: titleFontSize,
                          subtitleFontSize: subtitleFontSize,
                          detailFontSize: detailFontSize,
                          fontFamilyFallbacks: fontFamilyFallbacks,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(padding * 0.6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.eco, color: Colors.green[700], size: 20 * scaleFactor),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          entry.key.tr,
                                          style: TextStyle(
                                            fontSize: subtitleFontSize,
                                            fontWeight: FontWeight.w900,
                                            fontFamilyFallback: fontFamilyFallbacks,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${'temp_label'.tr}: ${entry.value['temp_range'][0]}${'degree_celsius'.tr} - ${entry.value['temp_range'][1]}${'degree_celsius'.tr}',
                                    style: TextStyle(
                                      fontSize: detailFontSize * 0.95,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      fontFamilyFallback: fontFamilyFallbacks,
                                    ),
                                  ),
                                  Text(
                                    '${'category_label'.tr}: ${(entry.value['category'] as String).tr}',
                                    style: TextStyle(
                                      fontSize: detailFontSize,
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      fontFamilyFallback: fontFamilyFallbacks,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              size: 24 * scaleFactor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
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
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black54,
          dismissible: true,
          onDismiss: () => Navigator.pop(context),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.75,
            builder: (context, scrollController) => GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? (isDarkMode ? Colors.blueGrey[900] : Colors.white),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cropName,
                                    style: TextStyle(
                                        fontSize: headerFontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamilyFallback: fontFamilyFallbacks)),
                                Icon(Icons.eco, color: Colors.green[700], size: 36),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text((data['category'] as String).tr,
                                style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                    fontFamilyFallback: fontFamilyFallbacks)),
                            const Divider(height: 16),
                            _buildDetailRow('optimal_temp_range'.tr,
                                '${data['temp_range'][0]}${'degree_celsius'.tr} - ${data['temp_range'][1]}${'degree_celsius'.tr}',
                                Icons.thermostat),
                            _buildDetailRow('weekly_water'.tr,
                                '${data['weekly_water_mm'][0]}${'millimeters'.tr} - ${data['weekly_water_mm'][1]}${'millimeters'.tr}',
                                Icons.water_drop),
                            _buildDetailRow('optimal_humidity'.tr,
                                '${data['humidity_range'][0]}% - ${data['humidity_range'][1]}%', Icons.opacity),
                            _buildDetailRow('altitude_range'.tr,
                                '${data['altitude_range_m'][0]}${'meters'.tr} - ${data['altitude_range_m'][1]}${'meters'.tr}',
                                Icons.height),
                            _buildDetailRow('soil_type'.tr,
                                (data['soil_type'] as List<String>).map((soil) => soil.tr).join(', '),
                                Icons.landscape),
                            _buildDetailRow('growing_season'.tr,
                                (data['growing_season'] as List<String>).map((season) => season.tr).join(', '),
                                Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: detailFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamilyFallback: fontFamilyFallbacks)),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: detailFontSize,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontFamilyFallback: fontFamilyFallbacks),
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
  final headerTranslationMap = {
    'Crop Overview': 'crop_overview',
    'Weather Impact': 'weather_impact',
    'Growth Tips': 'growth_tips',
    'Pest Management': 'pest_management',
    'Soil Preparation': 'soil_preparation',
  };

  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('Header: ')) {
      var content = line.replaceFirst('Header: ', '');
      if (headerTranslationMap.containsKey(content)) {
        content = headerTranslationMap[content]!.tr;
      }
      sections.add({'type': 'header', 'content': content});
    } else if (line.startsWith('Subheader: ')) {
      var content = line.replaceFirst('Subheader: ', '');
      if (headerTranslationMap.containsKey(content)) {
        content = headerTranslationMap[content]!.tr;
      }
      sections.add({'type': 'subheader', 'content': content});
    } else if (line.startsWith('Conclusion: ')) {
      sections.add({'type': 'paragraph', 'content': line.replaceFirst('Conclusion: ', '')});
    } else if (line.startsWith('- ')) {
      sections.add({'type': 'bullet', 'content': line.substring(2)});
    } else if (line.startsWith('**') && line.endsWith('**')) {
      sections.add({'type': 'bold', 'content': line.replaceAll('**', '')});
    } else if (line.startsWith('_') && line.endsWith('_')) {
      sections.add({'type': 'italic', 'content': line.replaceAll('_', '')});
    } else {
      sections.add({'type': 'paragraph', 'content': line});
    }
  }
  return sections;
}