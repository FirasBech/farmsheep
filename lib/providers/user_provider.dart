import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  UserProvider({required AuthService authService}) : _authService = authService;

  String? _role;
  bool _initialized = false;

  String? get role => _role;
  bool get isInitialized => _initialized;
  String? get displayName =>
      _authService.currentUser?.displayName ??
      _authService.currentUser?.email?.split('@').first;

  Future<void> loadUserRole() async {
    _role = await _authService.getUserRole();
    _initialized = true;
    notifyListeners();
  }
}
