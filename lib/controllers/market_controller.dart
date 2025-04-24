import 'package:get/get.dart';
import 'dart:math';

class MarketController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final Map<String, Map<String, dynamic>> cropData = {
    "teff": {"category": "Cereal"},
    "maize": {"category": "Cereal"},
    "wheat": {"category": "Cereal"},
    "barley": {"category": "Cereal"},
    "sorghum": {"category": "Cereal"},
    "millet": {"category": "Cereal"},
    "oats": {"category": "Cereal"},
    "finger_millet": {"category": "Cereal"},
    "triticale": {"category": "Cereal"},
    "rice": {"category": "Cereal"},
    "chickpea": {"category": "Pulse"},
    "haricot_bean": {"category": "Pulse"},
    "lentil": {"category": "Pulse"},
    "faba_bean": {"category": "Pulse"},
    "pea": {"category": "Pulse"},
    "grass_pea": {"category": "Pulse"},
    "soybean": {"category": "Pulse"},
    "niger_seed": {"category": "Oilseed"},
    "flaxseed": {"category": "Oilseed"},
    "sesame": {"category": "Oilseed"},
    "groundnut": {"category": "Oilseed"},
    "sunflower": {"category": "Oilseed"},
    "potato": {"category": "Root/Tuber"},
    "sweet_potato": {"category": "Root/Tuber"},
    "taro": {"category": "Root/Tuber"},
    "cassava": {"category": "Root/Tuber"},
    "yam": {"category": "Root/Tuber"},
    "enset": {"category": "Root/Tuber"},
    "onion": {"category": "Vegetable"},
    "tomato": {"category": "Vegetable"},
    "cabbage": {"category": "Vegetable"},
    "carrot": {"category": "Vegetable"},
    "beetroot": {"category": "Vegetable"},
    "kale": {"category": "Vegetable"},
    "lettuce": {"category": "Vegetable"},
    "spinach": {"category": "Vegetable"},
    "green_pepper": {"category": "Vegetable"},
    "eggplant": {"category": "Vegetable"},
    "okra": {"category": "Vegetable"},
    "squash": {"category": "Vegetable"},
    "avocado": {"category": "Fruit"},
    "banana": {"category": "Fruit"},
    "mango": {"category": "Fruit"},
    "papaya": {"category": "Fruit"},
    "orange": {"category": "Fruit"},
    "lemon": {"category": "Fruit"},
    "lime": {"category": "Fruit"},
    "grapefruit": {"category": "Fruit"},
    "pineapple": {"category": "Fruit"},
    "guava": {"category": "Fruit"},
    "chilli_pepper": {"category": "Spice"},
    "ginger": {"category": "Spice"},
    "turmeric": {"category": "Spice"},
    "garlic": {"category": "Spice"},
    "fenugreek": {"category": "Spice"},
    "coriander": {"category": "Spice"},
    "coffee": {"category": "Beverage"},
    "tea": {"category": "Beverage"},
    "sugarcane": {"category": "Sugar Crop"},
    "tobacco": {"category": "Cash Crop"},
    "cotton": {"category": "Cash Crop"},
    "cut_flowers": {"category": "Cash Crop"},
  };

  final double etbToUsd = 0.0083; // Approximate conversion rate as of April 2025
  final Random random = Random();

  List<MapEntry<String, Map<String, dynamic>>> getFilteredCrops() {
    return selectedCategory.value == 'All'
        ? cropData.entries.toList()
        : cropData.entries
            .where((entry) => entry.value['category'] == selectedCategory.value)
            .toList();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }
}