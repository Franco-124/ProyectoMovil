sealed class ForgotPasswordState { const ForgotPasswordState(); }
class ForgotPasswordIdle    extends ForgotPasswordState { const ForgotPasswordIdle(); }
class ForgotPasswordError   extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
}
class ForgotPasswordSuccess extends ForgotPasswordState { const ForgotPasswordSuccess(); }
