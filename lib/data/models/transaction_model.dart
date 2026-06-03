class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isExpense;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.isExpense = true,
  });
}
