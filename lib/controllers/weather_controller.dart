import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class WeatherController extends GetxController {
  final storage = GetStorage();
  var weatherData = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isOffline = false.obs;

  var questionController = TextEditingController();
  var askAnswer = Rxn<String>();
  var isAskLoading = false.obs;

  // Configurable API base URL (update for production)
  static const String apiBaseUrl = 'http://127.0.0.1:8000'; // Replace with Vercel URL in production

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCachedData();
      fetchWeatherData(latitude: 11.7833, longitude: 39.6, city: 'weldiya');
    });
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }

  void loadCachedData() {
    final cachedData = storage.read('weatherData');
    if (cachedData != null) {
      try {
        final parsedData = jsonDecode(cachedData);
        if (isValidWeatherData(parsedData)) {
          weatherData.value = parsedData;
          isOffline.value = true;
        } else {
          storage.remove('weatherData');
          errorMessage.value = 'Invalid cached data cleared'.tr;
        }
      } catch (e) {
        storage.remove('weatherData');
        errorMessage.value = 'Error loading cached data: $e'.tr;
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

  Future<void> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    isOffline.value = false;

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/weather?latitude=$latitude&longitude=$longitude&city=$city'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (isValidWeatherData(data)) {
          weatherData.value = data;
          storage.write('weatherData', jsonEncode(data));
        } else {
          errorMessage.value = 'Invalid weather data received'.tr;
          loadCachedData();
        }
      } else {
        errorMessage.value = 'Error Fetching Weather Data: ${response.statusCode}'.tr;
        loadCachedData();
      }
    } catch (e) {
      errorMessage.value = 'Error Fetching Weather Data: $e'.tr;
      loadCachedData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> askWeatherQuestion() async {
    if (questionController.text.isEmpty) {
      Get.snackbar('Error'.tr, 'Please enter a question'.tr);
      return;
    }

    isAskLoading.value = true;
    askAnswer.value = null;
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': questionController.text,
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        askAnswer.value = data['answer']?.toString() ?? 'No answer provided';
      } else {
        Get.snackbar('Error'.tr, 'Error Fetching Answer: ${response.statusCode}'.tr);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Error Fetching Answer: $e'.tr);
    } finally {
      isAskLoading.value = false;
    }
  }

  Future<void> askCropQuestion(String crop) async {
    isAskLoading.value = true;
    askAnswer.value = null;
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/ask/$crop'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        askAnswer.value = data['answer']?.toString() ?? 'No answer provided';
      } else {
        Get.snackbar('Error'.tr, 'Error Fetching Crop Answer: ${response.statusCode}'.tr);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Error Fetching Crop Answer: $e'.tr);
    } finally {
      isAskLoading.value = false;
    }
  }

  void toggleLanguage() {
    if (Get.locale?.languageCode == 'en') {
      Get.updateLocale(const Locale('am', 'ET'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}