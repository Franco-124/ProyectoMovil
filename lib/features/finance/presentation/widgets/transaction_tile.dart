import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/finance/transaction_model.dart';
import 'category_icon_widget.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    ).format(transaction.amount);

    final formattedDate = DateFormat('d MMM yyyy').format(transaction.date);

    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final prefix = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap ?? (transaction.invoiceId != null
            ? () => context.push('/invoices/${transaction.invoiceId}')
            : null),
        leading: CategoryIconWidget(category: transaction.category),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            if (transaction.isAutomatic) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: const Text(
                  'Auto',
                  style: TextStyle(color: Color(0xFF818CF8), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            transaction.description != null && transaction.description!.isNotEmpty
                ? transaction.description!
                : formattedDate,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          '$prefix$formattedAmount ${transaction.currency}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
