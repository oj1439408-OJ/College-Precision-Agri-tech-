import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/assistant_api_service.dart';
import '../services/mock_data_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AssistantApiService _assistantApiService;
  bool _isTyping = false;
  String? _failedQuestion;
  String? _retryMessageId;

  final List<String> _quickPrompts = [
    'Which crop should I grow?',
    'Why is my soil health low?',
    'When should I irrigate?',
    'What does low nitrogen mean?',
  ];

  @override
  void initState() {
    super.initState();
    _assistantApiService = AssistantApiService();
    _messages.addAll(MockDataService.getInitialChatMessages());
  }

  void _sendMessage(String text) async {
    final question = text.trim();
    if (question.isEmpty || _isTyping) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: question,
      sender: SenderType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _failedQuestion = null;
      _retryMessageId = null;
    });
    _textController.clear();
    _scrollToBottom();
    await _requestReply(question);
  }

  Future<void> _requestReply(String question) async {
    if (mounted) setState(() => _isTyping = true);
    try {
      final replyText = await _assistantApiService.sendMessage(question);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _failedQuestion = null;
        _retryMessageId = null;
        _messages.add(
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: replyText,
            sender: SenderType.assistant,
            timestamp: DateTime.now(),
          ),
        );
      });
    } on AssistantApiException catch (error) {
      _addRetryableError(question, error.message);
    } catch (_) {
      _addRetryableError(
        question,
        'The assistant could not be reached. Check the backend and retry.',
      );
    }
    _scrollToBottom();
  }

  void _addRetryableError(String question, String message) {
    if (!mounted) return;
    final errorId = DateTime.now().microsecondsSinceEpoch.toString();
    setState(() {
      _isTyping = false;
      _failedQuestion = question;
      _retryMessageId = errorId;
      _messages.add(
        ChatMessage(
          id: errorId,
          text: message,
          sender: SenderType.assistant,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _retryLastMessage() async {
    final question = _failedQuestion;
    if (question == null || _isTyping) return;
    setState(() => _retryMessageId = null);
    await _requestReply(question);
  }

  @override
  void dispose() {
    _assistantApiService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildRetryButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _isTyping ? null : _retryLastMessage,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Retry'),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.smart_toy_outlined, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('AI Farmer Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gemini AI via local Flask backend',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == SenderType.user;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF2E7D32) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isUser ? null : Border.all(color: const Color(0xFFE5EBE5)),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : const Color(0xFF1C2D21),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isUser ? Colors.white70 : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        if (message.id == _retryMessageId) _buildRetryButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                  ),
                  SizedBox(width: 8),
                  Text('AI Assistant is typing...', style: TextStyle(fontSize: 12, color: Color(0xFF6B7C6E))),
                ],
              ),
            ),

          // Quick Prompt Chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFB7E4BF)),
                    onPressed: _isTyping ? null : () => _sendMessage(prompt),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isTyping,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about crops, soil, nutrients...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF4F7F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _isTyping ? null : () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
