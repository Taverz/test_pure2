import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_pure/features/splash/splash_screen.dart';
import '../../../core/services/auth_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  final String _urlImage =
      "https://platform.vox.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/15443821/RAM_S2_Ep205.0.0.1505932128.jpg?quality=90&strip=all&crop=21.875,0,56.25,100";

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Профиль', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          StreamBuilder<User?>(
            stream: user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        snapshot.data!.photoURL ?? _urlImage,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(snapshot.data!.displayName ?? 'Без имени'),
                    Text(snapshot.data!.email ?? 'Нет email'),
                  ],
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await authService.signOut().timeout(const Duration(seconds: 2));
              } finally {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              }
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
