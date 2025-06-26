import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../main_app/main_app.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    Future.delayed(const Duration(seconds: 2), () async {
      final currentUser = await authService.user.first;
      await Future.delayed(const Duration(milliseconds: 300));
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              currentUser == null ? const AuthScreen() : const MainApp(),
        ),
      );
    });

    return Scaffold(body: Center(child: Icon(Icons.abc)));
  }
}
