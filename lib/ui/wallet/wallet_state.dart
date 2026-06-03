import '../../data/models/transaction_model.dart';

sealed class WalletState { const WalletState(); }
class WalletIdle    extends WalletState { const WalletIdle(); }
class WalletLoading extends WalletState { const WalletLoading(); }
class WalletSuccess extends WalletState {
  final double balance;
  final List<TransactionModel> transactions;
  const WalletSuccess({required this.balance, required this.transactions});
}
class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
}
