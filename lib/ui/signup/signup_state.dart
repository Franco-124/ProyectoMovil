sealed class SignUpState { const SignUpState(); }

class SignUpIdle    extends SignUpState { const SignUpIdle(); }
class SignUpLoading extends SignUpState { const SignUpLoading(); }
class SignUpSuccess extends SignUpState {
  final String email;
  const SignUpSuccess(this.email);
}
class SignUpError extends SignUpState {
  final String? message;
  final SignUpField? fieldError;
  const SignUpError({this.message, this.fieldError});
}

enum SignUpField { fullName, email, password, confirmPassword }
