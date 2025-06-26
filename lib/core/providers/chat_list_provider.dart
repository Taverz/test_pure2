
import 'package:flutter/material.dart';
import 'package:test_pure/core/models/chat.dart';
import 'package:test_pure/core/services/chat_service.dart';

class ChatListProvider with ChangeNotifier {
  final ChatService _chatService;
  final String _userId;

  List<Chat> _chats = [];
  bool _isLoading = false;

  ChatListProvider(this._chatService, this._userId);

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    _chats = await _chatService.getUserChats(_userId);

    _isLoading = false;
    notifyListeners();
  }
}
