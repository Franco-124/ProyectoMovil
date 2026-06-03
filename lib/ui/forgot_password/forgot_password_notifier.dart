import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_state.dart';

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordIdle());

  void onSendPressed(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isNotEmpty && emailRegex.hasMatch(email)) {
      state = const ForgotPasswordSuccess();
    } else {
      state = const ForgotPasswordError('Please enter a valid email address.');
    }
  }

  void reset() => state = const ForgotPasswordIdle();
}

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(),
);
