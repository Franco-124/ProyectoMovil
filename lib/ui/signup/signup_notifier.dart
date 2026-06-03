import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'signup_state.dart';

class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthRepository _auth;
  SignUpNotifier(this._auth) : super(const SignUpIdle());

  Future<void> onSignUpPressed(
      String name, String email, String pass, String confirmPass) async {
    if (name.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.fullName); return;
    }
    if (email.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.email); return;
    }
    if (pass.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.password); return;
    }
    if (confirmPass.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.confirmPassword); return;
    }
    if (pass != confirmPass) {
      state = const SignUpError(message: 'Passwords do not match.'); return;
    }

    state = const SignUpLoading();
    try {
      await _auth.signUp(email.trim(), pass.trim());
      state = SignUpSuccess(email.trim());
    } catch (e) {
      state = SignUpError(message: e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final signUpProvider = StateNotifierProvider.autoDispose<SignUpNotifier, SignUpState>(
  (ref) => SignUpNotifier(AuthRepository()),
);
