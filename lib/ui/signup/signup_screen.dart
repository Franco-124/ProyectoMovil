import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'signup_notifier.dart';
import 'signup_state.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);

    ref.listen<SignUpState>(signUpProvider, (_, next) {
      if (next is SignUpSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')));
        context.pop();
      }
    });

    String? fieldErr(SignUpField f) =>
        state is SignUpError && state.fieldError == f
            ? 'Completá todos los campos antes de continuar.' : null;

    final generalErr = state is SignUpError && state.fieldError == null
        ? state.message : null;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  errorText: fieldErr(SignUpField.fullName),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Email',
                  errorText: fieldErr(SignUpField.email),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Password',
                  errorText: fieldErr(SignUpField.password),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  errorText: fieldErr(SignUpField.confirmPassword),
                ),
              ),
              const SizedBox(height: 8),

              if (generalErr != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    generalErr,
                    style: const TextStyle(color: AppColors.statusCancelled),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: state is SignUpLoading ? null : () =>
                    ref.read(signUpProvider.notifier).onSignUpPressed(
                        _nameCtrl.text, _emailCtrl.text,
                        _passCtrl.text, _confirmCtrl.text),
                child: state is SignUpLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.bgDark, strokeWidth: 2),
                      )
                    : const Text('SIGN UP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Already have an account? Login',
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
