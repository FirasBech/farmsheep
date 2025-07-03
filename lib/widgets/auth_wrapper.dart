import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return const LoginScreen();
    } else {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      if (!userProv.isInitialized) userProv.loadUserRole();
      return const HomeScreen();
    }
  }
}
