import 'category_model.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;
  final bool isAutomatic;
  final DateTime createdAt;
  final String? invoiceId;
  final CategoryModel category;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.description,
    required this.date,
    required this.isAutomatic,
    required this.createdAt,
    this.invoiceId,
    required this.category,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      amount: double.parse(json['amount'].toString()),
      currency: json['currency']?.toString() ?? 'USD',
      description: json['description']?.toString(),
      date: DateTime.parse(json['date'] as String),
      isAutomatic: json['is_automatic'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      invoiceId: json['invoice_id']?.toString(),
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'currency': currency,
    'description': description,
    'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'is_automatic': isAutomatic,
    'created_at': createdAt.toIso8601String(),
    'invoice_id': invoiceId,
    'category': category.toJson(),
  };

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    bool? isAutomatic,
    DateTime? createdAt,
    String? invoiceId,
    CategoryModel? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      createdAt: createdAt ?? this.createdAt,
      invoiceId: invoiceId ?? this.invoiceId,
      category: category ?? this.category,
    );
  }
}
