import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'forgot_password_notifier.dart';
import 'forgot_password_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    // Auto-pop después de success (equivale al delay(2000) + popBackStack)
    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (_, next) async {
      if (next is ForgotPasswordSuccess) {
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          context.pop();
          ref.read(forgotPasswordProvider.notifier).reset();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Forgot Password',
                style: TextStyle(color: AppColors.textWhite, fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Enter your email address below to receive a password reset link.',
              style: TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.darkButton),
              decoration: const InputDecoration(hintText: 'Email Address'),
            ),
            const SizedBox(height: 16),

            if (state is ForgotPasswordError)
              Text(state.message,
                  style: const TextStyle(color: AppColors.statusCancelled)),
            if (state is ForgotPasswordSuccess)
              const Text('Reset link sent to your email.',
                  style: TextStyle(color: AppColors.accentTeal)),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(forgotPasswordProvider.notifier)
                  .onSendPressed(_emailCtrl.text.trim()),
              child: const Text('Send Reset Link'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Login',
                  style: TextStyle(color: AppColors.accentTeal)),
            ),
          ],
        ),
      ),
    );
  }
}
