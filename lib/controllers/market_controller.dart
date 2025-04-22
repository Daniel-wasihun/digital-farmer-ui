import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MarketController extends GetxController {
  var marketData = Rxn<List<dynamic>>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMarketData();
    });
  }

  Future<void> fetchMarketData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/market'));
      if (response.statusCode == 200) {
        marketData.value = jsonDecode(response.body);
      } else {
        errorMessage.value = 'Error Fetching Market Data: ${response.statusCode}'.tr;
      }
    } catch (e) {
      errorMessage.value = 'Error Fetching Market Data: $e'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMarketDataSafely() {
    Future.delayed(Duration.zero, () {
      fetchMarketData();
    });
  }
}