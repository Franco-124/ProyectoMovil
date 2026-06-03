import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'login_notifier.dart';
import 'login_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Equivalente al collect { state -> when(state) } del Fragment
    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next is LoginSuccess) {
        context.go(AppRoutes.home);
        ref.read(loginProvider.notifier).reset();
      }
    });

    final emailError    = loginState is LoginError && loginState.fieldError == LoginField.email
        ? 'Completá todos los campos antes de continuar.' : null;
    final passwordError = loginState is LoginError && loginState.fieldError == LoginField.password
        ? 'Completá todos los campos antes de continuar.' : null;
    final generalError  = loginState is LoginError && loginState.fieldError == null
        ? loginState.message : null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'E-BIKE RENTALS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accentTeal,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'LOGIN',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textWhite, fontSize: 18),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: AppColors.darkButton),
                decoration: InputDecoration(
                  hintText: 'Password',
                  errorText: passwordError,
                ),
              ),
              const SizedBox(height: 8),

              // Error general
              if (generalError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    generalError,
                    style: const TextStyle(color: AppColors.statusCancelled),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Botón Login
              ElevatedButton(
                onPressed: loginState is LoginLoading
                    ? null
                    : () => ref.read(loginProvider.notifier).onLoginPressed(
                          _emailCtrl.text, _passwordCtrl.text),
                child: loginState is LoginLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.bgDark, strokeWidth: 2),
                      )
                    : const Text('LOGIN'),
              ),
              const SizedBox(height: 16),

              // Links
              TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot Password?',
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.signup),
                child: const Text("Don't have an account? Sign Up",
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
