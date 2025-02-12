// import 'package:flutter/material.dart';
// import '../services/socket_service.dart';

// class ChatScreen extends StatefulWidget {
//   final String courseId;
//   final String token;
//   final String senderId;
//   final String receiverId;

//   const ChatScreen({
//     super.key,
//     required this.courseId,
//     required this.token,
//     required this.senderId,
//     required this.receiverId,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final SocketService _socketService = SocketService();
//   final TextEditingController _messageController = TextEditingController();
//   List<String> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     print(widget.token);
//     print(widget.senderId);
//     print(widget.receiverId);
//     _socketService.connectSocket(widget.token);
//     _socketService.listenToMessages((message) {
//       setState(() {
//         messages.add(message['text']);
//       });
//     });
//   }

// void sendMessage() {
//   if (_messageController.text.isNotEmpty) {
//     _socketService.sendMessage(widget.senderId, widget.receiverId, _messageController.text);
//     _messageController.clear();
//   }
// }

//   @override
//   void dispose() {
//     _socketService.disconnectSocket();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat with Tutor"),
//         backgroundColor: Colors.teal[100],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) => ListTile(
//                 title: Text(messages[index]),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:project/models/course_detail_model.dart';
import '../services/socket_service.dart';

class Message {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;
  bool isRead;
  final String senderId;
  final String receiverId;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
    required this.senderId,
    required this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      text: json['text'] ?? json['content'] ?? '',
      sender: json['sender'] ?? json['currentUserType'] ?? '',
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
      isRead: json['isRead'] ?? false,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String tutorname;
  final String token;
  final String senderId;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.tutorname,
    required this.token,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

void _initializeChat() {
  _socketService.connectSocket(widget.token);

  // Use a listener for when the socket connects
  _socketService.socket?.on('connect', (_) {
    print('Socket Connected. Fetching chat history...');
    
    _socketService.fetchChatHistory(
      widget.senderId,
      widget.receiverId,
      (historyData) {
        if (historyData['success']) {
          setState(() {
            messages = (historyData['messages'] as List)
                .map((msg) => Message.fromJson(msg))
                .toList();
            isLoading = false;
          });
          _scrollToBottom();
        }
      },
    );
  });

  // Listen for new messages
  _socketService.listenToMessages((messageData) {
    setState(() {
      messages.add(Message.fromJson(messageData));
    });
    _scrollToBottom();
  });

  // Listen for read status updates
  _socketService.listenToReadStatus((data) {
    setState(() {
      for (var message in messages) {
        if (message.receiverId == data['readBy']) {
          message.isRead = true;
        }
      }
    });
  });
}



  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderId': widget.senderId,
        'receiverId': widget.receiverId,
        'text': _messageController.text,
        'sender': 'user',
        'timestamp': DateTime.now().toIso8601String(),
      };

      _socketService.sendMessage(
        widget.senderId,
        widget.receiverId,
        _messageController.text,
      );

      setState(() {
        messages.add(Message.fromJson(newMessage));
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == widget.senderId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead ? Colors.blue : Colors.grey[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutorname),
        backgroundColor: Colors.teal[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
                  ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnectSocket();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}