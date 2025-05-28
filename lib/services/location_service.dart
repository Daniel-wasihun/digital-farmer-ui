import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class LocationService {
  final StorageService _storageService = StorageService();
  final Logger _logger = Logger();
  static const String openCageBaseUrl = 'https://api.opencagedata.com/geocode/v1/json';

  Future<Map<String, dynamic>?> getStoredLocation() async {
    try {
      final latitude = _storageService.read<double>('latitude');
      final longitude = _storageService.read<double>('longitude');
      final city = _storageService.read<String>('city');

      if (latitude != null && longitude != null && city != null) {
        _logger.i('Using stored location: $city ($latitude, $longitude)');
        return {
          'latitude': latitude,
          'longitude': longitude,
          'city': city,
        };
      }
      _logger.i('No stored location found');
      return null;
    } catch (e) {
      _logger.e('Error reading stored location: $e');
      return null;
    }
  }

  Future<void> storeUserLocation() async {
    try {
      final position = await _getDeviceLocation();
      if (position == null) {
        _logger.w('Failed to get device location for storage');
        return;
      }

      final city = await _getCityFromCoordinates(position.latitude, position.longitude);
      if (city == null) {
        _logger.w('Failed to get city for storage');
        return;
      }

      await _storageService.write('latitude', position.latitude);
      await _storageService.write('longitude', position.longitude);
      await _storageService.write('city', city);
      _logger.i('Stored location: $city (${position.latitude}, ${position.longitude})');
    } catch (e) {
      _logger.e('Error storing location: $e');
      // Silently fail without showing snackbar
    }
  }

  Future<Position?> _getDeviceLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services are disabled.');
        Get.snackbar(
          'Enable Location Services'.tr,
          'Please enable location services in your device settings to use this feature.'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
            child: Text('Open Settings'.tr, style: TextStyle(color: Colors.blue)),
          ),
        );
        return null;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      _logger.i('Current location permission status: $permission');

      // If permission is already granted, fetch location directly
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _logger.i('Location permission already granted: $permission');
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(Duration(seconds: 10), onTimeout: () {
          throw TimeoutException('Location fetch timed out');
        });
      }

      // Request permission only if not granted
      _logger.i('Requesting location permission...');
      try {
        permission = await Geolocator.requestPermission();
      } on PlatformException catch (e) {
        _logger.e('Platform exception during permission request: $e');
        Get.snackbar(
          'Permission Error'.tr,
          'Failed to request location permission: ${e.message}'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
        return null;
      }

      if (permission == LocationPermission.denied) {
        _logger.w('Location permission denied.');
        Get.snackbar(
          'Location Permission Required'.tr,
          'Please grant location permission to use this feature.'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () async {
              await _getDeviceLocation();
            },
            child: Text('Retry'.tr, style: TextStyle(color: Colors.blue)),
          ),
        );
        return null;
      }
      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permission permanently denied.');
        Get.snackbar(
          'Location Permission Denied'.tr,
          'Location permission is permanently denied. Please enable it in app settings.'.tr,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 7),
          mainButton: TextButton(
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
            child: Text('Open Settings'.tr, style: TextStyle(color: Colors.blue)),
          ),
        );
        return null;
      }

      // Permission granted, get location
      _logger.i('Fetching location with permission: $permission');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Location fetch timed out');
      });
      _logger.i('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error fetching device location: $e');
      // Silently fail without showing snackbar
      return null;
    }
  }

  Future<String?> _getCityFromCoordinates(double latitude, double longitude) async {
    try {
      final apiKey = dotenv.env['OPEN_CAGE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _logger.e('API key is missing or invalid.');
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
          return null;
        }
      } else {
        _logger.e('City fetch error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('City fetch exception: $e');
      return null;
    }
  }
}