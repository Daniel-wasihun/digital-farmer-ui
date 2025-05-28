import 'dart:async';
import 'dart:convert';
import 'package:digital_farmers/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class WeatherController extends GetxController {
  final StorageService _storageService = StorageService();
  final LocationService locationService = LocationService();
  var weatherData = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var errorMessage = ''.obs;
  var isOffline = false.obs;

  var questionController = TextEditingController();
  var askAnswer = Rxn<String>();
  var isAskLoading = false.obs;

  static const String aiBaseUrl = BaseApi.aiBaseUrl;

  final Logger _logger = Logger();

  @override
  void onInit() async {
    super.onInit();
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      _logger.e('Failed to load .env file: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to load configuration. Using cached data.'.tr,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      loadCachedData();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadCachedData();
      await fetchDeviceWeatherData();
    });
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }

  Future<void> storeUserLocation() async {
    isLocationLoading.value = true;
    try {
      await locationService.storeUserLocation();
      final location = await locationService.getStoredLocation();
      if (location == null) {
        _logger.w('Failed to store or retrieve location');
        loadCachedData();
        return;
      }
      await fetchWeatherData(
        latitude: location['latitude'],
        longitude: location['longitude'],
        city: location['city'],
      );
    } catch (e) {
      _logger.e('Error storing location: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to fetch location. Using cached data.'.tr,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      loadCachedData();
    } finally {
      isLocationLoading.value = false;
    }
  }

  void loadCachedData() {
    final cachedData = _storageService.read<String>('weatherData');
    if (cachedData != null) {
      try {
        final parsedData = jsonDecode(cachedData);
        if (isValidWeatherData(parsedData)) {
          weatherData.value = parsedData;
          isOffline.value = true;
        } else {
          _storageService.write('weatherData', null);
          Get.snackbar(
            'Error'.tr,
            'Invalid cached data. Please try again.'.tr,
            backgroundColor: Colors.black,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
          );
        }
      } catch (e) {
        _storageService.write('weatherData', null);
        Get.snackbar(
          'Error'.tr,
          'Failed to load cached data. Please try again.'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  bool isValidWeatherData(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    return data.containsKey('location') &&
        data['location'] is Map &&
        data['location'].containsKey('name') &&
        data.containsKey('current') &&
        data['current'] is Map &&
        data['current'].containsKey('condition') &&
        data['current'].containsKey('temperature') &&
        data.containsKey('forecast') &&
        data['forecast'] is List &&
        data.containsKey('historical') &&
        data['historical'] is List &&
        data.containsKey('cropData') &&
        data.containsKey('irrigation') &&
        data.containsKey('pestDiseaseRisk') &&
        data.containsKey('tempStress') &&
        data.containsKey('plantingWindows');
  }

  Future<void> fetchDeviceWeatherData() async {
    final location = await locationService.getStoredLocation();
    if (location != null) {
      _logger.i('Using stored location: ${location['city']} (${location['latitude']}, ${location['longitude']})');
      await fetchWeatherData(
        latitude: location['latitude'],
        longitude: location['longitude'],
        city: location['city'],
      );
    } else {
      await storeUserLocation();
    }
  }

  Future<void> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    isOffline.value = false;

    try {
      _logger.i('Fetching weather data for $city ($latitude, $longitude)');
      final response = await http.get(
        Uri.parse('$aiBaseUrl/weather?latitude=$latitude&longitude=$longitude&city=$city'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (isValidWeatherData(data)) {
          weatherData.value = data;
          await _storageService.write('weatherData', jsonEncode(data));
          _logger.i('Weather data fetched successfully');
        } else {
          errorMessage.value = 'Invalid weather data received. Please try again.'.tr;
          loadCachedData();
        }
      } else {
        errorMessage.value = 'Failed to fetch weather data. Please try again.'.tr;
        loadCachedData();
        _logger.e('Weather fetch error: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch weather data. Please try again.'.tr;
      loadCachedData();
      _logger.e('Weather fetch exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> askWeatherQuestion() async {
    if (questionController.text.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please enter a question'.tr,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      return;
    }

    isAskLoading.value = true;
    askAnswer.value = null;

    double latitude = 11.7833;
    double longitude = 39.6;
    String city = 'unknown';

    final location = await locationService.getStoredLocation();
    if (location != null) {
      latitude = location['latitude'];
      longitude = location['longitude'];
      city = location['city'];
    } else {
      await locationService.storeUserLocation();
      final newLocation = await locationService.getStoredLocation();
      if (newLocation != null) {
        latitude = newLocation['latitude'];
        longitude = newLocation['longitude'];
        city = newLocation['city'];
      }
    }

    try {
      final payload = {
        'question': questionController.text,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'language': Get.locale?.languageCode ?? 'en',
      };
      _logger.i('Sending request to $aiBaseUrl/ask/weather: $payload');
      final response = await http.post(
        Uri.parse('$aiBaseUrl/ask/weather'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        askAnswer.value = data['answer']?.toString() ?? 'No answer provided';
        _logger.i('Received answer: ${askAnswer.value}');
      } else {
        Get.snackbar(
          'Error'.tr,
          'Failed to get answer. Please try again.'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
        _logger.e('Error response: status=${response.statusCode}, body=${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to get answer. Please try again.'.tr,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      _logger.e('Request error: $e');
    } finally {
      isAskLoading.value = false;
    }
  }

  void toggleLanguage() {
    final newLocale = Get.locale?.languageCode == 'en' ? const Locale('am', 'ET') : const Locale('en', 'US');
    Get.updateLocale(newLocale);
    _storageService.saveLocale(newLocale.languageCode);
    _logger.i('Locale changed to: ${newLocale.languageCode}');
  }
}