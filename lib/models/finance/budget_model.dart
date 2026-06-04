import 'category_model.dart';

class BudgetModel {
  final String id;
  final double amount;
  final String currency;
  final String periodType; // "monthly" | "annual"
  final int year;
  final int? month;
  final CategoryModel? category;

  const BudgetModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.periodType,
    required this.year,
    this.month,
    this.category,
  });

  bool get isMonthly => periodType == 'monthly';
  bool get isAnnual => periodType == 'annual';

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      amount: double.parse(json['amount'].toString()),
      currency: json['currency']?.toString() ?? 'COP',
      periodType: json['period_type']?.toString() ?? 'monthly',
      year: json['year'] as int? ?? DateTime.now().year,
      month: json['month'] as int?,
      category: json['category'] != null 
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'currency': currency,
    'period_type': periodType,
    'year': year,
    'month': month,
    'category': category?.toJson(),
  };

  BudgetModel copyWith({
    String? id,
    double? amount,
    String? currency,
    String? periodType,
    int? year,
    int? month,
    CategoryModel? category,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      periodType: periodType ?? this.periodType,
      year: year ?? this.year,
      month: month ?? this.month,
      category: category ?? this.category,
    );
  }
}
