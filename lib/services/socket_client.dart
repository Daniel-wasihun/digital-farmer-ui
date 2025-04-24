import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  bool _isConnecting = false;
  // Configure base URL based on environment
  // Update this IP for physical devices
  static const String _deviceBaseUrl = 'http://localhost:5000'; // Replace with your machine's IP
  static const String _emulatorBaseUrl = 'http://localhost:5000';
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
    Function(String) onUserOffline,
  ) async {
    if (_isConnecting || socket?.connected == true) {
      print('SocketClient: Already connecting or connected for $userId');
      return;
    }
    _isConnecting = true;
    try {
      print('SocketClient: Connecting to $_baseUrl with token: $token');
      socket = IO.io(_baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
        'reconnectionDelayMax': 10000,
      });

      socket!.onConnect((_) {
        print('SocketClient: Connected for $userId');
        socket!.emit('register', userId);
        onConnect();
        _isConnecting = false;
      });

      socket!.on('registered', (data) {
        print('SocketClient: Registered: $data');
      });

      socket!.on('receiveMessage', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: Received message: ${data['messageId']}');
          onMessage(data);
        } else {
          print('SocketClient: Invalid message data: $data');
        }
      });

      socket!.on('messageSent', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: Message sent: ${data['messageId']}');
          onMessageSent(data);
        } else {
          print('SocketClient: Invalid messageSent data: $data');
        }
      });

      socket!.on('userTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Typing: ${data['senderId']}');
          onTyping(data['senderId']);
        } else {
          print('SocketClient: Invalid typing data: $data');
        }
      });

      socket!.on('userStoppedTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Stop typing: ${data['senderId']}');
          onStopTyping(data['senderId']);
        } else {
          print('SocketClient: Invalid stopTyping data: $data');
        }
      });

      socket!.on('newUser', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: New user: ${data['email']}');
          onNewUser(data);
        } else {
          print('SocketClient: Invalid newUser data: $data');
        }
      });

      socket!.on('userOnline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User online: ${data['email']}');
          onUserOnline(data['email']);
        } else {
          print('SocketClient: Invalid userOnline data: $data');
        }
      });

      socket!.on('userOffline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User offline: ${data['email']}');
          onUserOffline(data['email']);
        } else {
          print('SocketClient: Invalid userOffline data: $data');
        }
      });

      socket!.onConnectError((err) {
        print('SocketClient: Connect error: $err');
        onError('Connection error: $err');
        _isConnecting = false;
      });

      socket!.onError((err) {
        print('SocketClient: Error: $err');
        onError('Socket error: $err');
      });

      socket!.onDisconnect((reason) {
        print('SocketClient: Disconnected for $userId, reason: $reason');
        onError('Disconnected from server: $reason');
        _isConnecting = false;
      });

      socket!.on('forceDisconnect', (data) {
        print('SocketClient: Force disconnected for $userId: $data');
        disconnect();
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
      Get.snackbar('Error', 'socket_not_connected'.tr, snackPosition: SnackPosition.BOTTOM);
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
    socket!.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
    print('SocketClient: Sent typing: $senderId to $receiverId');
  }

  void sendStopTyping(String senderId, String receiverId) {
    if (socket == null || !socket!.connected) {
      print('SocketClient: Cannot send stop typing, socket not connected');
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
    socket!.emit('markAsRead', {'messageId': messageId});
    print('SocketClient: Marked as read: $messageId');
  }

  Future<void> disconnect() async {
    if (socket != null) {
      socket!.off('connect');
      socket!.off('registered');
      socket!.off('receiveMessage');
      socket!.off('messageSent');
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
}