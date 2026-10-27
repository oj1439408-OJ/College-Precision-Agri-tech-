enum SenderType { user, assistant }

class ChatMessage {
  final String id;
  final String text;
  final SenderType sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}
