import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signIn(
          email: _emailController.text, password: _passwordController.text);
      await Provider.of<UserProvider>(context, listen: false).loadUserRole();
      // Navigate to HomeScreen directly
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Accessibility: Announce error for screen readers
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: FocusTraversalGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'SheepFarm login icon',
                      child: Semantics(
                        label:
                            'SheepFarm Login Icon', // Changed from 'SheepFarm Login' to avoid duplicate semantics
                        child: Icon(Icons.pets,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('SheepFarm Login',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 32)),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 20)),
                      style: const TextStyle(fontSize: 22),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 20)),
                      obscureText: true,
                      style: const TextStyle(fontSize: 22),
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Tooltip(
                        message: 'Login',
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login, size: 32),
                          label: _loading
                              ? Semantics(
                                  label: 'Logging in',
                                  child: const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3)))
                              : const Text('Login', style: TextStyle(fontSize: 22)),
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 56)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context, '/register'),
                      child: const Text('Don\'t have an account? Register'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Enter a valid email to reset password'),
                                  ),
                                );
                                return;
                              }
                              try {
                                await Provider.of<AuthService>(context,
                                        listen: false)
                                    .sendPasswordResetEmail(email);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset email sent!'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Failed to send reset email: $e'),
                                  ),
                                );
                              }
                            },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
