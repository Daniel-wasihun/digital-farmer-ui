import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // API URL: Adjusted for different environments
  static const String _apiUrl = 'http://localhost:8000/ask'; // Android emulator
  // For iOS emulator: 'http://localhost:8000/ask'
  // For physical device: Replace with your host machine's IP, e.g., 'http://192.168.x.x:8000/ask'

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    messages.clear();
    super.onClose();
  }

  // Reformat the raw response into an attractive format
  String _reformatResponse(String rawResponse) {
    final lines = rawResponse.split('\n');
    final formattedLines = <String>[];

    bool inBulletSection = false;
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

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
    if (query.trim().isEmpty) return;

    if (!isRetry) {
      messages.add({'sender': 'user', 'text': query, 'isRich': false});
      isLoading.value = true;
      textController.clear();
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    http.Client? client;
    try {
      client = http.Client();
      final response = await client
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'query': query}),
            encoding: Encoding.getByName('utf-8'),
          )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Request timed out after 15 seconds');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final formattedResponse = _reformatResponse(data['response']);
        messages.add({
          'sender': 'bot',
          'text': formattedResponse,
          'isRich': true,
        });
      } else {
        messages.add({
          'sender': 'bot',
          'text': 'Server Error: Status ${response.statusCode}',
          'isRich': false,
          'isError': true,
          'query': query,
        });
      }
    } on TimeoutException {
      messages.add({
        'sender': 'bot',
        'text': 'Connection Timeout: Please check if the server is running at $_apiUrl',
        'isRich': false,
        'isError': true,
        'query': query,
      });
    } catch (e) {
      messages.add({
        'sender': 'bot',
        'text': 'Connection Error: $e. Ensure the server is running at $_apiUrl',
        'isRich': false,
        'isError': true,
        'query': query,
      });
    } finally {
      isLoading.value = false;
      client?.close();
    }

    // Scroll to bottom after response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void retryMessage(String query) {
    sendMessage(query, isRetry: true);
  }
}