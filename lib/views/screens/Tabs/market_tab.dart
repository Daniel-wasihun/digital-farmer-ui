import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/market_controller.dart';

// Utility method to capitalize the first letter of a string
String capitalizeFirstLetter(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1).toLowerCase();

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketController controller = Get.put(MarketController());
    final scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.1 : 0.9; // Adjusted scaleFactor for smaller content

    // Theme and dark mode
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Responsive font sizes (made smaller)
    const double baseTitleFontSize = 16.0;    // Reduced from 20.0
    const double baseSubtitleFontSize = 12.0; // Reduced from 16.0
    const double baseDetailFontSize = 10.0;   // Reduced from 14.0
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    final double detailFontSize = baseDetailFontSize * scaleFactor;

    // Reduced padding for compactness
    const double padding = 12.0; // Reduced from 16.0

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
              // Header
              Padding(
                padding: const EdgeInsets.all(12.0), // Reduced padding
                child: Text(
                  'market'.tr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    shadows: const [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Category Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Reduced padding
                child: Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        decoration: InputDecoration(
                          labelText: 'category'.tr,
                          labelStyle: TextStyle(
                            fontSize: detailFontSize,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.0, // Reduced border width
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
                        ),
                        style: TextStyle(
                          fontSize: detailFontSize,
                          color: theme.colorScheme.onSurface,
                        ),
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary,
                          size: 16 * scaleFactor, // Reduced icon size
                        ),
                        items: ['All', ...controller.cropData.values
                            .map((crop) => crop['category'] as String)
                            .toSet()
                            ].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              capitalizeFirstLetter(category),
                              style: TextStyle(
                                fontSize: detailFontSize,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateCategory(value);
                          }
                        },
                      ),
                    )),
              ),
              // Crop List
              Expanded(
                child: Obx(() {
                  final filteredCrops = controller.getFilteredCrops();
                  return filteredCrops.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 40 * scaleFactor, // Reduced icon size
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8), // Reduced spacing
                              Text(
                                'no_crops_found'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: detailFontSize,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Reduced padding
                          itemCount: filteredCrops.length,
                          itemBuilder: (context, index) {
                            final cropEntry = filteredCrops[index];
                            final cropName = cropEntry.key;
                            final category = cropEntry.value['category'];

                            // Simulate market price in ETB (per quintal/100kg)
                            final basePrice = 1000 + controller.random.nextDouble() * 4000;
                            final etbPrice = basePrice;
                            final usdPrice = etbPrice * controller.etbToUsd;

                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Card(
                                elevation: 2, // Matches WeatherTab.dart
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Matches WeatherTab.dart
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8.0), // Matches WeatherTab.dart
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12.0), // Reduced padding
                                  title: Hero(
                                    tag: 'crop-$cropName',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        cropName.replaceAll('_', ' ').toUpperCase(),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontSize: subtitleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4), // Reduced spacing
                                      Text(
                                        '${'category'.tr}: ${capitalizeFirstLetter(category)}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: detailFontSize,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 2), // Reduced spacing
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.currency_exchange,
                                            size: 12 * scaleFactor, // Reduced icon size
                                            color: Colors.green[700],
                                          ),
                                          const SizedBox(width: 2), // Reduced spacing
                                          Text(
                                            'ETB: ${NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2).format(etbPrice)}/quintal',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2), // Reduced spacing
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.currency_exchange,
                                            size: 12 * scaleFactor, // Reduced icon size
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 2), // Reduced spacing
                                          Text(
                                            'USD: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(usdPrice)}/quintal',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: detailFontSize,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12 * scaleFactor, // Reduced icon size
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  onTap: () {
                                    Get.snackbar(
                                      'details'.tr,
                                      '${'details_for'.tr} $cropName',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      colorText: theme.colorScheme.onSurface,
                                      margin: const EdgeInsets.all(12), // Reduced margin
                                      borderRadius: 12,
                                      snackStyle: SnackStyle.FLOATING,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            'refresh'.tr,
            'Prices refreshed'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            colorText: theme.colorScheme.onSurface,
            margin: const EdgeInsets.all(12), // Reduced margin
            borderRadius: 12,
            snackStyle: SnackStyle.FLOATING,
          );
        },
        backgroundColor: Colors.green[600],
        tooltip: 'Refresh Prices'.tr,
        mini: true,
        child: Icon(
          Icons.refresh,
          color: Colors.white,
          size: 12 * scaleFactor, // Reduced icon size
        ),
      ),
    );
  }
}