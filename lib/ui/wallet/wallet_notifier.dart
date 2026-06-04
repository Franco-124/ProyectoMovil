import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repo;
  WalletNotifier(this._repo) : super(const WalletIdle()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = const WalletLoading();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      state = const WalletError('Usuario no autenticado.');
      return;
    }

    try {
      final balance = await _repo.getBalance(userId);
      final txs = await _repo.getTransactions(userId);
      state = WalletSuccess(balance: balance, transactions: txs);
    } catch (e) {
      state = WalletError(e.toString());
    }
  }

  Future<void> onReloadPressed() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = const WalletLoading();
    try {
      // Recargar $50.00 por defecto de forma simulada
      await _repo.reloadBalance(userId, 50.00);
      await _loadData();
    } catch (e) {
      state = WalletError(e.toString());
    }
  }
}

final walletProvider = StateNotifierProvider.autoDispose<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(WalletRepository()),
);
