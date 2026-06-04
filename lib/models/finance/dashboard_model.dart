import 'category_model.dart';
import 'transaction_model.dart';
import 'budget_model.dart';

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final String currency;
  final String period;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.currency,
    required this.period,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'COP',
      period: json['period']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'total_income': totalIncome,
    'total_expenses': totalExpenses,
    'balance': balance,
    'currency': currency,
    'period': period,
  };
}

class CategorySummary {
  final CategoryModel category;
  final double total;
  final double percentage;
  final String currency;
  final int transactionsCount;

  const CategorySummary({
    required this.category,
    required this.total,
    required this.percentage,
    required this.currency,
    required this.transactionsCount,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'COP',
      transactionsCount: json['transactions_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category.toJson(),
    'total': total,
    'percentage': percentage,
    'currency': currency,
    'transactions_count': transactionsCount,
  };
}

class BudgetStatus {
  final BudgetModel budget;
  final double spent;
  final double remaining;
  final double percentageUsed;
  final bool isExceeded;

  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.isExceeded,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) {
    return BudgetStatus(
      budget: BudgetModel.fromJson(json['budget'] as Map<String, dynamic>),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      percentageUsed: (json['percentage_used'] as num?)?.toDouble() ?? 0.0,
      isExceeded: json['is_exceeded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'budget': budget.toJson(),
    'spent': spent,
    'remaining': remaining,
    'percentage_used': percentageUsed,
    'is_exceeded': isExceeded,
  };
}

class FinancialDashboard {
  final FinancialSummary summary;
  final List<CategorySummary> incomeByCategory;
  final List<CategorySummary> expensesByCategory;
  final List<BudgetStatus> budgetStatus;
  final List<TransactionModel> recentTransactions;

  const FinancialDashboard({
    required this.summary,
    required this.incomeByCategory,
    required this.expensesByCategory,
    required this.budgetStatus,
    required this.recentTransactions,
  });

  factory FinancialDashboard.fromJson(Map<String, dynamic> json) {
    return FinancialDashboard(
      summary: FinancialSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      incomeByCategory: (json['income_by_category'] as List? ?? [])
          .map((item) => CategorySummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      expensesByCategory: (json['expenses_by_category'] as List? ?? [])
          .map((item) => CategorySummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      budgetStatus: (json['budget_status'] as List? ?? [])
          .map((item) => BudgetStatus.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recent_transactions'] as List? ?? [])
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary.toJson(),
    'income_by_category': incomeByCategory.map((x) => x.toJson()).toList(),
    'expenses_by_category': expensesByCategory.map((x) => x.toJson()).toList(),
    'budget_status': budgetStatus.map((x) => x.toJson()).toList(),
    'recent_transactions': recentTransactions.map((x) => x.toJson()).toList(),
  };
}
