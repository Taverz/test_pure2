import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:test_pure/core/models/chat.dart';
import 'package:test_pure/core/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Chat> createChat({
    required String currentUserId,
    required String participantEmail,
    required String chatTitle,
  }) async {
    try {
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: participantEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('Пользователь с таким email не найден в базе');
      }

      final participantId = userSnapshot.docs.first.id;

      final newChatRef = _firestore.collection('chats').doc();
      final newChat = Chat(
        id: newChatRef.id,
        title: chatTitle.isNotEmpty ? chatTitle : 'Чат с $participantEmail',
        participants: [currentUserId, participantId],
        createdAt: DateTime.now(),
      );

      await newChatRef.set(newChat.toMap()).timeout(Duration(seconds: 1)).onError((_,__){});

      return newChat;
    } catch (e) {
      log('Ошибка создания чата: $e');
      rethrow;
    }
  }

  Future<List<Chat>> getUserChats(String userId) async {
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Chat.fromMap(doc.data())).toList();
  }

  Future<List<Message>> getChatMessages(String chatId) async {
    final snapshot = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  }

  Future<void> sendMessage(Message message) async {
    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _firestore.collection('chats').doc(message.chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': DateFormat('HH:mm').format(message.timestamp),
    });
  }
}
