import 'dart:async';
import 'dart:convert';
import 'package:digital_farmers/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../services/location_service.dart';

class AIChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble textScaleFactor = 1.0.obs;
  final RxBool _showScrollToBottom = false.obs;
  bool get showScrollToBottom => _showScrollToBottom.value;
  final RxBool isSelectionMode = false.obs;
  final RxSet<int> selectedIndices = <int>{}.obs;
  final GetStorage _storage = GetStorage();
  final LocationService locationService = LocationService();
  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _apiUrl = '${BaseApi.aiBaseUrl}/ask/agriculture';
  static const int _maxQueryLength = 1000;
  static const int _maxRetries = 2;
  static const Duration _baseRetryDelay = Duration(milliseconds: 500);
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
        'Failed to load configuration.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    _loadChatHistory();
    scrollController.addListener(scrollListener);
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    _saveChatHistory();
    super.onClose();
  }

  Future<void> _loadChatHistory() async {
    try {
      await GetStorage.init();
      final storedHistory = _storage.read<String>(_chatHistoryKey);
      if (storedHistory != null) {
        final List<dynamic> decoded = jsonDecode(storedHistory);
        messages.value = decoded.map((item) {
          return {
            'sender': item['sender'],
            'text': item['text'],
            'isRich': item['isRich'] ?? false,
            'timestamp': DateTime.parse(item['timestamp']),
            'isError': item['isError'] ?? false,
            'query': item['query'],
            'canRetry': item['canRetry'] ?? false,
          };
        }).toList().cast<Map<String, dynamic>>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: false);
        });
      }
    } catch (e) {
      print('AIChatController: Error loading chat history: $e');
      Get.closeAllSnackbars();
      Get.snackbar(
        'error'.tr,
        'couldnt_load_chat_history'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      messages.clear();
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      await GetStorage.init();
      final encoded = jsonEncode(messages.map((message) {
        return {
          'sender': message['sender'],
          'text': message['text'],
          'isRich': message['isRich'],
          'timestamp': message['timestamp'].toIso8601String(),
          'isError': message['isError'],
          'query': message['query'],
          'canRetry': message['canRetry'] ?? false,
        };
      }).toList());
      await _storage.write(_chatHistoryKey, encoded);
    } catch (e) {
      print('AIChatController: Error saving chat history: $e');
      Get.closeAllSnackbars();
      Get.snackbar(
        'error'.tr,
        'couldnt_save_chat_history'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void scrollToBottom({bool animated = false}) {
    if (scrollController.hasClients) {
      if (animated) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }
  }

  void scrollListener() {
    final offset = scrollController.position.pixels;
    final maxExtent = scrollController.position.maxScrollExtent;
    // Show arrow if user is more than 100 pixels from the bottom and scrolled down a bit
    _showScrollToBottom.value = offset < maxExtent - 100 && offset > 200;
  }

  String _reformatResponse(String? rawResponse) {
    if (rawResponse == null || rawResponse.isEmpty) {
      return 'Sorry, I didn’t receive a response. Please try again.';
    }

    // Handle specific known responses
    if (rawResponse.contains('I am only aware of agricultural') ||
        rawResponse.contains('እኔ የማውቀው ስለ እርሻ')) {
      return rawResponse;
    }

    try {
      final lines = rawResponse.split('\n');
      final formattedLines = <String>[];
      bool inBulletSection = false;

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) {
          formattedLines.add('');
          continue;
        }

        if (line.startsWith('* **') && line.endsWith('**')) {
          formattedLines.add('**${line.replaceFirst('* **', '').replaceAll('**', '')}**');
          inBulletSection = false;
        } else if (line.startsWith('* ')) {
          formattedLines.add('• ${line.replaceFirst('* ', '')}');
          inBulletSection = true;
        } else if (inBulletSection && !line.startsWith('* ')) {
          formattedLines.add(line);
          inBulletSection = false;
        } else {
          formattedLines.add(line);
        }
      }
      return formattedLines.join('\n');
    } catch (e) {
      print('AIChatController: Error reformatting response: $e');
      return rawResponse; // Fallback to raw response if reformatting fails
    }
  }

  Future<void> sendMessage(String query, {bool isRetry = false, int retryCount = 0}) async {
    if (query.trim().isEmpty) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'error'.tr,
        'please_type_question'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (query.length > _maxQueryLength) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'error'.tr,
        'question_too_long'.trParams({'max': _maxQueryLength.toString()}),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final userMessage = {
      'sender': 'user',
      'text': query,
      'isRich': false,
      'timestamp': DateTime.now(),
      'isError': false,
      'query': query,
      'canRetry': false,
    };

    if (!isRetry) {
      messages.add(userMessage);
      _saveChatHistory();
      isLoading.value = true;
      textController.clear();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(animated: true);
    });

    // Fetch location
    double latitude = 11.7833; // Default fallback
    double longitude = 39.6;
    String city = 'weldiya';

    final cachedLocation = await locationService.getStoredLocation();
    if (cachedLocation != null) {
      latitude = cachedLocation['latitude'];
      longitude = cachedLocation['longitude'];
      city = cachedLocation['city'];
      _logger.i('Using cached location: $city ($latitude, $longitude)');
    } else {
      await locationService.storeUserLocation();
      final newLocation = await locationService.getStoredLocation();
      if (newLocation != null) {
        latitude = newLocation['latitude'];
        longitude = newLocation['longitude'];
        city = newLocation['city'];
        _logger.i('Using newly fetched location: $city ($latitude, $longitude)');
      } else {
        _logger.i('No location fetched, using default: $city ($latitude, $longitude)');
      }
    }

    http.Client? client;
    try {
      client = http.Client();
      final payload = {
        'query': query,
        'language': Get.locale?.languageCode ?? 'en',
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
      };
      _logger.i('Sending request to $_apiUrl: $payload');
      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final rawResponse = data['response']?.toString();
        final formattedResponse = _reformatResponse(rawResponse);
        final botMessage = {
          'sender': 'bot',
          'text': formattedResponse,
          'isRich': rawResponse != null &&
              !rawResponse.contains('I am only aware of agricultural') &&
              !rawResponse.contains('እኔ የማውቀው ስለ እርሻ'),
          'timestamp': DateTime.now(),
          'isError': false,
          'query': query,
          'canRetry': false,
        };
        messages.add(botMessage);
      } else {
        final errorDetail = response.statusCode == 400 || response.statusCode == 500
            ? (jsonDecode(utf8.decode(response.bodyBytes))['detail']?.toString() ?? 'unknown_error')
            : 'server_error';
        print('AIChatController: Server error: $errorDetail, status: ${response.statusCode}');
        final canRetry = response.statusCode == 500 && retryCount < _maxRetries;
        final errorMessage = {
          'sender': 'bot',
          'text': canRetry ? 'couldnt_process_try_again'.tr : 'couldnt_process'.tr,
          'isRich': false,
          'isError': true,
          'query': query,
          'timestamp': DateTime.now(),
          'canRetry': canRetry,
        };
        messages.add(errorMessage);
        if (canRetry) {
          await Future.delayed(_baseRetryDelay * (retryCount + 1));
          await sendMessage(query, isRetry: true, retryCount: retryCount + 1);
        }
      }
    } on TimeoutException catch (e) {
      print('AIChatController: Timeout error: $e');
      final canRetry = retryCount < _maxRetries;
      final errorMessage = {
        'sender': 'bot',
        'text': canRetry ? 'couldnt_connect_try_again'.tr : 'couldnt_connect'.tr,
        'isRich': false,
        'isError': true,
        'query': query,
        'timestamp': DateTime.now(),
        'canRetry': canRetry,
      };
      messages.add(errorMessage);
      if (canRetry) {
        await Future.delayed(_baseRetryDelay * (retryCount + 1));
        await sendMessage(query, isRetry: true, retryCount: retryCount + 1);
      }
    } on FormatException catch (e) {
      print('AIChatController: Response format error: $e');
      final errorMessage = {
        'sender': 'bot',
        'text': 'couldnt_process'.tr,
        'isRich': false,
        'isError': true,
        'query': query,
        'timestamp': DateTime.now(),
        'canRetry': false,
      };
      messages.add(errorMessage);
    } catch (e) {
      print('AIChatController: Generic error: $e');
      final errorMessage = {
        'sender': 'bot',
        'text': 'something_went_wrong'.tr,
        'isRich': false,
        'isError': true,
        'query': query,
        'timestamp': DateTime.now(),
        'canRetry': false,
      };
      messages.add(errorMessage);
    } finally {
      isLoading.value = false;
      client?.close();
      _saveChatHistory();
      messages.refresh();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: true);
      });
    }
  }

  void retryMessage(String query) {
    sendMessage(query, isRetry: true);
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedIndices.clear();
      selectedIndices.refresh();
    }
    messages.refresh();
  }

  void toggleMessageSelection(int index) {
    if (index < 0 || index >= messages.length) return;
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
    if (selectedIndices.isEmpty) {
      isSelectionMode.value = false;
    }
    selectedIndices.refresh();
    if (selectedIndices.isEmpty || selectedIndices.length == 1) {
      messages.refresh();
    }
  }

  void copySelectedMessages() {
    if (selectedIndices.isEmpty) return;
    final validIndices = selectedIndices.where((index) => index < messages.length).toList();
    if (validIndices.isEmpty) {
      clearSelection();
      return;
    }
    final selectedMessages = validIndices
        .map((index) => messages[index]['text'] as String)
        .toList()
        .join('\n');
    Clipboard.setData(ClipboardData(text: selectedMessages));
    Get.closeAllSnackbars();
    Get.snackbar(
      'success'.tr,
      'copied_to_clipboard'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Get.theme.colorScheme.onSecondary,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
    clearSelection();
  }

  void deleteSelectedMessages() {
    if (selectedIndices.isEmpty) return;
    final validIndices = selectedIndices.where((index) => index < messages.length).toList();
    if (validIndices.isEmpty) {
      clearSelection();
      return;
    }
    Get.dialog(
      AlertDialog(
        title: Text(
          'confirm_delete'.tr,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'delete_messages_confirmation'.trParams({
            'count': validIndices.length.toString(),
            'plural': validIndices.length > 1 ? 's' : '',
          }),
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Get.theme.colorScheme.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              validIndices.sort((a, b) => b.compareTo(a));
              for (var index in validIndices) {
                messages.removeAt(index);
              }
              _saveChatHistory();
              clearSelection();
              Get.closeAllSnackbars();
              Get.snackbar(
                'success'.tr,
                'messages_deleted'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: Get.theme.colorScheme.secondary,
                colorText: Get.theme.colorScheme.onSecondary,
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
                duration: const Duration(seconds: 3),
              );
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Get.theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearSelection() {
    selectedIndices.clear();
    isSelectionMode.value = false;
    selectedIndices.refresh();
    messages.refresh();
  }
}