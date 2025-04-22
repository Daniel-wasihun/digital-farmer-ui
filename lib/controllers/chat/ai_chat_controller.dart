import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AIChatController extends GetxController {
  // Text and Scroll Controllers
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Observable list of messages, each a map with sender, text, isRich, and timestamp
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  // Observable boolean for loading state
  final RxBool isLoading = false.obs;

  // Observable double for text scale factor, allowing user-controlled text sizing
  final RxDouble textScaleFactor = 1.0.obs;

  // GetStorage instance for local storage
  final GetStorage _storage = GetStorage();
  static const String _chatHistoryKey = 'ai_chat_history'; // Key for chat history in storage

  // API URL:  Make sure to replace with your actual server address.
  static const String _apiUrl =
      'http://localhost:8000/ask'; //  e.g., 'http://192.168.1.100:8000/ask'   OR http://10.0.2.2:8000/ask for android emulator

  // Add this!  RxBool to hold the state, and a getter to expose it.
  final RxBool _showScrollToBottom = false.obs;
  bool get showScrollToBottom => _showScrollToBottom.value;

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory(); // Load chat history when the controller is initialized
    scrollController.addListener(scrollListener); //listen
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    textController.dispose();
    scrollController.dispose();
    _saveChatHistory(); // Save chat history when the controller is closed
    super.onClose();
  }

  // Load chat history from local storage
  Future<void> _loadChatHistory() async {
    try {
      await GetStorage.init(); // Ensure GetStorage is initialized.
      final storedHistory = _storage.read<String>(_chatHistoryKey);
      if (storedHistory != null) {
        final List<dynamic> decoded = jsonDecode(storedHistory);
        // Ensure the loaded data is of the correct type and convert timestamp back to DateTime
        messages.value = decoded.map((item) {
          return {
            'sender': item['sender'],
            'text': item['text'],
            'isRich': item['isRich'],
            'timestamp': DateTime.parse(item['timestamp']), // Convert back to DateTime
            if (item.containsKey('isError')) 'isError': item['isError'],
            if (item.containsKey('query')) 'query': item['query'],
          };
        }).toList().cast<Map<String, dynamic>>();

        // Scroll to the bottom after loading the history
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: false);
        });
      }
    } catch (e) {
      // Handle errors during JSON decoding or storage read
      print('Error loading chat history: $e');
      // Optionally, show a user-friendly message
      Get.snackbar(
        'Error',
        'Failed to load chat history.  Starting a new chat. Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      messages.value = []; // Clear messages to start fresh.
    }
  }

  // Save chat history to local storage
  Future<void> _saveChatHistory() async {
    try {
      await GetStorage.init();
      // Encode the message list as a JSON string, converting DateTime to ISO string
      final encoded = jsonEncode(messages.map((message) {
        return {
          'sender': message['sender'],
          'text': message['text'],
          'isRich': message['isRich'],
          'timestamp': message['timestamp'].toIso8601String(), // Convert to ISO string
          if (message.containsKey('isError')) 'isError': message['isError'],
          if (message.containsKey('query')) 'query': message['query'],
        };
      }).toList());
      await _storage.write(_chatHistoryKey, encoded);
    } catch (e) {
      // Handle errors during storage write
      print('Error saving chat history: $e');
      Get.snackbar(
        'Error',
        'Failed to save chat history: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // Helper method to scroll to the bottom of the chat
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

  // Reformat the raw response from the AI for better presentation
  String _reformatResponse(String rawResponse) {
    final lines = rawResponse.split('\n');
    final formattedLines = <String>[];
    bool inBulletSection = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('* **') && line.endsWith('**')) {
        // Bold titles
        formattedLines.add(
            '**${line.replaceFirst('* **', '').replaceAll('**', '')}**');
        inBulletSection = false;
      } else if (line.startsWith('* ')) {
        // Bullet points
        formattedLines.add('• ${line.replaceFirst('* ', '')}');
        inBulletSection = true;
      } else if (inBulletSection && !line.startsWith('* ')) {
        // Continuation of bullet point
        formattedLines.add(line);
        inBulletSection = false;
      } else {
        // Regular text
        formattedLines.add(line);
      }
    }
    return formattedLines.join('\n');
  }

  // Send a message to the AI and handle the response
  Future<void> sendMessage(String query, {bool isRetry = false}) async {
    if (query.trim().isEmpty) return; // Don't send empty messages

    final userMessage = {
      'sender': 'user',
      'text': query,
      'isRich': false,
      'timestamp': DateTime.now(),
    };

    if (!isRetry) {
      messages.add(userMessage); // Add user message to the list
      _saveChatHistory(); // Save the user message
      isLoading.value = true; // Show loading indicator
      textController.clear(); // Clear the input field
    }

    // Scroll to bottom after sending user message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(animated: true);
    });

    http.Client? client;
    try {
      client = http.Client();
      final response = await client.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'query': query}),
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        // Increased timeout to 30 seconds
        throw TimeoutException(
            'Request timed out after 30 seconds.  Please check your connection and the server.');
      });

      if (response.statusCode == 200) {
        // Successful response
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final formattedResponse = _reformatResponse(data['response']);
        final botMessage = {
          'sender': 'bot',
          'text': formattedResponse,
          'isRich': true,
          'timestamp': DateTime.now(),
        };
        messages.add(botMessage);
      } else {
        // Handle server errors
        final errorMessage = {
          'sender': 'bot',
          'text':
          'Server Error: Please try again later.',
          'isRich': false,
          'isError': true,
          'query': query, // Include the query for retry
          'timestamp': DateTime.now(),
        };
        messages.add(errorMessage);
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } on TimeoutException catch (e) {
      // Handle timeout exceptions
      final timeoutMessage = {
        'sender': 'bot',
        'text':
        'Connection Timeout: Please check your internet connection and try again.',
        'isRich': false,
        'isError': true,
        'query': query, // Include the query for retry
        'timestamp': DateTime.now(),
      };
      messages.add(timeoutMessage);
      Get.snackbar(
        'Timeout',
        e.message ?? 'Timeout Error',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      // Handle other exceptions (e.g., network errors, JSON errors)
      final errorMessage = {
        'sender': 'bot',
        'text': 'Error: Please check your connection and the server.',
        'isRich': false,
        'isError': true,
        'query': query, // Include the query for retry
        'timestamp': DateTime.now(),
      };
      messages.add(errorMessage);
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        );
    } finally {
      isLoading.value =
          false; // Ensure loading indicator is hidden, even on errors
      client?.close();
      _saveChatHistory(); // Save the updated message list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: true);
      });
    }
  }
  

  // Retry sending a message
  void retryMessage(String query) {
    sendMessage(query, isRetry: true);
  }

  void scrollListener() {
    _showScrollToBottom.value =
        scrollController.position.pixels > 200; // Example threshold
  }
}
