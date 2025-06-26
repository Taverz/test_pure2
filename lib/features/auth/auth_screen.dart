import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_pure/features/main_app/main_app.dart';
import '../../core/services/auth_service.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Dating App'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await authService.signInWithGoogle();
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Вход отменен или произошла ошибка'),
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainApp()),
                  );
                }
              },
              child: const Text('Войти через Google'),
            ),
          ],
        ),
      ),
    );
  }
}
