import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ChatPage extends StatefulWidget {
  final String userId;
  
  const ChatPage({super.key, required this.userId});
  
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageBubble> _messages = [];
  final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // API endpoint - replace with your actual backend URL
  static const String apiUrl = 'http://localhost:3000/api/v1/chat/chat/mock';

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    _messages.add(MessageBubble(
      sender: 'BeeBuddy',
      text: 'Hello! I\'m your beekeeping assistant. Ask me anything about beekeeping, honey production, or bee health!',
      isMe: false,
      timestamp: getFormattedTime(),
    ));
    
    // Scroll to bottom after welcome message is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _messages.add(MessageBubble(
        sender: 'You',
        text: _controller.text,
        isMe: true,
        timestamp: getFormattedTime(),
      ));
      _isLoading = true;
    });
    
    String message = _controller.text;
    _controller.clear();
    _focusNode.unfocus(); // Hide keyboard
    
    // Scroll to bottom to show new message
    _scrollToBottom();
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'userId': widget.userId,
          'sessionId': sessionId,
          'useHistory': true
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(MessageBubble(
            sender: 'BeeBuddy',
            text: data['response'],
            isMe: false,
            timestamp: getFormattedTime(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get response from server');
      }
    } on TimeoutException {
      setState(() {
        _messages.add(MessageBubble(
          sender: 'BeeBuddy',
          text: 'Sorry, I\'m taking too long to respond. Please check your connection and try again.',
          isMe: false,
          timestamp: getFormattedTime(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(MessageBubble(
          sender: 'BeeBuddy',
          text: 'Sorry, I encountered an error. Please try again in a moment.',
          isMe: false,
          timestamp: getFormattedTime(),
        ));
        _isLoading = false;
      });
    }
    
    _scrollToBottom();
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

  String getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beekeeping Assistant',
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About BeeBuddy'),
                  content: const Text(
                    'I\'m an AI assistant specialized in beekeeping knowledge. '
                    'I can answer questions about bee species, hive management, '
                    'honey production, and bee health issues.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return MessageBubble(
                      sender: 'BeeBuddy',
                      text: 'Thinking...',
                      isMe: false,
                      timestamp: getFormattedTime(),
                      isTyping: true,
                    );
                  }
                  return _messages[index];
                },
              ),
            ),
            MessageInputField(
              controller: _controller,
              focusNode: _focusNode,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final String timestamp;
  final bool isTyping;

  const MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isTyping = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.amber[500] : Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isTyping)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15.0,
                      ),
                    ),
                  const SizedBox(height: 5.0),
                  Text(
                    timestamp,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black54,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const MessageInputField({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Ask about beekeeping...',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => onSend(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.amber[700]),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}