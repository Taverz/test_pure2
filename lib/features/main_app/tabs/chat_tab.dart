import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_pure/core/providers/chat_list_provider.dart';
import 'package:test_pure/core/providers/chat_provider.dart';
import 'package:test_pure/core/services/auth_service.dart';
import 'package:test_pure/core/services/chat_service.dart';
import 'package:test_pure/features/main_app/chat/widgets/message_input.dart';
import 'package:test_pure/features/main_app/chat/widgets/message_list.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Требуется авторизация'));
    }

    return ChangeNotifierProvider(
      create: (_) => ChatListProvider(ChatService(), user.uid)..loadChats(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Чаты')),
        body: Consumer<ChatListProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.chats.isEmpty) {
              return const Center(child: Text('Нет активных чатов'));
            }

            return ListView.builder(
              itemCount: provider.chats.length,
              itemBuilder: (context, index) {
                final chat = provider.chats[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(chat.title),
                  subtitle: Text(chat.lastMessage ?? ''),
                  trailing: Text(chat.lastMessageTime?.toIso8601String() ?? ''),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chat.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _createNewChat(context, user.uid),
        ),
      ),
    );
  }

  void _createNewChat(BuildContext context, String userId) async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final chatListProvider = Provider.of<ChatListProvider>(
      context,
      listen: false,
    );

    final titleController = TextEditingController();
    final emailController = TextEditingController();

    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать новый чат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название чата',
                hintText: 'Введите название',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email участника',
                hintText: 'Введите email собеседника',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Создать'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await chatService.createChat(
          currentUserId: userId,
          participantEmail: emailController.text.trim(),
          chatTitle: titleController.text.trim(),
        ).timeout(Duration(seconds: 2));

        chatListProvider.loadChats();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Чат успешно создан')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
        }
      }
    }
  }
}

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(ChatService(), chatId)..loadMessages(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Чат')),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  return MessageList(messages: provider.messages);
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                return MessageInput(
                  onSend: (text) => provider.sendMessage(
                    text: text,
                    senderId: user!.uid,
                    senderName: user.displayName ?? 'Аноним',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
