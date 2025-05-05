import 'dart:async';
import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:agri/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/crop_price.dart';
import 'package:logger/logger.dart';

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

  final logger = Logger();

  // Cache for week-based price data
  final weekPriceCache = <String, List<CropPrice>>{}.obs;

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

  final StorageService storageService = Get.find<StorageService>();

  // Debounce timer for filtering and sorting
  Timer? _filterDebounceTimer;
  static const _debounceDuration = Duration(milliseconds: 100);

  // Flag to track if we're in initial load
  bool _isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    // Defer initial setup to avoid build-phase conflicts
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      selectedWeek.value = _getMondayOfWeek(DateTime.now());
      selectedDay.value = null;
      nameOrder.value = "Default";
      priceOrder.value = "Default";
      marketFilter.value = "";
      _loadCachedWeekPrices();
      
      // Load cached data for current week immediately
      final weekKey = _getWeekCacheKey(selectedWeek.value!);
      if (weekPriceCache.containsKey(weekKey) && weekPriceCache[weekKey]!.isNotEmpty) {
        prices.value = weekPriceCache[weekKey]!;
        _debouncedApplyFiltersAndSorting();
      }
      
      // Fetch new data in background
      await Future.wait([
        fetchCropData(),
        fetchPrices(),
      ]);

      // After initial load, allow snackbars for subsequent errors
      _isInitialLoad = false;

      // Check if prices are still empty after fetch and cache load
      if (prices.isEmpty) {
        showSnackbar(
          title: 'Error'.tr,
          message: 'Unable to load prices. Please try again later.'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          textColor: Colors.white,
        );
      }

      // Set up everAll with debounced callback for client-side filtering
      everAll([
        priceOrder,
        marketFilter,
        nameOrder,
        searchQuery,
      ], (_) => _debouncedApplyFiltersAndSorting());

      // Set up ever for week and day changes
      everAll([selectedWeek, selectedDay], (_) => _handleWeekOrDayChange());
    });
  }

  @override
  void onClose() {
    _filterDebounceTimer?.cancel();
    super.onClose();
  }

  void showSnackbar({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.TOP,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    TextButton? mainButton,
  }) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
    });
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
            tempCropData[cropName] = tempCropData[cropName] ?? [];
            if (!tempCropData[cropName]!.contains(cropType)) {
              tempCropData[cropName]!.add(cropType);
            }
          }
        }
        cropData.clear();
        cropData.addAll(tempCropData);
      } else {
        throw Exception('Failed to fetch crop data');
      }
    } catch (e) {
      logger.e('Error fetching crop data: $e');
      if (!_isInitialLoad) {
        showSnackbar(
          title: 'Error'.tr,
          message: 'Unable to load crop data. Please try again later.'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          textColor: Colors.white,
        );
      }
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
        final weekEnd = weekStart.add(const Duration(days: 6));
        queryParams['dateStart'] = weekStart.toIso8601String();
        queryParams['dateEnd'] = _normalizeDate(weekEnd).toIso8601String();
      }

      final uri = Uri.parse('$apiBaseUrl/prices').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch prices');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newPrices = (data['prices'] as List).map((e) {
        if (e['cropName'] == null ||
            e['cropType'] == null ||
            e['marketName'] == null ||
            e['pricePerKg'] == null ||
            e['pricePerQuintal'] == null ||
            e['date'] == null) {
          throw Exception('Invalid price data');
        }
        return CropPrice.fromJson({
          '_id': e['_id'] as String?,
          'cropName': e['cropName'] as String,
          'cropType': e['cropType'] as String,
          'marketName': e['marketName'] as String,
          'pricePerKg': (e['pricePerKg'] as num).toDouble(),
          'pricePerQuintal': (e['pricePerQuintal'] as num).toDouble(),
          'date': e['date'] as String,
          'createdAt': e['createdAt'] as String? ?? DateTime.now().toIso8601String(),
          'updatedAt': e['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
        });
      }).toList();

      // Check if new data differs from current prices
      final weekKey = _getWeekCacheKey(selectedWeek.value!);
      if (!isSamePriceList(prices, newPrices)) {
        prices.value = newPrices;
        _savePricesToCache(selectedWeek.value, prices.value);
        _debouncedApplyFiltersAndSorting();
      }
    } catch (e) {
      logger.e('Error fetching prices: $e');
      if (!_isInitialLoad && prices.isEmpty) {
        _loadCachedWeekPrices();
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool isSamePriceList(List<CropPrice> list1, List<CropPrice> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].cropName != list2[i].cropName ||
          list1[i].cropType != list2[i].cropType ||
          list1[i].marketName != list2[i].marketName ||
          list1[i].pricePerKg != list2[i].pricePerKg ||
          list1[i].pricePerQuintal != list2[i].pricePerQuintal ||
          list1[i].date != list2[i].date) {
        return false;
      }
    }
    return true;
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final exists = (data['prices'] as List).isNotEmpty;
        logger.i('Duplicate price check: exists=$exists for ${price.cropName}, ${price.cropType}, ${price.marketName}, ${price.date}');
        return exists;
      }
      throw Exception('Failed to check price existence');
    } catch (e) {
      logger.e('Error checking price existence: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'Unable to check price existence. Please try again.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      return false;
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

      if (price.cropName.isEmpty) throw Exception('Crop name is required'.tr);
      if (price.cropType.isEmpty) throw Exception('Crop type is required'.tr);
      if (!marketNames.contains(price.marketName)) throw Exception('Invalid market name'.tr);
      if (price.pricePerKg <= 0) throw Exception('Price per kg must be positive'.tr);
      if (price.pricePerQuintal < price.pricePerKg * 50) {
        throw Exception('Price per quintal must be at least 50 times price per kg'.tr);
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/prices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()..remove('_id')),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to add price');
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
        message: e.toString().contains('required') || e.toString().contains('must be')
            ? e.toString()
            : 'Unable to add price. Please try again.'.tr,
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

      if (price.cropName.isEmpty) throw Exception('Crop name is required'.tr);
      if (price.cropType.isEmpty) throw Exception('Crop type is required'.tr);
      if (!marketNames.contains(price.marketName)) throw Exception('Invalid market name'.tr);
      if (price.pricePerKg <= 0) throw Exception('Price per kg must be positive'.tr);
      if (price.pricePerQuintal < price.pricePerKg * 50) {
        throw Exception('Price per quintal must be at least 50 times price per kg'.tr);
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/prices/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(price.toJson()),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to update price');
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
        message: e.toString().contains('required') || e.toString().contains('must be')
            ? e.toString()
            : 'Unable to update price. Please try again.'.tr,
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
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to delete price');
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
        message: 'Unable to delete price. Please try again.'.tr,
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
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to clone prices');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      await fetchPrices();
      return {
        'message': responseData['message'] ?? 'No prices available to clone',
        'clonedPriceIds': List<String>.from(responseData['clonedPriceIds'] ?? []),
      };
    } catch (e) {
      logger.e('Error cloning prices: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: 'Unable to clone prices. Please try again.'.tr,
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
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to undo clone');
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
        message: 'Unable to undo clone. Please try again.'.tr,
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
        if (price.cropName.isEmpty) throw Exception('Crop name is required for ${price.cropName}'.tr);
        if (price.cropType.isEmpty) throw Exception('Crop type is required for ${price.cropName}'.tr);
        if (!marketNames.contains(price.marketName)) throw Exception('Invalid market name for ${price.cropName}'.tr);
        if (price.pricePerKg <= 0) throw Exception('Price per kg must be positive for ${price.cropName}'.tr);
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
        body: jsonEncode({'prices': validatedPrices.map((p) => p.toJson()..remove('_id')).toList()}),
      );

      if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(errorData?['error'] ?? 'Failed to batch insert prices');
      }

      await fetchPrices();
      showSnackbar(
        title: 'Success'.tr,
        message: 'Batch inserted ${pricesToInsert.length} prices successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      logger.e('Error batch inserting prices: $e');
      showSnackbar(
        title: 'Error'.tr,
        message: e.toString().contains('required') || e.toString().contains('must be')
            ? e.toString()
            : 'Unable to batch insert prices. Please try again.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedWeek(DateTime? week) {
    final normalizedWeek = week != null ? _normalizeDate(week) : null;
    if (selectedWeek.value != normalizedWeek) {
      selectedWeek.value = normalizedWeek;
      selectedDay.value = null;
      _handleWeekOrDayChange();
    }
  }

  void setSelectedDay(DateTime? day) {
    if (day != null) {
      final normalizedDay = _normalizeDate(day);
      selectedDay.value = normalizedDay;
      selectedWeek.value = _getMondayOfWeek(normalizedDay);
    } else {
      selectedDay.value = null;
    }
    _handleWeekOrDayChange();
  }

  void setPriceOrder(String value) {
    priceOrder.value = value;
    _debouncedApplyFiltersAndSorting();
  }

  void setMarketFilter(String value) {
    marketFilter.value = value == 'All' ? '' : value;
    _debouncedApplyFiltersAndSorting();
  }

  void setNameOrder(String value) {
    nameOrder.value = value;
    _debouncedApplyFiltersAndSorting();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.toLowerCase();
    _debouncedApplyFiltersAndSorting();
  }

  void _handleWeekOrDayChange() {
    if (selectedWeek.value == null) {
      prices.clear();
      filteredPrices.clear();
      _debouncedApplyFiltersAndSorting();
      return;
    }

    final weekKey = _getWeekCacheKey(selectedWeek.value!);
    if (weekPriceCache.containsKey(weekKey)) {
      prices.value = weekPriceCache[weekKey]!;
      _debouncedApplyFiltersAndSorting();
    }
    // Always fetch new data in background
    fetchPrices();
  }

  void _debouncedApplyFiltersAndSorting() {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(_debounceDuration, () {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _applyFiltersAndSorting();
      });
    });
  }

  void _applyFiltersAndSorting() {
    List<CropPrice> result = List.from(prices);

    // Apply day filter
    if (selectedDay.value != null) {
      final dayStart = _normalizeDate(selectedDay.value!);
      final dayEnd = dayStart.add(const Duration(days: 1));
      result = result.where((price) {
        final priceDate = _normalizeDate(price.date);
        return priceDate.isAtSameMomentAs(dayStart) || (priceDate.isAfter(dayStart) && priceDate.isBefore(dayEnd));
      }).toList();
    }

    // Apply market filter
    if (marketFilter.value.isNotEmpty) {
      result = result.where((price) => price.marketName == marketFilter.value).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((price) {
        final query = searchQuery.value.toLowerCase();
        return price.cropName.toLowerCase().contains(query) ||
            price.cropType.toLowerCase().contains(query) ||
            price.marketName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
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

      return b.date.compareTo(a.date); // Default sort by date descending
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

  String _getWeekCacheKey(DateTime weekStart) {
    return _normalizeDate(weekStart).toIso8601String();
  }

  void _savePricesToCache(DateTime? weekStart, List<CropPrice> prices) {
    if (weekStart == null) return;
    final weekKey = _getWeekCacheKey(weekStart);
    weekPriceCache[weekKey] = List.from(prices);
    final jsonPrices = prices.map((price) => price.toJson()).toList();
    storageService.box.write('weekPrices_$weekKey', jsonEncode(jsonPrices));
    logger.i('Saved ${jsonPrices.length} prices to cache for week $weekKey');
  }

  void _loadCachedWeekPrices() {
    final keys = storageService.box.getKeys().where((key) {
      if (key is String) {
        return key.startsWith('weekPrices_');
      }
      return false;
    });
    for (var key in keys) {
      final storedPrices = storageService.box.read<String>(key);
      if (storedPrices != null) {
        try {
          final decodedPrices = (jsonDecode(storedPrices) as List)
              .map((json) => CropPrice.fromJson(json as Map<String, dynamic>))
              .toList();
          weekPriceCache[key.replaceFirst('weekPrices_', '')] = decodedPrices;
          logger.i('Loaded ${decodedPrices.length} prices from cache for $key');
        } catch (e) {
          logger.e('Error decoding cached prices for $key: $e');
          storageService.box.remove(key);
        }
      }
    }
  }
}