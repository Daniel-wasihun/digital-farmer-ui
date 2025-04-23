import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  bool _isConnecting = false;

  void connect(
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
      socket = IO.io('http://localhost:5000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
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
        }
      });

      socket!.on('messageSent', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: Message sent: ${data['messageId']}');
          onMessageSent(data);
        }
      });

      socket!.on('userTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Typing: ${data['senderId']}');
          onTyping(data['senderId']);
        }
      });

      socket!.on('userStoppedTyping', (data) {
        if (data is Map<String, dynamic> && data['senderId'] is String) {
          print('SocketClient: Stop typing: ${data['senderId']}');
          onStopTyping(data['senderId']);
        }
      });

      socket!.on('newUser', (data) {
        if (data is Map<String, dynamic>) {
          print('SocketClient: New user: ${data['email']}');
          onNewUser(data);
        }
      });

      socket!.on('userOnline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User online: ${data['email']}');
          onUserOnline(data['email']);
        }
      });

      socket!.on('userOffline', (data) {
        if (data is Map<String, dynamic> && data['email'] is String) {
          print('SocketClient: User offline: ${data['email']}');
          onUserOffline(data['email']);
        }
      });

      socket!.onConnectError((err) {
        print('SocketClient: Connect error: $err');
        onError('Connection error: $err');
        _isConnecting = false;
        _reconnect(userId, token, onConnect, onMessage, onMessageSent,
            onTyping, onStopTyping, onError, onNewUser, onUserOnline, onUserOffline);
      });

      socket!.onError((err) {
        print('SocketClient: Error: $err');
        onError('Socket error: $err');
      });

      socket!.onDisconnect((_) {
        print('SocketClient: Disconnected for $userId');
        onError('Disconnected from server');
        _isConnecting = false;
        _reconnect(userId, token, onConnect, onMessage, onMessageSent,
            onTyping, onStopTyping, onError, onNewUser, onUserOnline, onUserOffline);
      });

      socket!.connect();
      print('SocketClient: Connecting for $userId');
    } catch (e) {
      print('SocketClient: Connect exception: $e');
      onError('Failed to connect: $e');
      _isConnecting = false;
      _reconnect(userId, token, onConnect, onMessage, onMessageSent,
          onTyping, onStopTyping, onError, onNewUser, onUserOnline, onUserOffline);
    }
  }

  void _reconnect(
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
    if (_isConnecting) return;
    print('SocketClient: Reconnecting in 5 seconds for $userId');
    await Future.delayed(Duration(seconds: 5));
    connect(userId, token, onConnect, onMessage, onMessageSent, onTyping,
        onStopTyping, onError, onNewUser, onUserOnline, onUserOffline);
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

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket = null;
      print('SocketClient: Disconnected');
    }
  }
}