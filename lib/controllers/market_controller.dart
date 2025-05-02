import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/crop_price.dart';
import 'package:logger/logger.dart'; // Add logger for debugging

class MarketController extends GetxController {
  final box = GetStorage();
  final prices = <CropPrice>[].obs;
  final filteredPrices = <CropPrice>[].obs;
  final selectedWeek = Rxn<DateTime>();
  final selectedDay = Rxn<DateTime>();
  final priceOrder = 'Default'.obs;
  final marketFilter = ''.obs;
  final nameOrder = 'Default'.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  static const String apiBaseUrl = BaseApi.apiBaseUrl;

  // Logger for debugging
  final logger = Logger();

  final Map<String, List<String>> cropData = {
    "teff": ["red teff", "white teff", "sergegna teff"],
    "maize": ["white maize", "yellow maize"],
    "wheat": ["durum wheat", "bread wheat"],
    "barley": ["malt barley", "food barley"],
    "sorghum": ["white sorghum", "red sorghum"],
    "millet": ["finger millet", "pearl millet"],
    "oats": ["common oats"],
    "finger_millet": ["red finger millet", "brown finger millet"],
    "triticale": ["common triticale"],
    "rice": ["upland rice", "lowland rice"],
    "chickpea": ["desi chickpea", "kabuli chickpea"],
    "haricot_bean": ["red haricot", "white haricot"],
    "lentil": ["red lentil", "green lentil"],
    "faba_bean": ["small faba", "large faba"],
    "pea": ["field pea", "garden pea"],
    "grass_pea": ["common grass pea"],
    "soybean": ["common soybean"],
    "niger_seed": ["black niger", "yellow niger"],
    "flaxseed": ["brown flaxseed", "golden flaxseed"],
    "sesame": ["white sesame", "black sesame"],
    "groundnut": ["red groundnut", "white groundnut"],
    "sunflower": ["common sunflower"],
    "potato": ["red potato", "white potato"],
    "sweet_potato": ["orange sweet potato", "white sweet potato"],
    "taro": ["common taro"],
    "cassava": ["bitter cassava", "sweet cassava"],
    "yam": ["white yam", "yellow yam"],
    "enset": ["common enset"],
    "onion": ["red onion", "white onion"],
    "tomato": ["roma tomato", "cherry tomato"],
    "cabbage": ["green cabbage", "red cabbage"],
    "carrot": ["orange carrot", "purple carrot"],
    "beetroot": ["red beetroot"],
    "kale": ["curly kale", "lacinato kale"],
    "lettuce": ["romaine lettuce", "iceberg lettuce"],
    "spinach": ["flat-leaf spinach", "savoy spinach"],
    "green_pepper": ["bell pepper", "jalapeno"],
    "eggplant": ["long eggplant", "round eggplant"],
    "okra": ["green okra"],
    "squash": ["butternut squash", "acorn squash"],
    "avocado": ["hass avocado", "fuerte avocado"],
    "banana": ["cavendish banana", "plantain"],
    "mango": ["kent mango", "keitt mango"],
    "papaya": ["solo papaya", "maradol papaya"],
    "orange": ["navel orange", "valencia orange"],
    "lemon": ["eureka lemon", "lisbon lemon"],
    "lime": ["persian lime", "key lime"],
    "grapefruit": ["ruby red grapefruit", "white grapefruit"],
    "pineapple": ["cayenne pineapple"],
    "guava": ["white guava", "pink guava"],
    "chilli_pepper": ["red chilli", "green chilli"],
    "ginger": ["common ginger"],
    "turmeric": ["yellow turmeric"],
    "garlic": ["hardneck garlic", "softneck garlic"],
    "fenugreek": ["common fenugreek"],
    "coriander": ["common coriander"],
    "coffee": ["arabica coffee", "robusta coffee"],
    "tea": ["black tea", "green tea"],
    "sugarcane": ["common sugarcane"],
    "tobacco": ["virginia tobacco", "burley tobacco"],
    "cotton": ["upland cotton", "pima cotton"],
    "cut_flowers": ["rose", "lily"]
  };

  final List<String> marketNames = ["Local", "Export"];
  final List<String> priceSortOptions = ["Default", "Low to High", "High to Low"];
  final List<String> nameSortOptions = ["Default", "Ascending", "Descending"];

  @override
  void onInit() {
    super.onInit();
    selectedWeek.value = _getMondayOfWeek(DateTime.now());
    selectedDay.value = null;
    nameOrder.value = "Default";
    priceOrder.value = "Default";
    marketFilter.value = "";
    fetchCropData();
    fetchPrices();

    everAll([
      selectedWeek,
      selectedDay,
      priceOrder,
      marketFilter,
      nameOrder,
      searchQuery
    ], (_) => _applyFiltersAndSorting());
  }

  // Safe method to show snackbars
  void showSnackbar({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    TextButton? mainButton,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      mainButton: mainButton,
    );
  }

  Future<void> fetchCropData() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$apiBaseUrl/crops'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final Map<String, List<String>> tempCropData = {};
        for (var item in data) {
          final cropName = item['cropName'] as String?;
          final cropType = item['cropType'] as String?;
          if (cropName != null && cropType != null) {
            if (!tempCropData.containsKey(cropName)) {
              tempCropData[cropName] = [];
            }
            if (!tempCropData[cropName]!.contains(cropType)) {
              tempCropData[cropName]!.add(cropType);
            }
          }
        }
        cropData.clear();
        cropData.addAll(tempCropData);
      } else {
        throw Exception('Failed to fetch crop data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.e('Error fetching crop data: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_fetch_crop_data'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrices() async {
    isLoading.value = true;
    try {
      final queryParams = <String, String>{};

      if (selectedDay.value != null) {
        final dayStart = _normalizeDate(selectedDay.value!);
        final dayEnd = dayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        queryParams['dateStart'] = dayStart.toIso8601String();
        queryParams['dateEnd'] = dayEnd.toIso8601String();
      } else if (selectedWeek.value != null) {
        final weekStart = _normalizeDate(selectedWeek.value!);
        final weekEnd = _normalizeDate(weekStart.add(const Duration(days: 6)));
        queryParams['dateStart'] = weekStart.toIso8601String();
        queryParams['dateEnd'] = weekEnd.toIso8601String();
      }

      final uri = Uri.parse('$apiBaseUrl/prices').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch prices: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      prices.value = (data['prices'] as List).map((e) {
        if (e['cropName'] == null ||
            e['cropType'] == null ||
            e['marketName'] == null ||
            e['pricePerKg'] == null ||
            e['pricePerQuintal'] == null ||
            e['date'] == null) {
          throw Exception('Invalid price data: missing required fields');
        }
        return CropPrice.fromJson({
          '_id': e['_id']?.toString() ?? '',
          'cropName': e['cropName'].toString(),
          'cropType': e['cropType'].toString(),
          'marketName': e['marketName'].toString(),
          'pricePerKg': (e['pricePerKg'] is num) ? e['pricePerKg'].toDouble() : 0.0,
          'pricePerQuintal': (e['pricePerQuintal'] is num) ? e['pricePerQuintal'].toDouble() : 0.0,
          'date': e['date'].toString(),
          'createdAt': e['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
          'updatedAt': e['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
        });
      }).toList();

      _applyFiltersAndSorting();
    } catch (e) {
      logger.e('Error fetching prices: $e');
      prices.clear();
      filteredPrices.clear();
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_fetch_crop_data'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkPriceExists(CropPrice price) async {
    try {
      final normalizedDate = _normalizeDate(price.date);
      final queryParams = {
        'cropName': price.cropName,
        'cropType': price.cropType,
        'marketName': price.marketName,
        'date': normalizedDate.toIso8601String(),
      };
      final uri = Uri.parse('$apiBaseUrl/prices').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exists = (data['prices'] as List).isNotEmpty;
        logger.i('Duplicate price check: exists=$exists for ${price.cropName}, ${price.cropType}, ${price.marketName}, ${price.date}');
        return exists;
      }
      throw Exception('Failed to check price existence: ${response.statusCode} - ${response.body}');
    } catch (e) {
      logger.e('Error checking price existence: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_check_price_existence'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      return false; // Assume no duplicate if check fails to avoid blocking valid additions
    }
  }

  Future<void> addPrice(CropPrice price) async {
    try {
      isLoading.value = true;
      price = price.copyWith(
        date: _normalizeDate(price.date),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (price.cropName.isEmpty) {
        throw Exception('Crop name is required'.tr);
      }
      if (price.cropType.isEmpty) {
        throw Exception('Crop type is required'.tr);
      }
      if (!marketNames.contains(price.marketName)) {
        throw Exception('Invalid market name'.tr);
      }
      if (price.pricePerKg <= 0) {
        throw Exception('Price per kg must be positive'.tr);
      }
      if (price.pricePerQuintal < price.pricePerKg * 50) {
        throw Exception('Price per quintal must be at least 50 times price per kg'.tr);
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/prices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()..remove('_id')),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to add price: ${errorData['error'] ?? response.body}');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'Price added successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error adding price: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_add_price'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePrice(String id, CropPrice price) async {
    try {
      isLoading.value = true;
      price = price.copyWith(
        date: _normalizeDate(price.date),
        updatedAt: DateTime.now(),
      );

      if (price.cropName.isEmpty) {
        throw Exception('Crop name is required'.tr);
      }
      if (price.cropType.isEmpty) {
        throw Exception('Crop type is required'.tr);
      }
      if (!marketNames.contains(price.marketName)) {
        throw Exception('Invalid market name'.tr);
      }
      if (price.pricePerKg <= 0) {
        throw Exception('Price per kg must be positive'.tr);
      }
      if (price.pricePerQuintal < price.pricePerKg * 50) {
        throw Exception('Price per quintal must be at least 50 times price per kg'.tr);
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/prices/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to update price: ${errorData['error'] ?? response.body}');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'Price updated successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error updating price: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_update_price'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePrice(String id) async {
    try {
      isLoading.value = true;
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/prices/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to delete price: ${errorData['error'] ?? response.body}');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'Price deleted successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error deleting price: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_delete_price'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> clonePrices(List<DateTime> sourceDays, DateTime targetDate) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$apiBaseUrl/prices/clone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sourceDays': sourceDays.map((day) => _normalizeDate(day).toIso8601String()).toList(),
          'targetDate': _normalizeDate(targetDate).toIso8601String(),
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to clone prices: ${errorData['error'] ?? response.body}');
      }

      final responseData = jsonDecode(response.body);
      return {
        'message': responseData['message'] ?? 'No prices available to clone',
        'clonedPriceIds': List<String>.from(responseData['clonedPriceIds'] ?? []),
      };
    } catch (e) {
      logger.e('Error cloning prices: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_clone_prices'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> undoClonePrices(List<String> priceIds, DateTime weekStart) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('$apiBaseUrl/prices/delete-batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'priceIds': priceIds,
          'weekStart': _normalizeDate(weekStart).toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to undo clone: ${errorData['error'] ?? response.body}');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'Clone operation undone successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error undoing clone: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_undo_clone'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> batchInsertPrices(List<CropPrice> pricesToInsert) async {
    try {
      isLoading.value = true;
      final validatedPrices = pricesToInsert.map((price) {
        if (price.cropName.isEmpty) {
          throw Exception('Crop name is required for ${price.cropName}'.tr);
        }
        if (price.cropType.isEmpty) {
          throw Exception('Crop type is required for ${price.cropName}'.tr);
        }
        if (!marketNames.contains(price.marketName)) {
          throw Exception('Invalid market name for ${price.cropName}'.tr);
        }
        if (price.pricePerKg <= 0) {
          throw Exception('Price per kg must be positive for ${price.cropName}'.tr);
        }
        if (price.pricePerQuintal < price.pricePerKg * 50) {
          throw Exception('Price per quintal must be at least 50 times price per kg for ${price.cropName}'.tr);
        }
        return price.copyWith(
          date: _normalizeDate(price.date),
          createdAt: price.createdAt ?? DateTime.now(),
          updatedAt: price.updatedAt ?? DateTime.now(),
        );
      }).toList();

      final response = await http.post(
        Uri.parse('$apiBaseUrl/prices/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prices': validatedPrices.map((p) => p.toJson()..remove('_id')).toList(),
        }),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to batch insert prices: ${errorData['error'] ?? response.body}');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'batch_inserted_prices'.trParams({'count': pricesToInsert.length.toString()}),
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error batch inserting prices: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'failed_to_batch_insert_prices'.trParams({'error': e.toString()}),
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedWeek(DateTime? week) {
    selectedWeek.value = week != null ? _normalizeDate(week) : null;
    selectedDay.value = null;
    fetchPrices();
  }

  void setSelectedDay(DateTime? day) {
    if (day != null) {
      selectedDay.value = _normalizeDate(day);
      selectedWeek.value = _getMondayOfWeek(day);
    } else {
      selectedDay.value = null;
    }
    fetchPrices();
  }

  void setPriceOrder(String value) {
    priceOrder.value = value;
  }

  void setMarketFilter(String value) {
    marketFilter.value = value == 'All' ? '' : value;
  }

  void setNameOrder(String value) {
    nameOrder.value = value;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.toLowerCase();
  }

  void _applyFiltersAndSorting() {
    List<CropPrice> result = List.from(prices);

    if (marketFilter.value.isNotEmpty) {
      result = result.where((price) => price.marketName == marketFilter.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      result = result.where((price) {
        final query = searchQuery.value;
        return price.cropName.toLowerCase().contains(query) ||
            price.cropType.toLowerCase().contains(query) ||
            price.marketName.toLowerCase().contains(query);
      }).toList();
    }

    result.sort((a, b) {
      if (priceOrder.value == 'Low to High') {
        final priceCompare = a.pricePerKg.compareTo(b.pricePerKg);
        if (priceCompare != 0) return priceCompare;
      } else if (priceOrder.value == 'High to Low') {
        final priceCompare = b.pricePerKg.compareTo(a.pricePerKg);
        if (priceCompare != 0) return priceCompare;
      }

      if (nameOrder.value == 'Ascending') {
        final nameCompare = a.cropName.compareTo(b.cropName);
        if (nameCompare != 0) return nameCompare;
      } else if (nameOrder.value == 'Descending') {
        final nameCompare = b.cropName.compareTo(a.cropName);
        if (nameCompare != 0) return nameCompare;
      }

      return b.date.compareTo(a.date);
    });

    filteredPrices.value = result;
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final daysToSubtract = (date.weekday - 1) % 7;
    return _normalizeDate(date.subtract(Duration(days: daysToSubtract)));
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}