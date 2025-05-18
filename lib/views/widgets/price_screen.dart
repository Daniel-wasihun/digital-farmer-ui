import 'package:agri/controllers/price_controller.dart';
import 'package:agri/utils/app_utils.dart';
import 'package:agri/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import 'package:logger/logger.dart';

class PriceScreen extends GetView<PriceController> {
  const PriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PriceController());
    final logger = Logger();
    logger.i(
        'PriceScreen: Building form, price: ${controller.price != null ? 'ID: ${controller.price!.id}, Crop: ${controller.price!.cropName}' : 'null'}');

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    final decimalInputFormatter =
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'));

    Widget buildDropdown({
      required String value,
      required Iterable<String> items,
      required void Function(String) onSelected,
      String? errorText,
    }) {
      final fillColor =
          theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05);
      final selectedFillColor = (isDarkMode ? Colors.green[600] : Colors.green[700])!
          .withOpacity(isDarkMode ? 0.2 : 0.15);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (48 * scaleFactor).clamp(40.0, 56.0),
            decoration: BoxDecoration(
              color: value != 'Crop Name'.tr &&
                      value != 'Crop Type'.tr &&
                      value != 'Market'.tr
                  ? selectedFillColor
                  : fillColor,
              borderRadius: BorderRadius.circular(8 * scaleFactor),
              border: Border.all(
                color: errorText != null
                    ? theme.colorScheme.error
                    : (value != 'Crop Name'.tr &&
                            value != 'Crop Type'.tr &&
                            value != 'Market'.tr)
                        ? (isDarkMode ? Colors.green[600] : Colors.green[700])!
                        : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
                width: 1 * scaleFactor,
              ),
            ),
            child: PopupMenuButton<String>(
              enabled: !controller.isLoading.value,
              onSelected: onSelected,
              itemBuilder: (context) => items
                  .map((item) => PopupMenuItem<String>(
                        value: item,
                        child: Text(
                          item.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            fontFamilyFallback: const [
                              'NotoSansEthiopic',
                              'AbyssinicaSIL'
                            ],
                          ),
                        ),
                      ))
                  .toList(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
                  vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                          fontWeight: FontWeight.w600,
                          color: value == 'Crop Name'.tr ||
                                  value == 'Crop Type'.tr ||
                                  value == 'Market'.tr
                              ? (isDarkMode ? Colors.grey[500] : Colors.grey[400])
                              : (isDarkMode ? Colors.white : Colors.grey[900]),
                          fontFamilyFallback: const [
                            'NotoSansEthiopic',
                            'AbyssinicaSIL'
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: (20 * scaleFactor).clamp(18.0, 24.0),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding:
                  EdgeInsets.only(top: 4 * scaleFactor, left: 6 * scaleFactor),
              child: Text(
                errorText,
                style: TextStyle(
                  fontSize: (12 * scaleFactor).clamp(10.0, 14.0) * 0.8,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                  fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );
    }

    Widget buildDateField() {
      final fillColor =
          theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05);
      return Obx(
        () => GestureDetector(
          onTap: controller.isLoading.value
              ? null
              : () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.date.value,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    controller.date.value = AppUtils.normalizeDate(selectedDate);
                    logger.i(
                        'PriceScreen: Date updated to ${controller.date.value}');
                  }
                },
          child: Container(
            height: (48 * scaleFactor).clamp(40.0, 56.0),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(8 * scaleFactor),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                width: 1 * scaleFactor,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
              vertical: (12 * scaleFactor).clamp(10.0, 16.0),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today,
                  size: (20 * scaleFactor).clamp(18.0, 24.0),
                  color: theme.inputDecorationTheme.prefixIconColor,
                ),
                SizedBox(width: (8 * scaleFactor).clamp(6.0, 10.0)),
                Expanded(
                  child: Text(
                    AppUtils.formatDate(
                        controller.date.value, 'EEE, dd MMM yyyy'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                      fontFamilyFallback: const [
                        'NotoSansEthiopic',
                        'AbyssinicaSIL'
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: ParticleOptions(
          baseColor: theme.colorScheme.secondary.withOpacity(0.3),
          spawnMinSpeed: 6.0,
          spawnMaxSpeed: 30.0,
          particleCount: 50,
          spawnOpacity: 0.15,
          maxOpacity: 0.3,
        ),
      ),
      vsync: const _VSyncProvider(),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.green[600] : Colors.green[700],
          elevation: 4.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: (24 * scaleFactor).clamp(20.0, 28.0),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'market'.tr,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: (18 * scaleFactor).clamp(16.0, 20.0),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [theme.colorScheme.surface, theme.colorScheme.surface]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95)
                    ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * (isTablet ? 0.12 : 0.06),
                      vertical: size.height * 0.03,
                    ),
                    child: Obx(
                      () => AnimatedOpacity(
                        opacity: controller.isLoading.value ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: (isTablet ? size.width * 0.75 : size.width * 0.85)
                                .clamp(280, maxFormWidth),
                          ),
                          child: Card(
                            elevation: isDarkMode ? 6.0 : 10.0,
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16 * scaleFactor)),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  (16 * scaleFactor).clamp(12.0, 24.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        controller.price == null
                                            ? Icons.add_circle
                                            : Icons.edit,
                                        size: 20 * scaleFactor,
                                        color: isDarkMode
                                            ? Colors.green[600]
                                            : Colors.green[800],
                                      ),
                                      SizedBox(width: 8 * scaleFactor),
                                      Expanded(
                                        child: Text(
                                          controller.price == null
                                              ? 'Add Price'.tr
                                              : 'Update Price'.tr,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontSize:
                                                (22 * scaleFactor).clamp(18.0, 24.0),
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.green[600]
                                                : Colors.green[800],
                                            shadows: isDarkMode
                                                ? null
                                                : [
                                                    Shadow(
                                                      blurRadius: 6.0,
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      offset: const Offset(2, 2),
                                                    ),
                                                  ],
                                            fontFamilyFallback: const [
                                              'NotoSansEthiopic',
                                              'AbyssinicaSIL'
                                            ],
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                  Obx(
                                    () => buildDropdown(
                                      value: controller.cropName.value.isEmpty
                                          ? 'Crop Name'.tr
                                          : controller.cropName.value.tr,
                                      items: controller.cropData.keys,
                                      onSelected: (value) {
                                        controller.cropName.value = value;
                                        controller.cropType.value = '';
                                        controller.cropNameError.value = null;
                                      },
                                      errorText: controller.cropNameError.value,
                                    ),
                                  ),
                                  SizedBox(
                                      height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => buildDropdown(
                                      value: controller.cropType.value.isEmpty
                                          ? 'Crop Type'.tr
                                          : controller.cropType.value.tr,
                                      items: controller.cropName.value.isNotEmpty
                                          ? controller
                                                  .cropData[controller.cropName.value] ??
                                              []
                                          : [],
                                      onSelected: (value) {
                                        controller.cropType.value = value;
                                        controller.cropTypeError.value = null;
                                      },
                                      errorText: controller.cropTypeError.value,
                                    ),
                                  ),
                                  SizedBox(
                                      height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => buildDropdown(
                                      value: controller.marketName.value.isEmpty
                                          ? 'Market'.tr
                                          : controller.marketName.value.tr,
                                      items: controller.marketNames,
                                      onSelected: (value) {
                                        controller.marketName.value = value;
                                        controller.marketNameError.value = null;
                                      },
                                      errorText: controller.marketNameError.value,
                                    ),
                                  ),
                                  SizedBox(
                                      height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => CustomTextField(
                                      label: 'Price/kg (ETB)'.tr,
                                      controller: controller.pricePerKgController,
                                      keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true),
                                      prefixIcon: Icons.monetization_on,
                                      errorText: controller.pricePerKgError.value,
                                      onChanged: (value) {
                                        controller.debounceValidation(() {
                                          controller.pricePerKgError.value =
                                              controller.validatePricePerKg(value);
                                        });
                                      },
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize:
                                          (12 * scaleFactor).clamp(10.0, 14.0),
                                      iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            (8 * scaleFactor).clamp(8.0, 12.0),
                                        vertical:
                                            (12 * scaleFactor).clamp(10.0, 16.0),
                                      ),
                                      borderRadius: 8 * scaleFactor,
                                      filled: true,
                                      fillColor: theme.colorScheme.onSurface
                                          .withOpacity(isDarkMode ? 0.1 : 0.05),
                                      enabled: !controller.isLoading.value,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [decimalInputFormatter],
                                      maxLines: 1,
                                      cursorColor: isDarkMode
                                          ? Colors.green[400]
                                          : Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(
                                      height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => CustomTextField(
                                      label: 'Price/quintal (ETB)'.tr,
                                      controller: controller.pricePerQuintalController,
                                      keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true),
                                      prefixIcon: Icons.monetization_on,
                                      errorText: controller.pricePerQuintalError.value,
                                      onChanged: (value) {
                                        controller.debounceValidation(() {
                                          controller.pricePerQuintalError.value =
                                              controller.validatePricePerQuintal(
                                                  value, controller.pricePerKgController.text);
                                        });
                                      },
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize:
                                          (12 * scaleFactor).clamp(10.0, 14.0),
                                      iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            (8 * scaleFactor).clamp(8.0, 12.0),
                                        vertical:
                                            (12 * scaleFactor).clamp(10.0, 16.0),
                                      ),
                                      borderRadius: 8 * scaleFactor,
                                      filled: true,
                                      fillColor: theme.colorScheme.onSurface
                                          .withOpacity(isDarkMode ? 0.1 : 0.05),
                                      enabled: !controller.isLoading.value,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        if (!controller.isLoading.value) {
                                          controller.savePrice();
                                        }
                                      },
                                      inputFormatters: [decimalInputFormatter],
                                      maxLines: 1,
                                      cursorColor: isDarkMode
                                          ? Colors.green[400]
                                          : Colors.green[700],
                                    ),
                                  ),
                                  SizedBox(
                                      height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  buildDateField(),
                                  SizedBox(
                                      height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                  AnimatedScale(
                                    scale: controller.isLoading.value ? 0.95 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.savePrice,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? Colors.green[600]
                                            : Colors.green[700],
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical:
                                              (14 * scaleFactor).clamp(12.0, 18.0),
                                          horizontal:
                                              (24 * scaleFactor).clamp(20.0, 32.0),
                                        ),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8 * scaleFactor)),
                                        textStyle: TextStyle(
                                          fontSize:
                                              (16 * scaleFactor).clamp(14.0, 18.0),
                                          fontWeight: FontWeight.w700,
                                          fontFamilyFallback: const [
                                            'NotoSansEthiopic',
                                            'AbyssinicaSIL'
                                          ],
                                        ),
                                        elevation:
                                            controller.isLoading.value ? 0 : 4.0,
                                      ),
                                      child: controller.isLoading.value
                                          ? SizedBox(
                                              width:
                                                  (24 * scaleFactor).clamp(20.0, 30.0),
                                              height:
                                                  (24 * scaleFactor).clamp(20.0, 30.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: (2.0 * scaleFactor)
                                                    .clamp(1.5, 3.0),
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              (controller.price == null
                                                      ? 'Save'
                                                      : 'Update')
                                                  .tr
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontFamilyFallback: [
                                                  'NotoSansEthiopic',
                                                  'AbyssinicaSIL'
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: (8 * scaleFactor).clamp(8.0, 12.0)),
                                  TextButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            controller.reset();
                                            Get.back();
                                          },
                                    child: Text(
                                      'Cancel'.tr,
                                      style: theme.textButtonTheme.style?.textStyle
                                              ?.resolve({}) ??
                                          TextStyle(
                                            fontSize:
                                                (14 * scaleFactor).clamp(12.0, 16.0),
                                            fontFamilyFallback: const [
                                              'NotoSansEthiopic',
                                              'AbyssinicaSIL'
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
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VSyncProvider implements TickerProvider {
  const _VSyncProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}