import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:test_pure/core/providers/chat_list_provider.dart';
import 'package:test_pure/core/services/auth_service.dart';
import 'package:test_pure/core/services/chat_service.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProxyProvider<AuthService, ChatListProvider>(
          create: (context) => ChatListProvider(
            Provider.of<ChatService>(context, listen: false),
            '',
          ),
          update: (context, authService, previous) => ChatListProvider(
            Provider.of<ChatService>(context, listen: false),
            authService.currentUser?.uid ?? '',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
