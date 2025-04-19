import 'package:http/http.dart' as http;
import 'base_api.dart';

class MessageApi extends BaseApi {
  Future<List<Map<String, dynamic>>> getMessages(String userId1, String userId2) async {
    print('Fetching messages between $userId1 and $userId2');
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('${BaseApi.apiBaseUrl}/messages?userId1=$userId1&userId2=$userId2'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    final data = await handleResponse(response, 'Get messages');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Get messages: Expected List, got ${data.runtimeType}');
      return [];
    }
  }
}