import 'package:digital_farmers/models/crop_price.dart';
import 'package:digital_farmers/services/market_service.dart';
import 'package:digital_farmers/services/storage_service.dart';
import 'package:digital_farmers/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class MarketController extends GetxController {
  final MarketService _marketService = Get.put(MarketService());
  final StorageService _storageService = Get.find<StorageService>();
  final GetStorage box = GetStorage();
  final logger = Logger();
  bool _isInitialized = false;

  // Observables
  final prices = <CropPrice>[].obs;
  final filteredPrices = <CropPrice>[].obs;
  final selectedWeek = Rxn<DateTime>();
  final selectedDay = Rxn<DateTime>();
  final priceOrder = 'Default'.obs;
  final marketFilter = ''.obs;
  final nameOrder = 'Default'.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final isAdmin = false.obs;

  // Sorting options
  final List<String> priceSortOptions = ['Default', 'Low to High', 'High to Low'];
  final List<String> nameSortOptions = ['Default', 'Ascending', 'Descending'];

  // Getters for service data
  Map<String, List<String>> get cropData => _marketService.cropData;
  List<String> get marketNames => _marketService.marketNames;

  @override
  void onInit() {
    super.onInit();
    // Initialize filters
    selectedWeek.value = AppUtils.getMondayOfWeek(DateTime.now());
    selectedDay.value = null;
    nameOrder.value = 'Default';
    priceOrder.value = 'Default';
    marketFilter.value = '';

    // Initialize admin status
    _checkAdminStatus();
    logger.i('MarketController: Initialized with isAdmin: ${isAdmin.value}');

    // Fetch initial data
    fetchCropData();
    fetchPrices();

    // React to filter changes with a slight delay
    everAll([
      selectedWeek,
      selectedDay,
      priceOrder,
      marketFilter,
      nameOrder,
      searchQuery,
    ], (_) {
      if (_isInitialized) {
        Future.microtask(() => _applyFiltersAndSorting());
      }
    });

    // Listen to user changes to update admin status
    ever(_storageService.user, (_) {
      _checkAdminStatus();
      logger.i('MarketController: User changed, updated isAdmin: ${isAdmin.value}');
    });
  }

  @override
  void onReady() {
    super.onReady();
    _isInitialized = true;
    _applyFiltersAndSorting();
    logger.i('MarketController: onReady, isAdmin: ${isAdmin.value}');
  }

  // Check admin status
  void _checkAdminStatus() {
    isAdmin.value = _storageService.getIsAdmin();
    logger.i('MarketController: Checked admin status, isAdmin: ${isAdmin.value}');
    // Explicitly log no redirect for non-admin users
    if (!isAdmin.value) {
      logger.i('MarketController: Non-admin user detected, no navigation enforced');
    }
  }

  // Fetch crop data
  Future<void> fetchCropData() async {
    isLoading.value = true;
    try {
      await _marketService.fetchCropData();
      logger.i('MarketController: Fetched crop data');
    } catch (e) {
      logger.e('MarketController: Error fetching crop data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch prices
  Future<void> fetchPrices() async {
    isLoading.value = true;
    try {
      prices.value = await _marketService.fetchPrices(
        selectedDay: selectedDay.value,
        selectedWeek: selectedWeek.value,
      );
      if (_isInitialized) {
        _applyFiltersAndSorting();
      }
      logger.i('MarketController: Fetched ${prices.length} prices');
    } catch (e) {
      logger.e('MarketController: Error fetching prices: $e');
      prices.clear();
      filteredPrices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Check if price exists
  Future<bool> checkPriceExists(CropPrice price) async {
    try {
      final exists = await _marketService.checkPriceExists(price);
      logger.i(
          'MarketController: Duplicate check for ${price.cropName}, ${price.cropType}, ${price.marketName}, ${price.date}: $exists');
      return exists;
    } catch (e) {
      logger.e('MarketController: Error checking price existence: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: 'Failed to check price existence'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
        mainButton: TextButton(
          onPressed: () => checkPriceExists(price),
          child: Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
        ),
      );
      return false; // Assume no duplicate if check fails
    }
  }

  // Add price
  Future<void> addPrice(CropPrice price) async {
    isLoading.value = true;
    try {
      await _marketService.addPrice(price);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Price added successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Price added successfully');
    } catch (e) {
      logger.e('MarketController: Error adding price: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: e.toString().tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update price
  Future<void> updatePrice(String id, CropPrice price) async {
    isLoading.value = true;
    try {
      await _marketService.updatePrice(id, price);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Price updated successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Price updated successfully for ID: $id');
    } catch (e) {
      logger.e('MarketController: Error updating price: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: e.toString().tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete price
  Future<void> deletePrice(String id) async {
    isLoading.value = true;
    try {
      await _marketService.deletePrice(id);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Price deleted successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Price deleted successfully for ID: $id');
    } catch (e) {
      logger.e('MarketController: Error deleting price: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: 'Failed to delete price'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Clone prices
  Future<Map<String, dynamic>> clonePrices(List<DateTime> sourceDays, DateTime targetDate) async {
    isLoading.value = true;
    try {
      final result = await _marketService.clonePrices(sourceDays, targetDate);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Prices cloned successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Cloned prices successfully');
      return result;
    } catch (e) {
      logger.e('MarketController: Error cloning prices: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: 'Failed to clone prices'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Undo clone
  Future<void> undoClonePrices(List<String> priceIds, DateTime weekStart) async {
    isLoading.value = true;
    try {
      await _marketService.undoClonePrices(priceIds, weekStart);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Clone undone successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Clone undone successfully');
    } catch (e) {
      logger.e('MarketController: Error undoing clone: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: 'Failed to undo clone'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Batch insert prices
  Future<void> batchInsertPrices(List<CropPrice> pricesToInsert) async {
    isLoading.value = true;
    try {
      await _marketService.batchInsertPrices(pricesToInsert);
      await fetchPrices();
      AppUtils.showSnackbar(
        title: 'Success'.tr,
        message: 'Prices batch inserted successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      logger.i('MarketController: Batch inserted ${pricesToInsert.length} prices');
    } catch (e) {
      logger.e('MarketController: Error batch inserting prices: $e');
      AppUtils.showSnackbar(
        title: 'Error'.tr,
        message: 'Failed to batch insert prices'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        textColor: Colors.white,
        position: SnackPosition.TOP,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Setters for filters
  void setSelectedWeek(DateTime? week) {
    selectedWeek.value = week != null ? AppUtils.normalizeDate(week) : null;
    selectedDay.value = null;
    fetchPrices();
  }

  void setSelectedDay(DateTime? day) {
    if (day != null) {
      selectedDay.value = AppUtils.normalizeDate(day);
      selectedWeek.value = AppUtils.getMondayOfWeek(day);
    } else {
      selectedDay.value = null;
    }
    fetchPrices();
  }

  void setPriceOrder(String value) {
    if (priceSortOptions.contains(value)) {
      priceOrder.value = value;
    }
  }

  void setMarketFilter(String value) {
    marketFilter.value = value == 'All' ? '' : value;
  }

  void setNameOrder(String value) {
    if (nameSortOptions.contains(value)) {
      nameOrder.value = value;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.toLowerCase();
  }

  // Apply filters and sorting
  void _applyFiltersAndSorting() {
    filteredPrices.value = _marketService.filterAndSortPrices(
      prices: prices,
      selectedWeek: selectedWeek.value,
      selectedDay: selectedDay.value,
      searchQuery: searchQuery.value,
      nameOrder: nameOrder.value,
      priceOrder: priceOrder.value,
      marketFilter: marketFilter.value.isEmpty ? 'All' : marketFilter.value,
    );
  }
}