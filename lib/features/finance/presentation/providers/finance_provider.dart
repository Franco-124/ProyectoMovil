import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/finance_repository.dart';
import '../../data/services/transaction_scan_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../models/finance/category_model.dart';
import '../../../../models/finance/transaction_model.dart';
import '../../../../models/finance/budget_model.dart';
import '../../../../models/finance/dashboard_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((_) => FinanceRepository());

final transactionScanServiceProvider = Provider<TransactionScanService>(
  (_) => TransactionScanService(ApiClient.instance),
);

final categoriesProvider = FutureProvider.family<List<CategoryModel>, String?>((ref, type) async {
  final repo = ref.read(financeRepositoryProvider);
  return repo.getCategories(type: type);
});

class TransactionFilter {
  final String? type;
  final int? month;
  final int? year;
  final String? categoryId;

  const TransactionFilter({
    this.type,
    this.month,
    this.year,
    this.categoryId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFilter &&
        other.type == type &&
        other.month == month &&
        other.year == year &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode =>
      type.hashCode ^ month.hashCode ^ year.hashCode ^ categoryId.hashCode;
}

final transactionsProvider = FutureProvider.family<List<TransactionModel>, TransactionFilter>((ref, filter) async {
  final repo = ref.read(financeRepositoryProvider);
  return repo.getTransactions(
    type: filter.type,
    month: filter.month,
    year: filter.year,
    categoryId: filter.categoryId,
  );
});

final budgetsProvider = FutureProvider.family<List<BudgetModel>, int?>((ref, year) async {
  final repo = ref.read(financeRepositoryProvider);
  return repo.getBudgets(year: year);
});

class DashboardPeriod {
  final int month;
  final int year;

  const DashboardPeriod({
    required this.month,
    required this.year,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardPeriod &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => month.hashCode ^ year.hashCode;
}

final financialDashboardProvider = FutureProvider.family<FinancialDashboard, DashboardPeriod>((ref, period) async {
  final repo = ref.read(financeRepositoryProvider);
  return repo.getDashboard(month: period.month, year: period.year);
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repo;
  final Ref _ref;

  TransactionNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createTransaction({
    required String categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String currency = 'COP',
    String? description,
    Map<String, dynamic>? extraData,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createTransaction(
        categoryId: categoryId,
        type: type,
        amount: amount,
        date: date,
        currency: currency,
        description: description,
        extraData: extraData,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(financialDashboardProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteTransaction(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(financialDashboardProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier(ref.read(financeRepositoryProvider), ref);
});

class BudgetNotifier extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repo;
  final Ref _ref;

  BudgetNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  Future<bool> createBudget({
    required double amount,
    required String periodType,
    required int year,
    int? month,
    String? categoryId,
    String currency = 'COP',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createBudget(
        amount: amount,
        periodType: periodType,
        year: year,
        month: month,
        categoryId: categoryId,
        currency: currency,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(financialDashboardProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteBudget(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(financialDashboardProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<void>>((ref) {
  return BudgetNotifier(ref.read(financeRepositoryProvider), ref);
});
