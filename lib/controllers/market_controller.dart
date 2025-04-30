import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/crop_price.dart';

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
    selectedWeek.value = _getMondayOfWeek(DateTime.now()); // Default to "This Week"
    selectedDay.value = null; // Default to "All"
    nameOrder.value = "Default"; // Default to "Default"
    priceOrder.value = "Default"; // Default to "Default"
    marketFilter.value = ""; // Default to "All"
    fetchCropData(); // Fetch crop data to ensure dropdowns are populated
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

  // Fetch crop data from MongoDB to populate dropdowns
  Future<void> fetchCropData() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('http://localhost:5000/api/crops'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final Map<String, List<String>> tempCropData = {};
        for (var item in data) {
          final cropName = item['cropName'] as String;
          final cropType = item['cropType'] as String;
          if (!tempCropData.containsKey(cropName)) {
            tempCropData[cropName] = [];
          }
          if (!tempCropData[cropName]!.contains(cropType)) {
            tempCropData[cropName]!.add(cropType);
          }
        }
        cropData.clear();
        cropData.addAll(tempCropData);
      } else {
        throw Exception('Failed to fetch crop data: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to fetch crop data: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch prices from MongoDB
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

      final uri = Uri.http('localhost:5000', '/api/prices', queryParams);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch prices: ${response.statusCode} ${response.body}');
      }

      final data = jsonDecode(response.body);
      prices.value = (data['prices'] as List).map((e) => CropPrice.fromJson({
        '_id': e['_id'],
        'cropName': e['cropName'],
        'cropType': e['cropType'],
        'marketName': e['marketName'],
        'pricePerKg': e['pricePerKg'],
        'pricePerQuintal': e['pricePerQuintal'],
        'date': e['date'],
        'createdAt': e['createdAt'],
        'updatedAt': e['updatedAt']
      })).toList();

      _applyFiltersAndSorting();
    } catch (e) {
      prices.clear();
      filteredPrices.clear();
      Get.snackbar('Error'.tr, 'Failed to fetch prices: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new price to MongoDB
  Future<void> addPrice(CropPrice price) async {
    try {
      isLoading.value = true;
      price = price.copyWith(
        date: _normalizeDate(price.date),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Client-side validation
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
      if ((price.pricePerQuintal - price.pricePerKg * 50).abs() > 0.01) {
        throw Exception('Price per quintal must be 50 times price per kg'.tr);
      }

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/prices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()..remove('_id')),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to add price: ${errorData['error'] ?? response.body}'.tr);
      }

      await fetchPrices();
      Get.snackbar('Success'.tr, 'Price added successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to add price: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing price in MongoDB
  Future<void> updatePrice(String id, CropPrice price) async {
    try {
      isLoading.value = true;
      price = price.copyWith(
        date: _normalizeDate(price.date),
        updatedAt: DateTime.now(),
      );

      // Client-side validation
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
      if ((price.pricePerQuintal - price.pricePerKg * 50).abs() > 0.01) {
        throw Exception('Price per quintal must be 50 times price per kg'.tr);
      }

      final response = await http.put(
        Uri.parse('http://localhost:5000/api/prices/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to update price: ${errorData['error'] ?? response.body}'.tr);
      }

      await fetchPrices();
      Get.snackbar('Success'.tr, 'Price updated successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to update price: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a price from MongoDB
  Future<void> deletePrice(String id, DateTime date) async {
    try {
      isLoading.value = true;
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/prices/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to delete price: ${errorData['error'] ?? response.body}'.tr);
      }

      await fetchPrices();
      Get.snackbar('Success'.tr, 'Price deleted successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to delete price: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Clone prices from one week to another
  Future<Map<String, dynamic>> clonePrices(List<DateTime> sourceDays, DateTime targetDate) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/prices/clone'),
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
      Get.snackbar('Error'.tr, 'Failed to clone prices: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Undo cloning by deleting cloned prices
  Future<void> undoClonePrices(List<String> priceIds, DateTime weekStart) async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/prices/delete-batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'priceIds': priceIds,
          'weekStart': _normalizeDate(weekStart).toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to undo clone: ${errorData['error'] ?? response.body}'.tr);
      }

      await fetchPrices();
      Get.snackbar('Success'.tr, 'Clone operation undone successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to undo clone: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Batch insert prices (for initial data or bulk operations)
  Future<void> batchInsertPrices(List<CropPrice> pricesToInsert) async {
    try {
      isLoading.value = true;
      final validatedPrices = pricesToInsert.map((price) {
        if (price.cropName.isEmpty ||
            price.cropType.isEmpty ||
            !marketNames.contains(price.marketName) ||
            price.pricePerKg <= 0 ||
            (price.pricePerQuintal - price.pricePerKg * 50).abs() > 0.01) {
          throw Exception('Invalid price data for ${price.cropName}');
        }
        return price.copyWith(
          date: _normalizeDate(price.date),
          createdAt: price.createdAt ?? DateTime.now(),
          updatedAt: price.updatedAt ?? DateTime.now(),
        );
      }).toList();

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/prices/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prices': validatedPrices.map((p) => p.toJson()..remove('_id')).toList(),
        }),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to batch insert prices: ${errorData['error'] ?? response.body}'.tr);
      }

      await fetchPrices();
      Get.snackbar('Success'.tr, 'Batch inserted ${pricesToInsert.length} prices successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to batch insert prices: $e'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white);
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

      return b.date.compareTo(a.date); // Default to newest first
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