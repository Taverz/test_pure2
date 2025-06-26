import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class Message {
  final String id;
  final String chatId;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.chatId,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      text: map['text'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? text,
    String? senderId,
    String? senderName,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chatId': chatId,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
