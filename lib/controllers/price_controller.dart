import 'dart:async';
import 'package:digital_farmers/models/crop_price.dart';
import 'package:digital_farmers/services/market_service.dart';
import 'package:digital_farmers/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class PriceController extends GetxController {
  final MarketService _marketService = Get.find<MarketService>();
  final logger = Logger();

  final cropName = ''.obs;
  final cropType = ''.obs;
  final marketName = ''.obs;
  final date = DateTime.now().obs;
  final isLoading = false.obs;
  final isEditing = false.obs;
  final cropNameError = Rxn<String>();
  final cropTypeError = Rxn<String>();
  final marketNameError = Rxn<String>();
  final pricePerKgError = Rxn<String>();
  final pricePerQuintalError = Rxn<String>();

  final pricePerKgController = TextEditingController();
  final pricePerQuintalController = TextEditingController();

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  CropPrice? price;

  Map<String, List<String>> get cropData => _marketService.cropData;
  List<String> get marketNames => _marketService.marketNames;

  @override
  void onInit() {
    super.onInit();
    price = Get.arguments as CropPrice?;
    logger.i(
        'PriceController: onInit called, price: ${price != null ? 'ID: ${price!.id}, Crop: ${price!.cropName}' : 'null'}');
    initializeFields();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    pricePerKgController.dispose();
    pricePerQuintalController.dispose();
    super.onClose();
  }

  void initializeFields() {
    logger.i(
        'PriceController: Initializing fields, price: ${price != null ? 'ID: ${price!.id}' : 'null'}');
    if (price != null) {
      isEditing.value = true;
      cropName.value = cropData.containsKey(price!.cropName) ? price!.cropName : '';
      cropType.value = cropName.value.isNotEmpty &&
              cropData[cropName.value]?.contains(price!.cropType) == true
          ? price!.cropType
          : '';
      marketName.value =
          marketNames.contains(price!.marketName) ? price!.marketName : '';
      pricePerKgController.text = price!.pricePerKg.toStringAsFixed(2);
      pricePerQuintalController.text = price!.pricePerQuintal.toStringAsFixed(2);
      date.value = price!.date;
      if (cropName.value != price!.cropName ||
          cropType.value != price!.cropType ||
          marketName.value != price!.marketName) {
        logger.w(
            'PriceController: Invalid price data - Crop: ${price!.cropName}, Type: ${price!.cropType}, Market: ${price!.marketName}');
        AppUtils.showSnackbar(
          title: 'Warning'.tr,
          message: 'Some price data is invalid and may not display correctly'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          textColor: Colors.white,
          position: SnackPosition.TOP,
        );
      }
      logger.i(
          'PriceController: Set fields for editing - ID: ${price!.id}, Crop: ${cropName.value}, Type: ${cropType.value}, Market: ${marketName.value}, Price/kg: ${pricePerKgController.text}, Price/quintal: ${pricePerQuintalController.text}, Date: ${date.value}');
    } else {
      isEditing.value = false;
      reset();
      logger.i('PriceController: Initialized for adding new price');
    }
  }

  void reset() {
    cropName.value = '';
    cropType.value = '';
    marketName.value = '';
    cropNameError.value = null;
    cropTypeError.value = null;
    marketNameError.value = null;
    pricePerKgController.clear();
    pricePerQuintalController.clear();
    pricePerKgError.value = null;
    pricePerQuintalError.value = null;
    date.value = DateTime.now();
    isLoading.value = false;
    price = null;
    logger.i('PriceController: Form reset');
  }

  void debounceValidation(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, callback);
  }

  String? validateCropName(String? value) {
    if (value == null || value.isEmpty || value == 'Crop Name'.tr) {
      return 'Crop Name required'.tr;
    }
    return null;
  }

  String? validateCropType(String? value) {
    if (value == null || value.isEmpty || value == 'Crop Type'.tr) {
      return 'Crop Type required'.tr;
    }
    return null;
  }

  String? validateMarketName(String? value) {
    if (value == null || value.isEmpty || value == 'Market'.tr) {
      return 'Market required'.tr;
    }
    return null;
  }

  String? validatePricePerKg(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price/kg required'.tr;
    }
    final priceValue = double.tryParse(value);
    if (priceValue == null) {
      return 'Invalid price/kg (must be a number)'.tr;
    }
    if (priceValue <= 0) {
      return 'Price/kg must be positive'.tr;
    }
    if (priceValue > 10000) {
      return 'Price/kg too high (max 10,000 ETB)'.tr;
    }
    pricePerQuintalError.value =
        validatePricePerQuintal(pricePerQuintalController.text, value);
    return null;
  }

  String? validatePricePerQuintal(String? value, String? kgValue) {
    if (value == null || value.isEmpty) {
      return 'Price/quintal required'.tr;
    }
    final priceQuintal = double.tryParse(value);
    if (priceQuintal == null) {
      return 'Invalid price/quintal (must be a number)'.tr;
    }
    if (priceQuintal <= 0) {
      return 'Price/quintal must be positive'.tr;
    }
    if (priceQuintal > 1000000) {
      return 'Price/quintal too high (max 1,000,000 ETB)'.tr;
    }
    final priceKg = double.tryParse(kgValue ?? '') ?? 0;
    if (priceKg > 0 && priceQuintal < priceKg * 50) {
      return 'Price/quintal must be at least 50x price/kg'.tr;
    }
    return null;
  }

  Future<void> savePrice() async {
    logger.i('PriceController: Attempting to save price, isEditing: ${isEditing.value}');
    cropNameError.value = validateCropName(cropName.value);
    cropTypeError.value = validateCropType(cropType.value);
    marketNameError.value = validateMarketName(marketName.value);
    pricePerKgError.value = validatePricePerKg(pricePerKgController.text);
    pricePerQuintalError.value =
        validatePricePerQuintal(pricePerQuintalController.text, pricePerKgController.text);

    if (cropNameError.value != null ||
        cropTypeError.value != null ||
        marketNameError.value != null ||
        pricePerKgError.value != null ||
        pricePerQuintalError.value != null) {
      logger.w('PriceController: Validation failed');
      return;
    }

    isLoading.value = true;
    try {
      final normalizedDate = AppUtils.normalizeDate(date.value);
      final newPrice = CropPrice(
        id: price?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: cropName.value,
        cropType: cropType.value,
        marketName: marketName.value,
        pricePerKg: double.parse(pricePerKgController.text),
        pricePerQuintal: double.parse(pricePerQuintalController.text),
        date: normalizedDate,
        createdAt: price?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (!isEditing.value) {
        final exists = await _marketService.checkPriceExists(newPrice);
        if (exists) {
          logger.w('PriceController: Duplicate price detected');
          AppUtils.showSnackbar(
            title: 'Error'.tr,
            message:
                'Price already exists for this crop, type, market, and date'.tr,
            backgroundColor: Get.theme.colorScheme.error,
            textColor: Colors.white,
            position: SnackPosition.TOP,
          );
          isLoading.value = false;
          return;
        }
      }

      if (isEditing.value) {
        logger.i('PriceController: Updating price with ID: ${price!.id}');
        await _marketService.updatePrice(price!.id, newPrice);
      } else {
        logger.i('PriceController: Adding new price');
        await _marketService.addPrice(newPrice);
      }

      reset();
      Get.back();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: isEditing.value
            ? 'Price updated successfully'.tr
            : 'Price added successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('PriceController: Price saved successfully');
    } catch (e) {
      logger.e('PriceController: Error saving price: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: isEditing.value
            ? 'failed_to_update_price'.trParams({'error': e.toString()})
            : 'failed_to_add_price'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}