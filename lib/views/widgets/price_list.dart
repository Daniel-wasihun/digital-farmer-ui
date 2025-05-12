import 'package:agri/controllers/market_controller.dart';
import 'package:agri/controllers/price_controller.dart';
import 'package:agri/models/crop_price.dart';
import 'package:agri/utils/app_utils.dart';
import 'package:agri/views/widgets/price_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceList extends StatelessWidget {
  const PriceList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final scaleFactor =
        (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final adjustedScaleFactor = scaleFactor * 1.1;
    final padding =
        (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    const double baseHeaderFontSize = 32.0;
    const double baseTitleFontSize = 20.0;
    const double baseCropNameFontSize = 18.0;
    const double baseSubtitleFontSize = 16.0;
    const double baseDetailFontSize = 14.0;

    final headerFontSize =
        (baseHeaderFontSize * adjustedScaleFactor).clamp(22.0, 38.0);
    final titleFontSize =
        (baseTitleFontSize * adjustedScaleFactor).clamp(16.0, 28.0);
    final cropNameFontSize =
        (baseCropNameFontSize * adjustedScaleFactor).clamp(14.0, 24.0);
    final subtitleFontSize =
        (baseSubtitleFontSize * adjustedScaleFactor * 0.9).clamp(12.0, 20.0);
    final detailFontSize =
        (baseDetailFontSize * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    const fontFamilyFallback = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    final crossAxisCount = screenWidth < 360
        ? 1
        : screenWidth < 600
            ? 2
            : screenWidth < 900
                ? 3
                : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isLargeTablet = constraints.maxWidth > 900;
        final isSmallPhone = constraints.maxWidth < 360;
        final cardWidth = constraints.maxWidth *
            (isLargeTablet ? 0.45 : isTablet ? 0.48 : isSmallPhone ? 0.98 : 0.95);

        return Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(padding * 0.8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? Colors.grey[900]!.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black26 : Colors.grey[200]!,
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.green[400]! : Colors.green[700]!),
                  strokeWidth: 3 * adjustedScaleFactor,
                  backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                ),
              ),
            );
          }

          final filteredPrices = controller.filteredPrices;

          if (filteredPrices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60 * adjustedScaleFactor,
                    height: 60 * adjustedScaleFactor,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          isDarkMode ? Colors.green[600]! : Colors.green[500]!,
                          isDarkMode ? Colors.green[900]! : Colors.green[800]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.green[400]!.withOpacity(0.3)
                              : Colors.green[600]!.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_mall_rounded,
                      size: 30 * adjustedScaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8 * adjustedScaleFactor),
                  Text(
                    'No Prices Available'.tr,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.grey[900]!,
                      fontFamilyFallback: fontFamilyFallback,
                    ),
                  ),
                  SizedBox(height: 4 * adjustedScaleFactor),
                  Text(
                    'Add prices or try different filters'.tr,
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontFamilyFallback: fontFamilyFallback,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8 * adjustedScaleFactor),
                  ElevatedButton(
                    onPressed: () => Get.to(
                      () => const PriceScreen(),
                      binding: BindingsBuilder(() {
                        Get.put(PriceController());
                      }),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.green[300] : Colors.green[500],
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * adjustedScaleFactor,
                        vertical: 8 * adjustedScaleFactor,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8 * adjustedScaleFactor)),
                    ),
                    child: Text(
                      'Add Price'.tr,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamilyFallback: fontFamilyFallback,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return isTablet
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: padding, vertical: padding * 0.8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10 * adjustedScaleFactor,
                    mainAxisSpacing: 10 * adjustedScaleFactor,
                    childAspectRatio: isLargeTablet ? 3 / 1.95 : 3 / 2.1,
                  ),
                  itemCount: filteredPrices.length,
                  itemBuilder: (context, index) => _buildPriceCard(
                    context,
                    filteredPrices[index],
                    index,
                    cardWidth,
                    isDarkMode,
                    theme,
                    adjustedScaleFactor: adjustedScaleFactor,
                    padding: padding,
                    cropNameFontSize: cropNameFontSize,
                    subtitleFontSize: subtitleFontSize,
                    detailFontSize: detailFontSize,
                    fontFamilyFallback: fontFamilyFallback,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: padding, vertical: padding * 0.8),
                  itemCount: filteredPrices.length,
                  itemBuilder: (context, index) => _buildPriceCard(
                    context,
                    filteredPrices[index],
                    index,
                    cardWidth,
                    isDarkMode,
                    theme,
                    adjustedScaleFactor: adjustedScaleFactor,
                    padding: padding,
                    cropNameFontSize: cropNameFontSize,
                    subtitleFontSize: subtitleFontSize,
                    detailFontSize: detailFontSize,
                    fontFamilyFallback: fontFamilyFallback,
                  ),
                );
        });
      },
    );
  }

  Widget _buildPriceCard(
    BuildContext context,
    CropPrice price,
    int index,
    double cardWidth,
    bool isDarkMode,
    ThemeData theme, {
    required double adjustedScaleFactor,
    required double padding,
    required double cropNameFontSize,
    required double subtitleFontSize,
    required double detailFontSize,
    required List<String> fontFamilyFallback,
  }) {
    final dayLabel = AppUtils.formatDate(price.date, 'EEE, dd MMM');
    final cardColor =
        theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white);
    final accentColor = isDarkMode ? Colors.green[400]! : Colors.green[600]!;
    final actionIconColor = isDarkMode ? Colors.green[300]! : Colors.green[700]!;
    final errorIconColor = theme.colorScheme.error;
    final textColorPrimary = isDarkMode ? Colors.white : Colors.grey[900]!;
    final textColorSecondary = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    Widget buildActionButton({
      required IconData icon,
      required Color color,
      required VoidCallback onPressed,
    }) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(6 * adjustedScaleFactor),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8 * adjustedScaleFactor),
            border: Border.all(color: color.withOpacity(0.2), width: 0.5),
          ),
          child: Icon(icon, color: color, size: 20 * adjustedScaleFactor),
        ),
      );
    }

    Widget buildPriceRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: detailFontSize,
              fontWeight: FontWeight.w600,
              color: textColorPrimary,
              fontFamilyFallback: fontFamilyFallback,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 8 * adjustedScaleFactor,
                vertical: 4 * adjustedScaleFactor),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6 * adjustedScaleFactor),
              border: Border.all(color: accentColor.withOpacity(0.2), width: 0.5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: detailFontSize,
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontFamilyFallback: fontFamilyFallback,
              ),
            ),
          ),
        ],
      );
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: Duration(milliseconds: 200 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * adjustedScaleFactor)),
        color: cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(padding * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${price.cropName.tr} (${price.cropType.tr})',
                                style: TextStyle(
                                  fontSize: cropNameFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: textColorPrimary,
                                  fontFamilyFallback: fontFamilyFallback,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 4 * adjustedScaleFactor),
                              Text(
                                price.marketName.tr,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: textColorSecondary,
                                  fontFamilyFallback: fontFamilyFallback,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildActionButton(
                              icon: Icons.edit,
                              color: actionIconColor,
                              onPressed: () {
                                print(
                                    'PriceList: Navigating to edit price with ID: ${price.id}, Crop: ${price.cropName}, Type: ${price.cropType}, Market: ${price.marketName}, Date: ${price.date}');
                                Get.to(
                                  () => const PriceScreen(),
                                  arguments: price,
                                  binding: BindingsBuilder(() {
                                    Get.put(PriceController());
                                  }),
                                );
                              },
                            ),
                            SizedBox(width: 8 * adjustedScaleFactor),
                            buildActionButton(
                              icon: Icons.delete,
                              color: errorIconColor,
                              onPressed: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                final confirm = await Get.dialog<bool>(
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width * 0.75,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(
                                            12 * adjustedScaleFactor),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDarkMode
                                                ? Colors.black26
                                                : Colors.grey[200]!,
                                            blurRadius: 6,
                                            spreadRadius: 0.5,
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(padding * 0.8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Confirm Delete'.tr,
                                            style: TextStyle(
                                              fontSize: cropNameFontSize,
                                              fontWeight: FontWeight.w700,
                                              color: errorIconColor,
                                              fontFamilyFallback:
                                                  fontFamilyFallback,
                                            ),
                                          ),
                                          SizedBox(
                                              height: 8 * adjustedScaleFactor),
                                          Text(
                                            'Delete price for {cropName}?'.trParams(
                                                {'cropName': price.cropName.tr}),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: subtitleFontSize,
                                              fontWeight: FontWeight.w600,
                                              color: textColorSecondary,
                                              fontFamilyFallback:
                                                  fontFamilyFallback,
                                            ),
                                          ),
                                          SizedBox(
                                              height: 12 * adjustedScaleFactor),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: Text(
                                                  'Cancel'.tr,
                                                  style: TextStyle(
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColorSecondary,
                                                    fontFamilyFallback:
                                                        fontFamilyFallback,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 8 * adjustedScaleFactor),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Get.back(result: true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      errorIconColor,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        12 * adjustedScaleFactor,
                                                    vertical:
                                                        6 * adjustedScaleFactor,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8 *
                                                                  adjustedScaleFactor)),
                                                  elevation: 1,
                                                ),
                                                child: Text(
                                                  'Delete'.tr,
                                                  style: TextStyle(
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamilyFallback:
                                                        fontFamilyFallback,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    print(
                                        'PriceList: Deleting price with ID: ${price.id}');
                                    // await controller.deletePrice(price.id);
                                  } catch (e) {
                                    print('PriceList: Error deleting price: $e');
                                    AppUtils.showSnackbar(
                                      title: 'Error'.tr,
                                      message: 'failed_to_delete_price'
                                          .trParams({'error': e.toString()}),
                                      backgroundColor: theme.colorScheme.error,
                                      textColor: Colors.white,
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * adjustedScaleFactor),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8 * adjustedScaleFactor,
                          vertical: 4 * adjustedScaleFactor),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(6 * adjustedScaleFactor),
                      ),
                      child: Text(
                        '${'Date'.tr}: $dayLabel',
                        style: TextStyle(
                          fontSize: detailFontSize,
                          fontWeight: FontWeight.w600,
                          color: textColorSecondary,
                          fontFamilyFallback: fontFamilyFallback,
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * adjustedScaleFactor),
                    buildPriceRow(
                      'Price/kg:'.tr,
                      '${price.pricePerKg.toStringAsFixed(2)} ${Get.locale!.languageCode == 'am' ? 'ብር' : 'ETB'}',
                    ),
                    SizedBox(height: 6 * adjustedScaleFactor),
                    buildPriceRow(
                      'Price/quintal:'.tr,
                      '${price.pricePerQuintal.toStringAsFixed(2)} ${Get.locale!.languageCode == 'am' ? 'ብር' : 'ETB'}',
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
}