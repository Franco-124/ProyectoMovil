import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import 'wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletIdle()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = const WalletLoading();
    await Future.delayed(const Duration(milliseconds: 1500));

    state = const WalletSuccess(
      balance: 85.50,
      transactions: [
        TransactionModel(id:'1', title:'Viaje al Centro',        date:'20 Oct 2023', amount:15.00, isExpense:true),
        TransactionModel(id:'2', title:'Recarga de saldo',       date:'18 Oct 2023', amount:50.00, isExpense:false),
        TransactionModel(id:'3', title:'Viaje a la Universidad', date:'15 Oct 2023', amount:12.50, isExpense:true),
      ],
    );
  }

  void onReloadPressed() => _loadData();
}

final walletProvider = StateNotifierProvider.autoDispose<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(),
);
