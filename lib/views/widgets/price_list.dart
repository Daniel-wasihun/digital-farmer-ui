import 'package:agri/controllers/market_controller.dart';
import 'package:agri/models/crop_price.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/price_dialog.dart';

class PriceList extends StatelessWidget {
  final double scaleFactor;
  final double padding;
  final double detailFontSize;
  final double subtitleFontSize;
  final double screenWidth;

  const PriceList({
    super.key,
    required this.scaleFactor,
    required this.padding,
    required this.detailFontSize,
    required this.subtitleFontSize,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isLargeTablet = constraints.maxWidth > 900;
        final isSmallPhone = constraints.maxWidth < 360;
        // Card width remains compact
        final cardWidth = constraints.maxWidth * (isLargeTablet ? 0.42 : isTablet ? 0.45 : isSmallPhone ? 0.98 : 0.92);
        // Responsive font scaling based on screen width
        final fontScale = constraints.maxWidth < 360
            ? 0.8
            : constraints.maxWidth < 600
                ? 0.95
                : constraints.maxWidth < 900
                    ? 1.1
                    : 1.25;
        // Slightly larger font sizes
        final largeFontSize = subtitleFontSize * 1.3 * fontScale;
        final mediumFontSize = detailFontSize * 1.1 * fontScale;
        final smallFontSize = detailFontSize * 0.85 * fontScale;

        return Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(10 * scaleFactor),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.grey[900]!.withOpacity(0.6) : Colors.white.withOpacity(0.8),
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
                    isDarkMode ? Colors.green[400]! : Colors.green[700]!,
                  ),
                  strokeWidth: 3 * scaleFactor,
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
                    width: 60 * scaleFactor,
                    height: 60 * scaleFactor,
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
                          color: isDarkMode ? Colors.green[400]!.withOpacity(0.3) : Colors.green[600]!.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_mall_rounded,
                      size: 30 * scaleFactor,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8 * scaleFactor),
                  Text(
                    'No Prices Available'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: largeFontSize * 1.1,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 4 * scaleFactor),
                  Text(
                    'Add prices or adjust filters'.tr,
                    style: TextStyle(
                      fontSize: mediumFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return isTablet
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 4 * scaleFactor),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLargeTablet ? 3 : 2,
                    crossAxisSpacing: 8 * scaleFactor,
                    mainAxisSpacing: 8 * scaleFactor,
                    childAspectRatio: isLargeTablet ? 2.0 : 1.8,
                  ),
                  itemCount: filteredPrices.length,
                  itemBuilder: (context, index) => _buildPriceCard(
                    context,
                    filteredPrices[index],
                    index,
                    cardWidth,
                    fontScale,
                    isDarkMode,
                    theme,
                    largeFontSize: largeFontSize,
                    mediumFontSize: mediumFontSize,
                    smallFontSize: smallFontSize,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 4 * scaleFactor, vertical: 4 * scaleFactor),
                  itemCount: filteredPrices.length,
                  itemBuilder: (context, index) => _buildPriceCard(
                    context,
                    filteredPrices[index],
                    index,
                    cardWidth,
                    fontScale,
                    isDarkMode,
                    theme,
                    largeFontSize: largeFontSize,
                    mediumFontSize: mediumFontSize,
                    smallFontSize: smallFontSize,
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
    double fontScale,
    bool isDarkMode,
    ThemeData theme, {
    required double largeFontSize,
    required double mediumFontSize,
    required double smallFontSize,
  }) {
    final dayLabel = DateFormat('EEE, dd MMM').format(price.date);
    final cardColor = theme.cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white);
    final accentColor = isDarkMode ? Colors.green[400]! : Colors.green[600]!;
    final actionIconColor = isDarkMode ? Colors.green[300]! : Colors.green[700]!;
    final errorIconColor = theme.colorScheme.error;
    final textColorPrimary = isDarkMode ? Colors.white : Colors.black87;
    final textColorSecondary = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: Duration(milliseconds: 200 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(vertical: 4 * scaleFactor),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.grey[200]!.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDarkMode ? Colors.green[800]!.withOpacity(0.2) : Colors.green[200]!.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding * 1.0, vertical: padding * 0.7),
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
                                '${price.cropName} (${price.cropType})'.tr,
                                style: TextStyle(
                                  fontSize: largeFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: textColorPrimary,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 3 * scaleFactor),
                              Text(
                                price.marketName.tr,
                                style: TextStyle(
                                  fontSize: mediumFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: textColorSecondary,
                                  letterSpacing: 0.2,
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
                            _buildActionButton(
                              icon: Icons.edit,
                              color: actionIconColor,
                              onPressed: () => Get.dialog(
                                PriceDialog(
                                  price: price,
                                  scaleFactor: scaleFactor,
                                  padding: padding,
                                  titleFontSize: subtitleFontSize * 1.5,
                                  subtitleFontSize: subtitleFontSize * 1.1,
                                  detailFontSize: detailFontSize * 0.9,
                                ),
                              ),
                              scaleFactor: scaleFactor,
                            ),
                            SizedBox(width: 6 * scaleFactor),
                            _buildActionButton(
                              icon: Icons.delete,
                              color: errorIconColor,
                              onPressed: () async {
                                final confirm = await Get.dialog<bool>(
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                                        border: Border.all(
                                          color: isDarkMode ? Colors.green[800]!.withOpacity(0.2) : Colors.green[200]!.withOpacity(0.4),
                                          width: 0.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDarkMode ? Colors.black26 : Colors.grey[200]!,
                                            blurRadius: 6,
                                            spreadRadius: 0.5,
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(padding * 1.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Confirm Delete'.tr,
                                            style: TextStyle(
                                              fontSize: largeFontSize,
                                              fontWeight: FontWeight.w900,
                                              color: errorIconColor,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          SizedBox(height: 8 * scaleFactor),
                                          Text(
                                            'Delete price for ${price.cropName}?'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: mediumFontSize,
                                              fontWeight: FontWeight.w700,
                                              color: textColorSecondary,
                                              letterSpacing: 0.2,
                                              height: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 12 * scaleFactor),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => Get.back(result: false),
                                                child: Text(
                                                  'Cancel'.tr,
                                                  style: TextStyle(
                                                    fontSize: mediumFontSize,
                                                    fontWeight: FontWeight.w700,
                                                    color: textColorSecondary,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8 * scaleFactor),
                                              ElevatedButton(
                                                onPressed: () => Get.back(result: true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: errorIconColor,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12 * scaleFactor,
                                                    vertical: 6 * scaleFactor,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                                                  ),
                                                  elevation: 1,
                                                ),
                                                child: Text(
                                                  'Delete'.tr,
                                                  style: TextStyle(
                                                    fontSize: mediumFontSize,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.2,
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
                                  // await controller.deletePrice(price.id);
                                }
                              },
                              scaleFactor: scaleFactor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6 * scaleFactor),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6 * scaleFactor, vertical: 3 * scaleFactor),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6 * scaleFactor),
                      ),
                      child: Text(
                        'Date: $dayLabel'.tr,
                        style: TextStyle(
                          fontSize: smallFontSize,
                          fontWeight: FontWeight.w700,
                          color: textColorSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * scaleFactor),
                    _buildPriceRow(
                      'Price/kg:'.tr,
                      '${price.pricePerKg.toStringAsFixed(2)} ETB',
                      theme,
                      fontSize: smallFontSize,
                      priceColor: accentColor,
                      textColor: textColorPrimary,
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 4 * scaleFactor),
                    _buildPriceRow(
                      'Price/quintal:'.tr,
                      '${price.pricePerQuintal.toStringAsFixed(2)} ETB',
                      theme,
                      fontSize: smallFontSize,
                      priceColor: accentColor,
                      textColor: textColorPrimary,
                      scaleFactor: scaleFactor,
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

  Widget _buildPriceRow(
    String label,
    String value,
    ThemeData theme, {
    required double fontSize,
    required Color priceColor,
    required Color textColor,
    required double scaleFactor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 3 * scaleFactor),
          decoration: BoxDecoration(
            color: priceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6 * scaleFactor),
            border: Border.all(color: priceColor.withOpacity(0.2), width: 0.5),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: priceColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double scaleFactor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(4 * scaleFactor),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16 * scaleFactor,
        ),
      ),
    );
  }
}