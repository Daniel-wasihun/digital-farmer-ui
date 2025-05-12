import 'dart:convert';
import 'package:agri/models/crop_price.dart';
import 'package:agri/services/api/base_api.dart';
import 'package:agri/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class MarketService extends GetxService {
  final logger = Logger();
  final String baseUrl = BaseApi.apiBaseUrl;

  // Crop data (initially populated, updated via API)
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
    "cut_flowers": ["rose", "lily"],
  };

  final List<String> marketNames = ["Local", "Export"];

  // Fetch crop data from API
  Future<void> fetchCropData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/prices/crops'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! List) {
          throw 'Invalid crop data format';
        }
        final Map<String, List<String>> tempCropData = {};
        for (var item in data) {
          final cropName = item['cropName'] as String?;
          final cropType = item['cropType'] as String?;
          if (cropName != null && cropType != null) {
            tempCropData.putIfAbsent(cropName, () => []);
            tempCropData[cropName]!.add(cropType);
            tempCropData[cropName] = tempCropData[cropName]!.toSet().toList();
          }
        }
        cropData.clear();
        cropData.addAll(tempCropData);
        logger.i('MarketService: Fetched ${tempCropData.length} crop types');
      } else {
        throw 'Failed to fetch crop data: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error fetching crop data: $e');
      throw 'Failed to load crop data. Please try again.';
    }
  }

  // Fetch prices from API
  Future<List<CropPrice>> fetchPrices({
    DateTime? selectedDay,
    DateTime? selectedWeek,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (selectedDay != null) {
        final dayStart = AppUtils.normalizeDate(selectedDay);
        final dayEnd =
            dayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        queryParams['dateStart'] = dayStart.toIso8601String();
        queryParams['dateEnd'] = dayEnd.toIso8601String();
      } else if (selectedWeek != null) {
        final weekStart = AppUtils.normalizeDate(selectedWeek);
        final weekEnd = AppUtils.normalizeDate(weekStart.add(const Duration(days: 6)));
        queryParams['dateStart'] = weekStart.toIso8601String();
        queryParams['dateEnd'] = weekEnd.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/prices').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic> || data['prices'] is! List) {
          throw 'Invalid price data format';
        }
        return (data['prices'] as List).map((e) {
          if (e['cropName'] == null ||
              e['cropType'] == null ||
              e['marketName'] == null ||
              e['pricePerKg'] == null ||
              e['pricePerQuintal'] == null ||
              e['date'] == null) {
            throw 'Invalid price data: missing required fields';
          }
          return CropPrice.fromJson({
            '_id': e['_id']?.toString() ?? '',
            'cropName': e['cropName'].toString(),
            'cropType': e['cropType'].toString(),
            'marketName': e['marketName'].toString(),
            'pricePerKg': (e['pricePerKg'] is num) ? e['pricePerKg'].toDouble() : 0.0,
            'pricePerQuintal':
                (e['pricePerQuintal'] is num) ? e['pricePerQuintal'].toDouble() : 0.0,
            'date': e['date'].toString(),
            'createdAt': e['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
            'updatedAt': e['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
          });
        }).toList();
      } else {
        throw 'Failed to fetch prices: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error fetching prices: $e');
      throw 'Failed to load prices. Please try again.';
    }
  }

  // Check if price exists (updated to check only for the exact date)
  Future<bool> checkPriceExists(CropPrice price) async {
    try {
      if (price.cropName.isEmpty || price.cropType.isEmpty || price.marketName.isEmpty) {
        throw 'Invalid price data for existence check';
      }
      final normalizedDate = AppUtils.normalizeDate(price.date);
      final queryParams = {
        'cropName': price.cropName,
        'cropType': price.cropType,
        'marketName': price.marketName,
        'dateStart': normalizedDate.toIso8601String(),
        'dateEnd': normalizedDate
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1))
            .toIso8601String(),
      };
      final uri = Uri.parse('$baseUrl/prices').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic> || data['prices'] is! List) {
          throw 'Invalid response format';
        }
        final prices = data['prices'] as List;
        // Check if any price matches the exact normalized date
        return prices.any((p) =>
            p['cropName'] == price.cropName &&
            p['cropType'] == price.cropType &&
            p['marketName'] == price.marketName &&
            AppUtils.normalizeDate(DateTime.parse(p['date'])) ==
                normalizedDate);
      }
      throw 'Failed to check price existence: ${response.statusCode}';
    } catch (e) {
      logger.e('MarketService: Error checking price existence: $e');
      throw 'Failed to check price existence. Please try again.';
    }
  }

  // Add price
  Future<void> addPrice(CropPrice price) async {
    try {
      final validatedPrice = price.copyWith(
        date: AppUtils.normalizeDate(price.date),
        createdAt: price.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (validatedPrice.cropName.isEmpty) {
        throw 'Crop name is required';
      }
      if (validatedPrice.cropType.isEmpty) {
        throw 'Crop type is required';
      }
      if (!marketNames.contains(validatedPrice.marketName)) {
        throw 'Invalid market name';
      }
      if (validatedPrice.pricePerKg <= 0) {
        throw 'Price per kg must be positive';
      }
      if (validatedPrice.pricePerQuintal < validatedPrice.pricePerKg * 50) {
        throw 'Price per quintal must be at least 50 times price per kg';
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/prices'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(validatedPrice.toJson()..remove('_id')),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw 'Failed to add price: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error adding price: $e');
      throw 'Failed to add price. Please try again.';
    }
  }

  // Update price
  Future<void> updatePrice(String id, CropPrice price) async {
    try {
      if (id.isEmpty) {
        throw 'Price ID required';
      }
      final validatedPrice = price.copyWith(
        date: AppUtils.normalizeDate(price.date),
        updatedAt: DateTime.now(),
      );
      if (validatedPrice.cropName.isEmpty) {
        throw 'Crop name is required';
      }
      if (validatedPrice.cropType.isEmpty) {
        throw 'Crop type is required';
      }
      if (!marketNames.contains(validatedPrice.marketName)) {
        throw 'Invalid market name';
      }
      if (validatedPrice.pricePerKg <= 0) {
        throw 'Price per kg must be positive';
      }
      if (validatedPrice.pricePerQuintal < validatedPrice.pricePerKg * 50) {
        throw 'Price per quintal must be at least 50 times price per kg';
      }

      final response = await http
          .put(
            Uri.parse('$baseUrl/prices/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(validatedPrice.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw 'Failed to update price: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error updating price: $e');
      throw 'Failed to update price. Please try again.';
    }
  }

  // Delete price
  Future<void> deletePrice(String id) async {
    try {
      if (id.isEmpty) {
        throw 'Price ID required';
      }
      final response = await http
          .delete(Uri.parse('$baseUrl/prices/$id'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw 'Failed to delete price: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error deleting price: $e');
      throw 'Failed to delete price. Please try again.';
    }
  }

  // Clone prices
  Future<Map<String, dynamic>> clonePrices(List<DateTime> sourceDays, DateTime targetDate) async {
    try {
      if (sourceDays.isEmpty) {
        throw 'Source days cannot be empty';
      }
      final response = await http
          .post(
            Uri.parse('$baseUrl/prices/clone'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sourceDays': sourceDays
                  .map((day) => AppUtils.normalizeDate(day).toIso8601String())
                  .toList(),
              'targetDate': AppUtils.normalizeDate(targetDate).toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw 'Failed to clone prices: ${response.statusCode}';
      }

      final responseData = jsonDecode(response.body);
      if (responseData is! Map<String, dynamic>) {
        throw 'Invalid response format';
      }
      return {
        'message': responseData['message']?.toString() ?? 'No prices available to clone',
        'clonedPriceIds': List<String>.from(responseData['clonedPriceIds'] ?? []),
      };
    } catch (e) {
      logger.e('MarketService: Error cloning prices: $e');
      throw 'Failed to clone prices. Please try again.';
    }
  }

  // Undo clone
  Future<void> undoClonePrices(List<String> priceIds, DateTime weekStart) async {
    try {
      if (priceIds.isEmpty) {
        throw 'Price IDs cannot be empty';
      }
      final response = await http
          .post(
            Uri.parse('$baseUrl/prices/delete-batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'priceIds': priceIds,
              'weekStart': AppUtils.normalizeDate(weekStart).toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw 'Failed to undo clone: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error undoing clone: $e');
      throw 'Failed to undo clone. Please try again.';
    }
  }

  // Batch insert prices
  Future<void> batchInsertPrices(List<CropPrice> pricesToInsert) async {
    try {
      if (pricesToInsert.isEmpty) {
        throw 'No prices provided for batch insert';
      }
      final validatedPrices = pricesToInsert.map((price) {
        if (price.cropName.isEmpty) {
          throw 'Crop name is required';
        }
        if (price.cropType.isEmpty) {
          throw 'Crop type is required';
        }
        if (!marketNames.contains(price.marketName)) {
          throw 'Invalid market name';
        }
        if (price.pricePerKg <= 0) {
          throw 'Price per kg must be positive';
        }
        if (price.pricePerQuintal < price.pricePerKg * 50) {
          throw 'Price per quintal must be at least 50 times price per kg';
        }
        return price.copyWith(
          date: AppUtils.normalizeDate(price.date),
          createdAt: price.createdAt ?? DateTime.now(),
          updatedAt: price.updatedAt ?? DateTime.now(),
        );
      }).toList();

      final response = await http
          .post(
            Uri.parse('$baseUrl/prices/batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prices': validatedPrices.map((p) => p.toJson()..remove('_id')).toList(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw 'Failed to batch insert prices: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('MarketService: Error batch inserting prices: $e');
      throw 'Failed to batch insert prices. Please try again.';
    }
  }

  // Filter and sort prices
  List<CropPrice> filterAndSortPrices({
    required List<CropPrice> prices,
    DateTime? selectedWeek,
    DateTime? selectedDay,
    String searchQuery = '',
    String nameOrder = 'Default',
    String priceOrder = 'Default',
    String marketFilter = 'All',
  }) {
    var filtered = prices;

    // Apply week filter
    if (selectedWeek != null) {
      filtered = filtered
          .where((price) => AppUtils.isSameWeek(price.date, selectedWeek))
          .toList();
    }

    // Apply day filter
    if (selectedDay != null) {
      filtered = filtered
          .where((price) =>
              AppUtils.normalizeDate(price.date) ==
              AppUtils.normalizeDate(selectedDay))
          .toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where((price) =>
              price.cropName.toLowerCase().contains(query) ||
              price.cropType.toLowerCase().contains(query) ||
              price.marketName.toLowerCase().contains(query))
          .toList();
    }

    // Apply market filter
    if (marketFilter != 'All') {
      filtered = filtered
          .where((price) => price.marketName == marketFilter)
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      if (priceOrder == 'Low to High') {
        final priceCompare = a.pricePerKg.compareTo(b.pricePerKg);
        if (priceCompare != 0) return priceCompare;
      } else if (priceOrder == 'High to Low') {
        final priceCompare = b.pricePerKg.compareTo(a.pricePerKg);
        if (priceCompare != 0) return priceCompare;
      }

      if (nameOrder == 'Ascending') {
        final nameCompare = a.cropName.compareTo(b.cropName);
        if (nameCompare != 0) return nameCompare;
      } else if (nameOrder == 'Descending') {
        final nameCompare = b.cropName.compareTo(a.cropName);
        if (nameCompare != 0) return nameCompare;
      }

      return b.date.compareTo(a.date);
    });

    return filtered;
  }
}