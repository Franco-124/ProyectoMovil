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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Formatear la fecha
    final rawDate = json['created_at'] as String?;
    String formattedDate = '';
    if (rawDate != null) {
      try {
        final parsed = DateTime.parse(rawDate).toLocal();
        formattedDate = '${parsed.day} ${_getMonthName(parsed.month)} ${parsed.year}';
      } catch (_) {
        formattedDate = rawDate.split('T').first;
      }
    }

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Transacción',
      date: formattedDate,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense: json['is_expense'] as bool? ?? true,
    );
  }

  static String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
