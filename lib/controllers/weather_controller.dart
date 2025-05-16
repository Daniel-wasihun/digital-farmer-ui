import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherController extends GetxController {
  final storage = GetStorage();
  var weatherData = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var errorMessage = ''.obs;
  var isOffline = false.obs;

  var questionController = TextEditingController();
  var askAnswer = Rxn<String>();
  var isAskLoading = false.obs;

  static const String aiBaseUrl = BaseApi.aiBaseUrl;
  static const String openCageBaseUrl = 'https://api.opencagedata.com/geocode/v1/json';

  @override
  void onInit() async {
    super.onInit();
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Failed to load .env file: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to load configuration. Using cached data.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
      final position = await _getDeviceLocation();
      if (position == null) {
        print('Failed to get device location for storage');
        return;
      }

      final city = await _getCityFromCoordinates(position.latitude, position.longitude);
      if (city == null) {
        print('Failed to get city for storage');
        return;
      }

      await storage.write('latitude', position.latitude);
      await storage.write('longitude', position.longitude);
      await storage.write('city', city);
      print('Stored location: $city (${position.latitude}, ${position.longitude})');

      await fetchWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
      );
    } catch (e) {
      print('Error storing location: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to fetch location. Using cached data.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      loadCachedData();
    } finally {
      isLocationLoading.value = false;
    }
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
            'Invalid cached data. Please try again.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        storage.remove('weatherData');
        Get.snackbar(
          'Error'.tr,
          'Failed to load cached data. Please try again.'.tr,
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
  
    Future<Position?> _getDeviceLocation() async {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.snackbar(
            'Error'.tr,
            'Location services are disabled.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
  
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            Get.snackbar(
              'Error'.tr,
              'Location permissions are denied.'.tr,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return null;
          }
        }
  
        if (permission == LocationPermission.deniedForever) {
          Get.snackbar(
            'Error'.tr,
            'Location permissions are permanently denied.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
  
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        Get.snackbar(
          'Error'.tr,
          'Failed to get device location.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Location fetch exception: $e');
        return null;
      }
    }
  
    Future<String?> _getCityFromCoordinates(double latitude, double longitude) async {
      try {
        final apiKey = dotenv.env['OPEN_CAGE_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          Get.snackbar(
            'Error'.tr,
            'API key is missing or invalid.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
  
        final response = await http.get(
          Uri.parse('$openCageBaseUrl?q=$latitude,+$longitude&key=$apiKey'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));
  
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final components = results[0]['components'] as Map<String, dynamic>;
            return components['town']?.toString() ??
                components['_normalized_city']?.toString() ??
                'Unknown';
          } else {
            Get.snackbar(
              'Error'.tr,
              'No city found for the given coordinates.'.tr,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return null;
          }
        } else {
          Get.snackbar(
            'Error'.tr,
            'Failed to fetch city name.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          print('City fetch error: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        Get.snackbar(
          'Error'.tr,
          'Failed to fetch city name.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('City fetch exception: $e');
        return null;
      }
    }
  
    Future<void> fetchDeviceWeatherData() async {
      final cachedLatitude = storage.read('latitude');
      final cachedLongitude = storage.read('longitude');
      final cachedCity = storage.read('city');
  
      if (cachedLatitude != null && cachedLongitude != null && cachedCity != null) {
        print('Using stored location: $cachedCity ($cachedLatitude, $cachedLongitude)');
        await fetchWeatherData(
          latitude: cachedLatitude,
          longitude: cachedLongitude,
          city: cachedCity,
        );
      } else {
        final position = await _getDeviceLocation();
        if (position == null) {
          loadCachedData();
          return;
        }
  
        final city = await _getCityFromCoordinates(position.latitude, position.longitude);
        if (city == null) {
          loadCachedData();
          return;
        }
  
        await storage.write('latitude', position.latitude);
        await storage.write('longitude', position.longitude);
        await storage.write('city', city);
  
        await fetchWeatherData(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
        );
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
            errorMessage.value = 'Invalid weather data received. Please try again.'.tr;
            loadCachedData();
          }
        } else {
          errorMessage.value = 'Failed to fetch weather data. Please try again.'.tr;
          loadCachedData();
          print('Weather fetch error: ${response.statusCode}');
        }
      } catch (e) {
        errorMessage.value = 'Failed to fetch weather data. Please try again.'.tr;
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
  
      final cachedLatitude = storage.read('latitude');
      final cachedLongitude = storage.read('longitude');
      final cachedCity = storage.read('city');
  
      double latitude = cachedLatitude ?? 11.7833;
      double longitude = cachedLongitude ?? 39.6;
      String city = cachedCity ?? 'unknown';
  
      if (cachedLatitude == null || cachedLongitude == null || cachedCity == null) {
        final position = await _getDeviceLocation();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          city = await _getCityFromCoordinates(latitude, longitude) ?? 'unknown';
          await storage.write('latitude', latitude);
          await storage.write('longitude', longitude);
          await storage.write('city', city);
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
            'Failed to get answer. Please try again.'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          print('Error response: status=${response.statusCode}, body=${utf8.decode(response.bodyBytes)}');
        }
      } catch (e) {
        Get.snackbar(
          'Error'.tr,
          'Failed to get answer. Please try again.'.tr,
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