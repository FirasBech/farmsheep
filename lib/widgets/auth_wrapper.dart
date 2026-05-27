import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import '../core/utils/l10n_extension.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = p.Provider.of<User?>(context);
    if (user == null) {
      return const LoginScreen();
    }
    if (!user.emailVerified) {
      return const _VerifyEmailScreen();
    }

    // Load role into Riverpod AuthNotifier
    final authState = ref.read(authNotifierProvider);
    if (!authState.roleLoaded) {
      ref.read(authNotifierProvider.notifier).loadRole();
    }

    return const HomeScreen();
  }
}

class _VerifyEmailScreen extends StatefulWidget {
  const _VerifyEmailScreen();

  @override
  State<_VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<_VerifyEmailScreen> {
  bool _sending = false;
  String? _message;

  Future<void> _resend() async {
    setState(() {
      _sending = true;
      _message = null;
    });
    try {
      final auth = p.Provider.of<AuthService>(context, listen: false);
      await auth.sendEmailVerification();
      if (mounted) setState(() => _message = context.l10n.verificationEmailSent);
    } catch (e) {
      if (mounted) setState(() => _message = context.l10n.failedToSend(e.toString()));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _logout() async {
    final auth = p.Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              Text(context.l10n.verifyYourEmailTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                context.l10n.verifyEmailBody,
                textAlign: TextAlign.center,
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _resend,
                  child: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(context.l10n.resendVerificationEmail),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _logout,
                child: Text(context.l10n.signOutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
