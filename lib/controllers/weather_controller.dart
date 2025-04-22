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

  // For /api/ask endpoint
  var questionController = TextEditingController();
  var askAnswer = Rxn<String>();
  var isAskLoading = false.obs;

  // For /api/ask/{crop_type} endpoint
  var selectedCrop = 'teff'.obs;
  var cropInfo = Rxn<String>();
  var isCropInfoLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load cached data on init
    loadCachedData();
    // Fetch fresh data
    fetchWeatherData(latitude: 11.7833, longitude: 39.6, city: 'weldiya');
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }

  void loadCachedData() {
    final cachedData = storage.read('weatherData');
    if (cachedData != null) {
      weatherData.value = jsonDecode(cachedData);
    }
  }

  Future<void> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/weather?latitude=$latitude&longitude=$longitude&city=$city'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        weatherData.value = data;
        // Cache the data
        storage.write('weatherData', jsonEncode(data));
      } else {
        errorMessage.value = 'Error Fetching Weather Data: ${response.statusCode}'.tr;
        // Load cached data if available
        loadCachedData();
      }
    } catch (e) {
      errorMessage.value = 'Error Fetching Weather Data: $e'.tr;
      // Load cached data if available
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
        Uri.parse('http://127.0.0.1:8000/api/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': questionController.text,
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        askAnswer.value = data['answer'];
      } else {
        Get.snackbar('Error'.tr, 'Error Fetching Answer: ${response.statusCode}'.tr);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Error Fetching Answer: $e'.tr);
    } finally {
      isAskLoading.value = false;
    }
  }

  Future<void> fetchCropInfo(String cropType) async {
    isCropInfoLoading.value = true;
    cropInfo.value = null;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/ask/$cropType'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        cropInfo.value = data['answer'];
      } else {
        Get.snackbar('Error'.tr, 'Error Fetching Crop Info: ${response.statusCode}'.tr);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Error Fetching Crop Info: $e'.tr);
    } finally {
      isCropInfoLoading.value = false;
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