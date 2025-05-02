import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/crop_price.dart';
import '../controllers/market_controller.dart';

class PriceController extends GetxController {
  final MarketController marketController = Get.find<MarketController>();
  final CropPrice? price = Get.arguments as CropPrice?;
  final formKey = GlobalKey<FormState>(); // Kept for potential future use
  final cropName = ''.obs;
  final cropType = ''.obs;
  final marketName = ''.obs;
  final cropNameError = Rxn<String>();
  final cropTypeError = Rxn<String>();
  final marketNameError = Rxn<String>();
  final pricePerKgController = TextEditingController();
  final pricePerQuintalController = TextEditingController();
  final pricePerKgError = Rxn<String>(); // Added for errorText
  final pricePerQuintalError = Rxn<String>(); // Added for errorText
  final date = DateTime.now().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (price != null) {
      cropName.value = price!.cropName;
      cropType.value = price!.cropType;
      marketName.value = price!.marketName;
      pricePerKgController.text = price!.pricePerKg.toStringAsFixed(2);
      pricePerQuintalController.text = price!.pricePerQuintal.toStringAsFixed(2);
      date.value = price!.date;
    }

    // Sync TextEditingControllers with error updates
    pricePerKgController.addListener(() {
      pricePerKgError.value = validatePricePerKg(pricePerKgController.text);
    });
    pricePerQuintalController.addListener(() {
      pricePerQuintalError.value = validatePricePerQuintal(pricePerQuintalController.text, pricePerKgController.text);
    });
  }

  @override
  void onClose() {
    pricePerKgController.dispose();
    pricePerQuintalController.dispose();
    super.onClose();
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
    return null;
  }

  String? validatePricePerQuintal(String? value, String kgValue) {
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
    final priceKg = double.tryParse(kgValue) ?? 0;
    if (priceKg > 0 && priceQuintal < priceKg * 50) {
      return 'Price/quintal must be at least 50x price/kg'.tr;
    }
    return null;
  }

  Future<void> savePrice() async {
    // Validate dropdowns
    cropNameError.value = cropName.value.isEmpty ? 'Crop Name required'.tr : null;
    cropTypeError.value = cropType.value.isEmpty ? 'Crop Type required'.tr : null;
    marketNameError.value = marketName.value.isEmpty ? 'Market required'.tr : null;

    // Validate price fields
    pricePerKgError.value = validatePricePerKg(pricePerKgController.text);
    pricePerQuintalError.value = validatePricePerQuintal(pricePerQuintalController.text, pricePerKgController.text);

    // Check all validations
    if (cropNameError.value == null &&
        cropTypeError.value == null &&
        marketNameError.value == null &&
        pricePerKgError.value == null &&
        pricePerQuintalError.value == null) {
      isLoading.value = true;
      final normalizedDate = DateTime.utc(date.value.year, date.value.month, date.value.day);
      final newPrice = CropPrice(
        id: price?.id ?? '',
        cropName: cropName.value,
        cropType: cropType.value,
        marketName: marketName.value,
        pricePerKg: double.parse(pricePerKgController.text),
        pricePerQuintal: double.parse(pricePerQuintalController.text),
        date: normalizedDate,
        createdAt: price?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (price == null) {
        final exists = marketController.prices.any((p) =>
            p.cropName == newPrice.cropName &&
            p.cropType == newPrice.cropType &&
            p.marketName == newPrice.marketName &&
            p.date.isAtSameMomentAs(normalizedDate));
        if (exists) {
          isLoading.value = false;
          marketController.showSnackbar(
            title: 'Error'.tr,
            message: 'Price already exists for this crop, type, market, and date'.tr,
            backgroundColor: Get.theme.colorScheme.error,
            textColor: Colors.white,
          );
          return;
        }
      }

      try {
        if (price == null) {
          await marketController.addPrice(newPrice);
        } else {
          await marketController.updatePrice(price!.id, newPrice);
        }
        Get.back();
      } catch (e) {
        marketController.showSnackbar(
          title: 'Error'.tr,
          message: price == null
              ? 'failed_to_add_price'.trParams({'error': e.toString()})
              : 'failed_to_update_price'.trParams({'error': e.toString()}),
          backgroundColor: Get.theme.colorScheme.error,
          textColor: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      // marketController.showSnackbar(
      //   title: 'Validation Error'.tr,
      //   message: 'Please fill all fields correctly'.tr,
      //   backgroundColor: Get.theme.colorScheme.error,
      //   textColor: Colors.white,
      // );
    }
  }
}