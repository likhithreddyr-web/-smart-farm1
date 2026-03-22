import 'package:flutter/material.dart';
import 'package:smart_farm/services/chat_service.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialMessage();
  }

  Future<void> _loadInitialMessage() async {
    String username = '';
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final name = doc.data()!['name'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            username = name.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading username: $e');
    }

    if (mounted) {
      setState(() {
        String greeting = TranslationService.translate('hi_farmer') ?? 'Hello! I am your Agri assistant. How can I help you today?';
        
        if (username.isNotEmpty) {
          if (greeting.toLowerCase().contains('farmer')) {
            greeting = greeting.replaceAll(RegExp('farmer', caseSensitive: false), username);
          } else {
            greeting = 'Hi $username! I am your Agri assistant. How can I help you today?';
          }
        }

        _messages.add(ChatMessage(
          text: greeting,
          isUser: false,
        ));
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _chatService.sendMessage(text);
    final cleanedResponse = _cleanText(response);
    
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: cleanedResponse, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _cleanText(String text) {
    // Remove common markdown symbols
    return text
        .replaceAll(RegExp(r'\*\*'), '') // Remove bold
        .replaceAll(RegExp(r'###'), '') // Remove headers
        .replaceAll(RegExp(r'##'), '')  // Remove headers
        .replaceAll(RegExp(r'#'), '')   // Remove headers
        .replaceAll(RegExp(r'_'), '')   // Remove italics/underscore
        .replaceAll(RegExp(r'~'), '')   // Remove strikethrough
        .replaceAll(RegExp(r'\*'), '')  // Remove single asterisk
        .trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('ai_assistant') ?? 'Krushi Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: message.isUser 
                ? Theme.of(context).primaryColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser 
                  ? Colors.white 
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: TranslationService.translate('ask_question') ?? 'Ask farm-related questions...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
