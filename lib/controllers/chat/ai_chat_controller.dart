import 'dart:async';
import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

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
  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _apiUrl = '${BaseApi.aiBaseUrl}/ask/agriculture';

  @override
  void onInit() {
    super.onInit();
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
          };
        }).toList().cast<Map<String, dynamic>>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: false);
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      Get.snackbar('Error', 'Failed to load chat history: $e');
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
        };
      }).toList());
      await _storage.write(_chatHistoryKey, encoded);
    } catch (e) {
      print('Error saving chat history: $e');
      Get.snackbar('Error', 'Failed to save chat history: $e');
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
    _showScrollToBottom.value = scrollController.position.pixels > 200;
  }

  String _reformatResponse(String rawResponse) {
    if (rawResponse.contains('I am only aware of agricultural') ||
        rawResponse.contains('እኔ የማውቀው ስለ እርሻ')) {
      return rawResponse;
    }

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
  }

  Future<void> sendMessage(String query, {bool isRetry = false}) async {
    if (query.trim().isEmpty) {
      Get.snackbar('Error', 'Query cannot be empty');
      return;
    }

    final userMessage = {
      'sender': 'user',
      'text': query,
      'isRich': false,
      'timestamp': DateTime.now(),
      'isError': false,
      'query': query,
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

    http.Client? client;
    try {
      client = http.Client();
      final payload = {
        'query': query,
        'language': Get.locale?.languageCode ?? 'en',
      };
      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final rawResponse = data['response'];
        final formattedResponse = _reformatResponse(rawResponse);
        final botMessage = {
          'sender': 'bot',
          'text': formattedResponse,
          'isRich': !rawResponse.contains('I am only aware of agricultural') &&
              !rawResponse.contains('እኔ የማውቀው ስለ እርሻ'),
          'timestamp': DateTime.now(),
          'isError': false,
          'query': query,
        };
        messages.add(botMessage);
      } else {
        final errorDetail = response.statusCode == 400 || response.statusCode == 500
            ? jsonDecode(utf8.decode(response.bodyBytes))['detail']
            : 'Server error: ${response.statusCode}';
        final errorMessage = {
          'sender': 'bot',
          'text': errorDetail,
          'isRich': false,
          'isError': true,
          'query': query,
          'timestamp': DateTime.now(),
        };
        messages.add(errorMessage);
        Get.snackbar('Error', errorDetail);
      }
    } on TimeoutException catch (e) {
      final errorMessage = {
        'sender': 'bot',
        'text': 'Connection Timeout: Please check your internet connection.',
        'isRich': false,
        'isError': true,
        'query': query,
        'timestamp': DateTime.now(),
      };
      messages.add(errorMessage);
      Get.snackbar('Timeout', e.message ?? 'Request timed out');
    } catch (e) {
      final errorMessage = {
        'sender': 'bot',
        'text': 'Error: $e',
        'isRich': false,
        'isError': true,
        'query': query,
        'timestamp': DateTime.now(),
      };
      messages.add(errorMessage);
      Get.snackbar('Error', 'An error occurred: $e');
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
    Get.snackbar(
      'Copied',
      validIndices.length == 1 ? 'Message copied' : 'Messages copied',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
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
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${validIndices.length} message${validIndices.length > 1 ? 's' : ''}?\nThis action cannot be undone.',
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Dismiss dialog
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Get.theme.colorScheme.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              validIndices.sort((a, b) => b.compareTo(a));
              for (var index in validIndices) {
                messages.removeAt(index);
              }
              _saveChatHistory();
              clearSelection();
              Get.snackbar(
                'Deleted',
                validIndices.length == 1 ? 'Message deleted' : 'Messages deleted',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text(
              'Delete',
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