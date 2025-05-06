import 'package:agri/controllers/price_controller.dart';
import 'package:agri/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import 'package:intl/intl.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/theme_controller.dart';

class PriceScreen extends GetView<PriceController> {
  const PriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller only if not already registered
    if (!Get.isRegistered<PriceController>()) {
      Get.put(PriceController(), permanent: true);
    }
    final ThemeController themeController = Get.find<ThemeController>();
    final AppController appController = Get.find<AppController>();

    // Initialize fields only for editing an existing price
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.price != null && controller.cropName.value.isEmpty) {
        controller.initializeFields();
      }
    });

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

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
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
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
                            maxWidth: (isTablet ? size.width * 0.75 : size.width * 0.85).clamp(280, maxFormWidth),
                          ),
                          child: Card(
                            elevation: isDarkMode ? 6.0 : 10.0,
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16 * scaleFactor),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: EdgeInsets.all((16 * scaleFactor).clamp(12.0, 24.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        controller.price == null ? Icons.add_circle : Icons.edit,
                                        size: 20 * scaleFactor,
                                        color: isDarkMode ? Colors.green[600] : Colors.green[800],
                                      ),
                                      SizedBox(width: 8 * scaleFactor),
                                      Expanded(
                                        child: Text(
                                          controller.price == null ? 'Add Price'.tr : 'Update Price'.tr,
                                          style: theme.textTheme.headlineSmall?.copyWith(
                                            fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.green[600] : Colors.green[800],
                                            shadows: isDarkMode
                                                ? null
                                                : [
                                                    Shadow(
                                                      blurRadius: 6.0,
                                                      color: Colors.black.withOpacity(0.2),
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                            fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                  Obx(
                                    () => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      value: controller.cropName.value.isEmpty ? 'Crop Name'.tr : controller.cropName.value.tr,
                                      items: controller.marketController.cropData.keys,
                                      onSelected: (value) {
                                        controller.cropName.value = value;
                                        controller.cropType.value = '';
                                        controller.cropNameError.value = null;
                                      },
                                      errorText: controller.cropNameError.value,
                                      enabled: !controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      value: controller.cropType.value.isEmpty ? 'Crop Type'.tr : controller.cropType.value.tr,
                                      items: controller.cropName.value.isNotEmpty
                                          ? controller.marketController.cropData[controller.cropName.value] ?? []
                                          : [],
                                      onSelected: (value) {
                                        controller.cropType.value = value;
                                        controller.cropTypeError.value = null;
                                      },
                                      errorText: controller.cropTypeError.value,
                                      enabled: !controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => _buildDropdown(
                                      context: context,
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      value: controller.marketName.value.isEmpty ? 'Market'.tr : controller.marketName.value.tr,
                                      items: controller.marketController.marketNames,
                                      onSelected: (value) {
                                        controller.marketName.value = value;
                                        controller.marketNameError.value = null;
                                      },
                                      errorText: controller.marketNameError.value,
                                      enabled: !controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => CustomTextField(
                                      label: 'Price/kg (ETB)'.tr,
                                      controller: controller.pricePerKgController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      prefixIcon: Icons.monetization_on,
                                      errorText: controller.pricePerKgError.value,
                                      onChanged: (value) {
                                        controller.debounceValidation(() {
                                          controller.pricePerKgError.value = controller.validatePricePerKg(value);
                                        });
                                      },
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
                                        vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                                      ),
                                      borderRadius: 8 * scaleFactor,
                                      filled: true,
                                      fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                      enabled: !controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => CustomTextField(
                                      label: 'Price/quintal (ETB)'.tr,
                                      controller: controller.pricePerQuintalController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      prefixIcon: Icons.monetization_on,
                                      errorText: controller.pricePerQuintalError.value,
                                      onChanged: (value) {
                                        controller.debounceValidation(() {
                                          controller.pricePerQuintalError.value = controller.validatePricePerQuintal(value, controller.pricePerKgController.text);
                                        });
                                      },
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
                                        vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                                      ),
                                      borderRadius: 8 * scaleFactor,
                                      filled: true,
                                      fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                      enabled: !controller.isLoading.value,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        if (!controller.isLoading.value) {
                                          controller.savePrice();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  Obx(
                                    () => _buildDateField(
                                      theme: theme,
                                      isDarkMode: isDarkMode,
                                      scaleFactor: scaleFactor,
                                      fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                      labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                      dayLabel: _formatDate(controller.date.value, 'EEE, dd MMM yyyy'),
                                      enabled: !controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                  AnimatedScale(
                                    scale: controller.isLoading.value ? 0.95 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value ? null : controller.savePrice,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode ? Colors.green[600] : Colors.green[700],
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: (14 * scaleFactor).clamp(12.0, 18.0),
                                          horizontal: (24 * scaleFactor).clamp(20.0, 32.0),
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scaleFactor)),
                                        textStyle: TextStyle(
                                          fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                          fontWeight: FontWeight.w700,
                                          fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                                        ),
                                        elevation: controller.isLoading.value ? 0 : 4.0,
                                      ),
                                      child: controller.isLoading.value
                                          ? SizedBox(
                                              width: (24 * scaleFactor).clamp(20.0, 30.0),
                                              height: (24 * scaleFactor).clamp(20.0, 30.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0),
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              (controller.price == null ? 'Save' : 'Update').tr.toUpperCase(),
                                              style: const TextStyle(
                                                fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL'],
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: (8 * scaleFactor).clamp(8.0, 12.0)),
                                  TextButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            controller.reset();
                                            Get.back();
                                          },
                                    child: Text(
                                      'Cancel'.tr,
                                      style: theme.textButtonTheme.style?.textStyle?.resolve({}) ??
                                          TextStyle(
                                            fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                            fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
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

  String _formatDate(DateTime date, String format) {
    final monthKeys = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    final monthName = monthKeys[date.month - 1].tr;

    final dayKeys = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    final dayIndex = date.weekday % 7;
    final dayName = dayKeys[dayIndex].tr;

    if (format == 'EEE, dd MMM yyyy') {
      return '$dayName, ${DateFormat('dd').format(date)} $monthName ${DateFormat('yyyy').format(date)}';
    }
    return DateFormat(format).format(date);
  }

  Widget _buildDropdown({
    required BuildContext context,
    required ThemeData theme,
    required bool isDarkMode,
    required double scaleFactor,
    required double fontSize,
    required double labelFontSize,
    required String value,
    required Iterable<String> items,
    required void Function(String) onSelected,
    String? errorText,
    required bool enabled,
  }) {
    final fillColor = theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05);
    final selectedFillColor = (isDarkMode ? Colors.green[600] : Colors.green[700])!.withOpacity(isDarkMode ? 0.2 : 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: (48 * scaleFactor).clamp(40.0, 56.0),
          decoration: BoxDecoration(
            color: value != 'Crop Name'.tr && value != 'Crop Type'.tr && value != 'Market'.tr ? selectedFillColor : fillColor,
            borderRadius: BorderRadius.circular(8 * scaleFactor),
            border: Border.all(
              color: errorText != null
                  ? theme.colorScheme.error
                  : (value != 'Crop Name'.tr && value != 'Crop Type'.tr && value != 'Market'.tr)
                      ? (isDarkMode ? Colors.green[600] : Colors.green[700])!
                      : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
              width: 1 * scaleFactor,
            ),
          ),
          child: PopupMenuButton<String>(
            enabled: enabled,
            onSelected: onSelected,
            itemBuilder: (context) => items
                .map((item) => PopupMenuItem<String>(
                      value: item,
                      child: Text(
                        item.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
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
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: value == 'Crop Name'.tr || value == 'Crop Type'.tr || value == 'Market'.tr
                            ? (isDarkMode ? Colors.grey[500] : Colors.grey[400])
                            : (isDarkMode ? Colors.white : Colors.grey[900]),
                        fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
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
            padding: EdgeInsets.only(top: 4 * scaleFactor, left: 6 * scaleFactor),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: labelFontSize * 0.8,
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

  Widget _buildDateField({
    required ThemeData theme,
    required bool isDarkMode,
    required double scaleFactor,
    required double fontSize,
    required double labelFontSize,
    required String dayLabel,
    required bool enabled,
  }) {
    return CustomTextField(
      label: 'Date'.tr,
      controller: TextEditingController(text: dayLabel),
      enabled: false,
      prefixIcon: Icons.today,
      scaleFactor: scaleFactor,
      fontSize: fontSize,
      labelFontSize: labelFontSize,
      iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
      contentPadding: EdgeInsets.symmetric(
        horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
        vertical: (12 * scaleFactor).clamp(10.0, 16.0),
      ),
      borderRadius: 8 * scaleFactor,
      filled: true,
      fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
    );
  }
}

class _VSyncProvider implements TickerProvider {
  const _VSyncProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}