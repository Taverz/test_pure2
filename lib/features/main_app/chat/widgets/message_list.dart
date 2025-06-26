import 'package:flutter/material.dart';
import 'package:test_pure/core/models/message.dart';
import 'package:test_pure/features/main_app/chat/widgets/message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}