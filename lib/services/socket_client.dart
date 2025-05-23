import 'package:digital_farmers/services/api/base_api.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  bool _isConnecting = false;
  static const String _deviceBaseUrl = BaseApi.imageBaseUrl;
  static const String _emulatorBaseUrl = BaseApi.imageBaseUrl;
  String get _baseUrl => defaultTargetPlatform == TargetPlatform.android && !kIsWeb ? _emulatorBaseUrl : _deviceBaseUrl;

  Future<void> connect(
    String userId,
    String token,
    Function onConnect,
    Function(Map<String, dynamic>) onMessage,
    Function(Map<String, dynamic>) onMessageSent,
    Function(String) onTyping,
    Function(String) onStopTyping,
    Function(String) onError,
    Function(Map<String, dynamic>) onNewUser,
    Function(String) onUserOnline,
    Function(String) onUserOffline, {
    required Function(String) onMessageDelivered,
    required Function(String) onMessageRead,
  }) async {
    if (_isConnecting || socket?.connected == true) {
      print('SocketClient: Already connecting or connected for $userId');
      return;
    }
    if (userId.isEmpty || token.isEmpty) {
      print('SocketClient: Invalid userId or token: userId=$userId, token=${token.isEmpty ? '[empty]' : '[provided]'}');
      onError('Invalid user ID or token');
      return;
    }
    _isConnecting = true;
    try {
      print('SocketClient: Connecting to $_baseUrl with userId: $userId');
      socket = IO.io(_baseUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
        'auth': {'token': token},
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 2000,
        'reconnectionDelayMax': 10000,
      });

      socket!.onConnect((_) {
        print('SocketClient: Connected for $userId');
        socket!.emit('register', userId);
        onConnect();
        _isConnecting = false;
        // Get.snackbar('Success', 'Connected to chat'.tr,
        //     snackPosition: SnackPosition.TOP,
        //     backgroundColor: Get.theme.colorScheme.secondary,
        //     colorText: Get.theme.colorScheme.onSecondary);
      });

      socket!.on('registered', (data) {
        print('SocketClient: Registered: $data');
        if (data is Map<String, dynamic> && data['userId'] != userId) {
          print('SocketClient: User ID mismatch in registration: expected $userId, got ${data['userId']}');
          onError('User ID mismatch');
        }
      });

      socket!.on('receiveMessage', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: Received message: ${data['messageId']}');
          onMessage(data);
        } else {
          print('SocketClient: Invalid message data: $data');
          onError('Invalid message received');
        }
      });

      socket!.on('messageSent', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: Message sent: ${data['messageId']}');
          onMessageSent(data);
        } else {
          print('SocketClient: Invalid messageSent data: $data');
          onError('Invalid message sent data');
        }
      });

      socket!.on('messageDelivered', (data) {
        if (data is Map<String, dynamic> && data['messageId'] is String) {
          print('SocketClient: Message delivered: ${data['messageId']}');
          onMessageDelivered(data['messageId']);
        } else {
          print('SocketClient: Invalid messageDelivered data: $data');
          onError('Invalid message delivered data');
        }
      });

      socket!.on('messageRead', (data) {
        if (data is Map<String, dynamic> && data['messageId'] is String) {
          print('SocketClient: Message read: ${data['messageId']}');
          onMessageRead(data['messageId']);
        } else {
          print('SocketClient: Invalid messageRead data: $data');
          onError('Invalid message read data');
        }
      });

      socket!.on('userTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Typing: ${data['senderId']}');
          onTyping(data['senderId']);
        } else {
          print('SocketClient: Invalid typing data: $data');
          onError('Invalid typing data');
        }
      });

      socket!.on('userStoppedTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Stop typing: ${data['senderId']}');
          onStopTyping(data['senderId']);
        } else {
          print('SocketClient: Invalid stopTyping data: $data');
          onError('Invalid stop typing data');
        }
      });

      socket!.on('newUser', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: New user: ${data['email']}');
          onNewUser(data);
        } else {
          print('SocketClient: Invalid newUser data: $data');
          onError('Invalid new user data');
        }
      });

      socket!.on('userOnline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User online: ${data['email']}');
          onUserOnline(data['email']);
        } else {
          print('SocketClient: Invalid userOnline data: $data');
          onError('Invalid user online data');
        }
      });

      socket!.on('userOffline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User offline: ${data['email']}');
          onUserOffline(data['email']);
        } else {
          print('SocketClient: Invalid userOffline data: $data');
          onError('Invalid user offline data');
        }
      });

      socket!.onConnectError((err) {
        print('SocketClient: Connect error: $err');
        onError('Failed to connect to server');
        _isConnecting = false;
      });

      socket!.onError((err) {
        print('SocketClient: Error: $err');
        onError(err is Map && err['message'] is String ? err['message'] : 'Socket error occurred');
        _isConnecting = false;
      });

      socket!.onDisconnect((reason) {
        print('SocketClient: Disconnected for $userId, reason: $reason');
        onError('Disconnected from server');
        _isConnecting = false;
      });

      socket!.on('forceDisconnect', (data) {
        print('SocketClient: Force disconnected for $userId: $data');
        _disconnect();
        onError('Session replaced by new login');
      });

      socket!.connect();
      print('SocketClient: Initiating connection for $userId');
    } catch (e) {
      print('SocketClient: Connect exception: $e');
      onError('Failed to connect: $e');
      _isConnecting = false;
    }
  }

  void sendMessage(String senderId, String receiverId, String message, String messageId) {
    if (socket == null || !socket!.connected) {
      print('SocketClient: Cannot send message, socket not connected');
      // Get.snackbar('Error', 'Not connected to server'.tr,
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Get.theme.colorScheme.error,
      //     colorText: Get.theme.colorScheme.onError);
      return;
    }
    if (senderId.isEmpty || receiverId.isEmpty || message.isEmpty || messageId.isEmpty) {
      print('SocketClient: Invalid message data: senderId=$senderId, receiverId=$receiverId, message=$message, messageId=$messageId');
      return;
    }
    socket!.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageId': messageId,
    });
    print('SocketClient: Sent message: $messageId to $receiverId');
  }

  void sendTyping(String senderId, String receiverId) {
    if (socket == null || !socket!.connected) {
      print('SocketClient: Cannot send typing, socket not connected');
      return;
    }
    if (senderId.isEmpty || receiverId.isEmpty) {
      print('SocketClient: Invalid typing data: senderId=$senderId, receiverId=$receiverId');
      return;
    }
    socket!.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
    print('SocketClient: Sent typing: $senderId to $receiverId');
  }

  void sendStopTyping(String senderId, String receiverId) {
    if (socket == null || !socket!.connected) {
      print('SocketClient: Cannot send stop typing, socket not connected');
      return;
    }
    if (senderId.isEmpty || receiverId.isEmpty) {
      print('SocketClient: Invalid stop typing data: senderId=$senderId, receiverId=$receiverId');
      return;
    }
    socket!.emit('stopTyping', {'senderId': senderId, 'receiverId': receiverId});
    print('SocketClient: Sent stop typing: $senderId to $receiverId');
  }

  void markAsRead(String messageId) {
    if (socket == null || !socket!.connected) {
      print('SocketClient: Cannot mark as read, socket not connected');
      return;
    }
    if (messageId.isEmpty) {
      print('SocketClient: Invalid messageId for mark as read: $messageId');
      return;
    }
    socket!.emit('markAsRead', {'messageId': messageId});
    print('SocketClient: Marked as read: $messageId');
  }

  Future<void> _disconnect() async {
    if (socket != null) {
      socket!.off('connect');
      socket!.off('registered');
      socket!.off('receiveMessage');
      socket!.off('messageSent');
      socket!.off('messageDelivered');
      socket!.off('messageRead');
      socket!.off('userTyping');
      socket!.off('userStoppedTyping');
      socket!.off('newUser');
      socket!.off('userOnline');
      socket!.off('userOffline');
      socket!.off('connect_error');
      socket!.off('error');
      socket!.off('disconnect');
      socket!.off('forceDisconnect');
      socket!.disconnect();
      socket = null;
      print('SocketClient: Disconnected');
    }
  }

  Future<void> disconnect() async {
    await _disconnect();
  }
}