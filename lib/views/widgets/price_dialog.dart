import 'package:agri/controllers/market_controller.dart';
import 'package:agri/models/crop_price.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PriceDialog extends StatelessWidget {
  final CropPrice? price;
  final double scaleFactor;
  final double padding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double detailFontSize;

  const PriceDialog({
    super.key,
    this.price,
    required this.scaleFactor,
    required this.padding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.detailFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarketController>();
    final formKey = GlobalKey<FormState>();
    final cropName = (price?.cropName ?? '').obs;
    final cropType = (price?.cropType ?? '').obs;
    final marketName = (price?.marketName ?? '').obs;
    final cropNameError = Rxn<String>();
    final cropTypeError = Rxn<String>();
    final marketNameError = Rxn<String>();
    final pricePerKgController = TextEditingController(text: price?.pricePerKg.toStringAsFixed(2) ?? '');
    final pricePerQuintalController = TextEditingController(text: price?.pricePerQuintal.toStringAsFixed(2) ?? '');
    
    // Initialize date to price.date or current date (non-updateable for consistency with MongoDB data)
    final date = (price?.date ?? DateTime.now()).obs;
    final dayLabel = DateFormat('EEE, dd MMM yyyy').format(date.value);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjusted font sizes for compact content
    final adjustedTitleFontSize = titleFontSize * 1.1;
    final adjustedSubtitleFontSize = subtitleFontSize * 1.0;
    final adjustedDetailFontSize = detailFontSize * 1.0;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.06),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * scaleFactor),
          child: Container(
            width: screenWidth * 0.92,
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.4,
              maxHeight: screenHeight * 0.75, // Increased to 0.75 for more space
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[850]!]
                    : [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14 * scaleFactor),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black26 : Colors.grey[300]!,
                  blurRadius: 6 * scaleFactor,
                  offset: Offset(0, 2 * scaleFactor),
                ),
              ],
              border: Border.all(
                color: isDarkMode ? Colors.green[800]!.withOpacity(0.2) : Colors.green[200]!.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6 * scaleFactor),
                  child: Container(
                    width: 36 * scaleFactor,
                    height: 3 * scaleFactor,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(1.5 * scaleFactor),
                    ),
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(padding * 0.5), // Reduced padding for compactness
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Icon(
                                  price == null ? Icons.add_circle : Icons.edit,
                                  size: 18 * scaleFactor,
                                  color: isDarkMode ? Colors.green[300] : Colors.green[600],
                                ),
                                SizedBox(width: 5 * scaleFactor),
                                Text(
                                  price == null ? 'Add Price'.tr : 'Update Price'.tr,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: adjustedTitleFontSize,
                                    fontWeight: FontWeight.w900,
                                    color: isDarkMode ? Colors.white : Colors.grey[900],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6 * scaleFactor), // Reduced spacing
                            // Two-column grid
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6 * scaleFactor,
                              mainAxisSpacing: 3 * scaleFactor, // Further reduced for compactness
                              childAspectRatio: 2.8, // Adjusted to make rows taller for error messages
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // Crop Name Dropdown
                                Obx(() => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      detailFontSize: adjustedDetailFontSize,
                                      value: cropName.value.isEmpty ? 'Crop Name'.tr : cropName.value,
                                      items: controller.cropData.keys,
                                      onSelected: (value) {
                                        cropName.value = value;
                                        cropType.value = '';
                                        cropNameError.value = null;
                                      },
                                      icon: Icons.arrow_drop_down,
                                      hasValue: cropName.value.isNotEmpty,
                                      errorText: cropNameError.value,
                                    )),
                                // Crop Type Dropdown
                                Obx(() => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      detailFontSize: adjustedDetailFontSize,
                                      value: cropType.value.isEmpty ? 'Crop Type'.tr : cropType.value,
                                      items: cropName.value.isNotEmpty
                                          ? controller.cropData[cropName.value] ?? []
                                          : [],
                                      onSelected: (value) {
                                        cropType.value = value;
                                        cropTypeError.value = null;
                                      },
                                      icon: Icons.arrow_drop_down,
                                      hasValue: cropType.value.isNotEmpty,
                                      errorText: cropTypeError.value,
                                    )),
                                // Market Name Dropdown
                                Obx(() => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      detailFontSize: adjustedDetailFontSize,
                                      value: marketName.value.isEmpty ? 'Market'.tr : marketName.value,
                                      items: controller.marketNames,
                                      onSelected: (value) {
                                        marketName.value = value;
                                        marketNameError.value = null;
                                      },
                                      icon: Icons.arrow_drop_down,
                                      hasValue: marketName.value.isNotEmpty,
                                      errorText: marketNameError.value,
                                    )),
                                // Price per Kg
                                _buildPriceTextField(
                                  controller: pricePerKgController,
                                  theme: theme,
                                  isDarkMode: isDarkMode,
                                  scaleFactor: scaleFactor,
                                  detailFontSize: adjustedDetailFontSize,
                                  hintText: 'Price/kg (ETB)'.tr,
                                  validator: (value) {
                                    if (value?.isEmpty == true) return 'Price/kg required'.tr;
                                    final priceValue = double.tryParse(value!);
                                    if (priceValue == null || priceValue <= 0) return 'Invalid price/kg'.tr;
                                    return null;
                                  },
                                ),
                                // Price per Quintal
                                _buildPriceTextField(
                                  controller: pricePerQuintalController,
                                  theme: theme,
                                  isDarkMode: isDarkMode,
                                  scaleFactor: scaleFactor,
                                  detailFontSize: adjustedDetailFontSize,
                                  hintText: 'Price/quintal (ETB)'.tr,
                                  validator: (value) {
                                    if (value?.isEmpty == true) return 'Price/quintal required'.tr;
                                    final priceQuintal = double.tryParse(value!);
                                    if (priceQuintal == null || priceQuintal <= 0) return 'Invalid price/quintal'.tr;
                                    final priceKg = double.tryParse(pricePerKgController.text) ?? 0;
                                    if (priceQuintal < priceKg * 50) {
                                      return 'Must be >= 50x price/kg'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                // Date Display (Non-editable)
                                Container(
                                  height: 32 * scaleFactor,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                                    border: Border.all(
                                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                      width: 1 * scaleFactor,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8 * scaleFactor,
                                    vertical: 6 * scaleFactor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dayLabel,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: adjustedDetailFontSize * 0.85,
                                            fontWeight: FontWeight.w800,
                                            color: isDarkMode ? Colors.white : Colors.grey[900],
                                            letterSpacing: 0.3,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.today,
                                        size: 14 * scaleFactor,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6 * scaleFactor), // Reduced spacing before buttons
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * scaleFactor,
                                      vertical: 6 * scaleFactor,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel'.tr,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: adjustedDetailFontSize * 0.85,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6 * scaleFactor),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Validate dropdowns
                                    cropNameError.value = cropName.value.isEmpty ? 'Crop Name required'.tr : null;
                                    cropTypeError.value = cropType.value.isEmpty ? 'Crop Type required'.tr : null;
                                    marketNameError.value = marketName.value.isEmpty ? 'Market required'.tr : null;

                                    if (formKey.currentState!.validate() &&
                                        cropNameError.value == null &&
                                        cropTypeError.value == null &&
                                        marketNameError.value == null) {
                                      final newPrice = CropPrice(
                                        id: price?.id ?? '',
                                        cropName: cropName.value,
                                        cropType: cropType.value,
                                        marketName: marketName.value,
                                        pricePerKg: double.parse(pricePerKgController.text),
                                        pricePerQuintal: double.parse(pricePerQuintalController.text),
                                        date: _normalizeDate(date.value),
                                        createdAt: price?.createdAt ?? DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                                      try {
                                        Get.back(); // Close dialog immediately
                                        if (price == null) {
                                          await controller.addPrice(newPrice);
                                          Get.snackbar(
                                            'Success'.tr,
                                            'Price added successfully'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: theme.colorScheme.primary,
                                            colorText: Colors.white,
                                          );
                                        } else {
                                          await controller.updatePrice(price!.id, newPrice);
                                          Get.snackbar(
                                            'Success'.tr,
                                            'Price updated successfully'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: theme.colorScheme.primary,
                                            colorText: Colors.white,
                                          );
                                        }
                                      } catch (e) {
                                        Get.snackbar(
                                          'Error'.tr,
                                          'Failed to ${price == null ? 'add' : 'update'} price: $e'.tr,
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: theme.colorScheme.error,
                                          colorText: Colors.white,
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? Colors.green[400] : Colors.green[600],
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14 * scaleFactor,
                                      vertical: 6 * scaleFactor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                                    ),
                                    elevation: 2,
                                    shadowColor: isDarkMode ? Colors.black26 : Colors.grey[300],
                                  ),
                                  child: Text(
                                    price == null ? 'Save'.tr : 'Update'.tr,
                                    style: TextStyle(
                                      fontSize: adjustedDetailFontSize * 0.85,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to normalize DateTime to midnight UTC
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  // Helper method to build dropdowns with a fixed height
  Widget _buildDropdown({
    required BuildContext context,
    required ThemeData theme,
    required bool isDarkMode,
    required double scaleFactor,
    required double detailFontSize,
    required String value,
    required Iterable<String> items,
    required void Function(String) onSelected,
    required IconData icon,
    required bool hasValue,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32 * scaleFactor,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8 * scaleFactor),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1 * scaleFactor,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.grey[200]!,
                blurRadius: 3 * scaleFactor,
                offset: Offset(0, 1 * scaleFactor),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            onSelected: onSelected,
            itemBuilder: (context) => items
                .map((item) => PopupMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: detailFontSize * 0.85,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                    ))
                .toList(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 6 * scaleFactor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: detailFontSize * 0.85,
                        fontWeight: FontWeight.w800,
                        color: hasValue
                            ? (isDarkMode ? Colors.white : Colors.grey[900])
                            : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    icon,
                    size: 14 * scaleFactor,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 1 * scaleFactor, left: 6 * scaleFactor),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: detailFontSize * 0.6, // Slightly smaller font for errors
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              ),
              maxLines: 1, // Limit to one line to control height
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  // Helper method to build price text fields with a fixed height
  Widget _buildPriceTextField({
    required TextEditingController controller,
    required ThemeData theme,
    required bool isDarkMode,
    required double scaleFactor,
    required double detailFontSize,
    required String hintText,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32 * scaleFactor,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: detailFontSize * 0.85,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scaleFactor),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                vertical: 6 * scaleFactor,
                horizontal: 8 * scaleFactor,
              ),
              errorStyle: TextStyle(
                fontSize: detailFontSize * 0.6, // Match dropdown error font size
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: detailFontSize * 0.85,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
        if (controller.text.isNotEmpty && validator(controller.text) != null)
          Padding(
            padding: EdgeInsets.only(top: 1 * scaleFactor, left: 6 * scaleFactor),
            child: Text(
              validator(controller.text)!,
              style: TextStyle(
                fontSize: detailFontSize * 0.6, // Slightly smaller font for errors
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              ),
              maxLines: 1, // Limit to one line to control height
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}