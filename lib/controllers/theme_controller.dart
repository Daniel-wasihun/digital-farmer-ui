import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read('isDarkMode') ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write('isDarkMode', isDarkMode.value);
  }

  ThemeData getTheme() {
    return isDarkMode.value
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey[800],
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.grey.shade200),
              bodyMedium: TextStyle(color: Colors.grey.shade400),
              titleLarge: TextStyle(
                  color: Colors.grey.shade200, fontWeight: FontWeight.bold),
            ),
            iconTheme: IconThemeData(color: Colors.grey.shade200),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.grey.shade200,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade300,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.grey.shade200,
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[850],
              selectedItemColor: Colors.blue.shade300,
              unselectedItemColor: Colors.grey.shade400,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[800]?.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIconColor: Colors.grey.shade400,
              labelStyle: TextStyle(color: Colors.grey.shade400),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.grey.shade800),
              bodyMedium: TextStyle(color: Colors.grey.shade600),
              titleLarge: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.bold),
            ),
            iconTheme: IconThemeData(color: Colors.grey.shade800),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade200,
                foregroundColor: Colors.grey.shade800,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade300,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.grey,
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100]?.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIconColor: Colors.grey.shade600,
              labelStyle: TextStyle(color: Colors.grey.shade600),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          );
  }
}