// Equivalente a LoginUiState.kt + LoginField enum
sealed class LoginState {
  const LoginState();
}

class LoginIdle    extends LoginState { const LoginIdle(); }
class LoginLoading extends LoginState { const LoginLoading(); }

class LoginError extends LoginState {
  final String? message;
  final LoginField? fieldError;
  const LoginError({this.message, this.fieldError});
}

class LoginSuccess extends LoginState {
  final String email;
  const LoginSuccess(this.email);
}

enum LoginField { email, password }
