import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
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

  static const String aiBaseUrl = BaseApi.aiBaseUrl;

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
          Get.snackbar(
            'Error'.tr,
            'An error occurred. Please try again.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        storage.remove('weatherData');
        Get.snackbar(
          'Error'.tr,
          'An error occurred. Please try again.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
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

  Future<void> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    isOffline.value = false;

    try {
      print('Fetching weather data for $city ($latitude, $longitude)');
      final response = await http.get(
        Uri.parse('$aiBaseUrl/weather?latitude=$latitude&longitude=$longitude&city=$city'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (isValidWeatherData(data)) {
          weatherData.value = data;
          storage.write('weatherData', jsonEncode(data));
          print('Weather data fetched successfully');
        } else {
          Get.snackbar(
            'Error'.tr,
            'An error occurred. Please try again.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          loadCachedData();
        }
      } else {
        Get.snackbar(
          'Error'.tr,
          'An error occurred. Please try again.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        loadCachedData();
        print('Weather fetch error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'An error occurred. Please try again.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      loadCachedData();
      print('Weather fetch exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> askWeatherQuestion() async {
    if (questionController.text.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please enter a question'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isAskLoading.value = true;
    askAnswer.value = null;
    try {
      final payload = {
        'question': questionController.text,
        'latitude': 11.7833,
        'longitude': 39.6,
        'city': 'weldiya',
        'language': Get.locale?.languageCode ?? 'en',
      };
      print('Sending request to $aiBaseUrl/ask/weather: $payload');
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
        print('Received answer: ${askAnswer.value}');
      } else {
        Get.snackbar(
          'Error'.tr,
          'An error occurred. Please try again.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Error response: status=${response.statusCode}, body=${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'An error occurred. Please try again.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Request error: $e');
    } finally {
      isAskLoading.value = false;
    }
  }

  void toggleLanguage() {
    final newLocale = Get.locale?.languageCode == 'en' ? const Locale('am', 'ET') : const Locale('en', 'US');
    Get.updateLocale(newLocale);
    print('Locale changed to: ${newLocale.languageCode}');
  }
}