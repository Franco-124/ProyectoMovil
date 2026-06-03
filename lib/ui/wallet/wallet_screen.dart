import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'wallet_notifier.dart';
import 'wallet_state.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wallet', style: TextStyle(color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentTeal),
            onPressed: () => ref.read(walletProvider.notifier).onReloadPressed(),
            tooltip: 'Recargar',
          )
        ],
      ),
      body: switch (state) {
        WalletLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        WalletSuccess(:final balance, :final transactions) => Column(
          children: [
            // Balance card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentTeal],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance',
                      style: TextStyle(color: AppColors.textWhite)),
                  Text('\$$balance',
                      style: const TextStyle(color: AppColors.textWhite,
                          fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Transactions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft,
                  child: Text('Transactions',
                      style: TextStyle(color: AppColors.textWhite,
                          fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: transactions.length,
                itemBuilder: (_, i) => _TransactionTile(transactions[i]),
              ),
            ),
          ],
        ),
        WalletError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile(this.tx);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: tx.isExpense ? AppColors.textGray : AppColors.statusCompleted,
          child: Icon(tx.isExpense ? Icons.remove : Icons.add,
              color: AppColors.textWhite),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.title, style: const TextStyle(color: AppColors.textWhite,
                fontWeight: FontWeight.w500)),
            Text(tx.date, style: const TextStyle(color: AppColors.textGray,
                fontSize: 12)),
          ]),
        ),
        Text(
          tx.isExpense ? '-\$${tx.amount}' : '+\$${tx.amount}',
          style: TextStyle(
            color: tx.isExpense ? AppColors.textWhite : AppColors.statusCompleted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
