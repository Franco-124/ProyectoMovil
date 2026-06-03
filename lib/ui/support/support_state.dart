import '../../data/models/faq_model.dart';

sealed class SupportState { const SupportState(); }
class SupportIdle    extends SupportState { const SupportIdle(); }
class SupportLoading extends SupportState { const SupportLoading(); }
class SupportSuccess extends SupportState {
  final List<FaqModel> faqs;
  final String contactEmail;
  final String contactPhone;
  const SupportSuccess({required this.faqs, required this.contactEmail, required this.contactPhone});
}
class SupportError extends SupportState {
  final String message;
  const SupportError(this.message);
}
