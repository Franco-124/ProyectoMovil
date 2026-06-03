import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

// Equivalente a LoginViewModel.kt
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _auth;
  LoginNotifier(this._auth) : super(const LoginIdle());

  Future<void> onLoginPressed(String email, String password) async {
    final e = email.trim();
    final p = password.trim();

    if (e.isEmpty) {
      state = const LoginError(fieldError: LoginField.email);
      return;
    }
    if (p.isEmpty) {
      state = const LoginError(fieldError: LoginField.password);
      return;
    }

    state = const LoginLoading();
    try {
      await _auth.login(e, p);
      state = LoginSuccess(e);
    } catch (ex) {
      // Mostrar un mensaje de error legible
      state = LoginError(message: ex.toString().replaceAll('Exception: ', ''));
    }
  }

  void reset() => state = const LoginIdle();
}

final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(AuthRepository()),
);
