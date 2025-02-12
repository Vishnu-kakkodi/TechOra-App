// import 'package:socket_io_client/socket_io_client.dart' as io;

// class SocketService {
//   io.Socket? socket;

//   void connectSocket(String token) {
//     print('$token,Hello Tokn');
//     socket = io.io('https://api.techora.online', <String, dynamic>{
//       'auth': {'token': token},
//       'autoConnect': false,
//     });

//     socket!.connect();

//     socket!.onConnect((_) {
//       print('Connected to Socket.IO server');
//     });

//     socket!.onDisconnect((_) {
//       print('Disconnected from Socket.IO server');
//     });

//     socket!.onError((data) {
//       print('Socket Error: $data');
//     });
//   }

// void sendMessage(String senderId, String receiverId, String text) {
//   if (socket != null && socket!.connected) {
//     socket!.emit('send_message', {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'text': text,
//       'sender': 'user', // Adjust based on user type
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//   } else {
//     print("Socket not connected");
//   }
// }


//   void listenToMessages(Function(dynamic) onMessageReceived) {
//     socket!.on('receive_message', (message) {
//       onMessageReceived(message);
//     });
//   }

//   void markMessagesAsRead(String receiverId) {
//     socket!.emit('mark_messages_read', receiverId);
//   }

//   void disconnectSocket() {
//     socket?.disconnect();
//   }
// }





import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? socket;
  bool isConnected = false;

  void connectSocket(String token) {
    socket = io.io(
      'http://10.0.2.2:5000', // Replace with your server URL if needed
      io.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .setAuth({'token': token})
        .enableAutoConnect()
        .build()
    );

    // Listen for socket connection events
    socket!.onConnect((_) {
      print('Connected to Socket.IO server');
      isConnected = true;
    });

    socket!.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
      isConnected = false;
    });

    socket!.onError((error) {
      print('Socket Error: $error');
    });

    socket!.onConnectError((error) {
      print('Connection Error: $error');
    });

    socket!.connect(); // Ensure the socket is actually connecting
  }


  void sendMessage(String senderId, String receiverId, String text) {
    if (socket != null && socket!.connected) {
      final messageData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'sender': 'user',
        'timestamp': DateTime.now().toIso8601String(),
      };

      socket!.emit('send_message', messageData);
    } else {
      print('Socket not connected');
    }
  }
void fetchChatHistory(
  String senderId,
  String receiverId,
  Function(Map<String, dynamic>) onHistoryReceived,
) {
  print('Fetching chat historyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy...');
  
  if (socket != null && socket!.connected) {
    socket!.emitWithAck(
      'fetch_chat_history_mobile',
      {'senderId': senderId, 'receiverId': receiverId}, 
      ack: (response) {
        if (response != null) {
          onHistoryReceived(response as Map<String, dynamic>);
        } else {
          print("No response from server");
        }
      }
    );
  } else {
    print("Socket not connected");
  }
}


  void listenToMessages(Function(dynamic) onMessageReceived) {
    socket!.on('receive_message', (message) {
      onMessageReceived(message);
    });
  }

  void listenToReadStatus(Function(dynamic) onReadStatusUpdate) {
    socket!.on('messages_read', (data) {
      onReadStatusUpdate(data);
    });
  }

  void markMessagesAsRead(String receiverId) {
    if (socket != null && socket!.connected) {
      socket!.emit('mark_messages_read', receiverId);
    }
  }

  void joinChat(String receiverId) {
    if (socket != null && socket!.connected) {
      socket!.emit('join_chat', receiverId);
    }
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    isConnected = false;
  }
}
