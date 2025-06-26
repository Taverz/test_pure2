import 'package:flutter/foundation.dart';
import 'package:test_pure/core/models/message.dart';
import 'package:test_pure/core/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final String _chatId;

  List<Message> _messages = [];
  bool _isLoading = false;

  ChatProvider(this._chatService, this._chatId);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    _messages = await _chatService.getChatMessages(_chatId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: _chatId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      timestamp: DateTime.now(),
    );

    await _chatService.sendMessage(message);
    _messages.insert(0, message);
    notifyListeners();
  }
}

