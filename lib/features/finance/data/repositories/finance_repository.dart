import '../../../../core/network/api_client.dart';
import '../../../../models/finance/category_model.dart';
import '../../../../models/finance/transaction_model.dart';
import '../../../../models/finance/budget_model.dart';
import '../../../../models/finance/dashboard_model.dart';

class FinanceRepository {
  final _dio = ApiClient.instance;

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final Map<String, dynamic> params = {};
    if (type != null) params['type'] = type;

    final res = await _dio.get(
      '/finance/categories',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return (res.data as List)
        .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getIncomeCategories() => getCategories(type: 'income');

  Future<List<CategoryModel>> getExpenseCategories() => getCategories(type: 'expense');

  Future<List<TransactionModel>> getTransactions({
    String? type,
    int? month,
    int? year,
    String? categoryId,
  }) async {
    final Map<String, dynamic> params = {};
    if (type != null) params['type'] = type;
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;
    if (categoryId != null) params['category_id'] = categoryId;

    final res = await _dio.get(
      '/finance/transactions',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return (res.data as List)
        .map((j) => TransactionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> createTransaction({
    required String categoryId,
    required String type,
    required double amount,
    required DateTime date,
    String currency = 'COP',
    String? description,
  }) async {
    final dateStr = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final Map<String, dynamic> body = {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'date': dateStr,
    };
    if (description != null) body['description'] = description;

    final res = await _dio.post('/finance/transactions', data: body);
    return TransactionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/finance/transactions/$id');
  }

  Future<List<BudgetModel>> getBudgets({int? year}) async {
    final Map<String, dynamic> params = {};
    if (year != null) params['year'] = year;

    final res = await _dio.get(
      '/finance/budgets',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return (res.data as List)
        .map((j) => BudgetModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<BudgetModel> createBudget({
    required double amount,
    required String periodType,
    required int year,
    int? month,
    String? categoryId,
    String currency = 'COP',
  }) async {
    final Map<String, dynamic> body = {
      'amount': amount,
      'period_type': periodType,
      'year': year,
      'currency': currency,
    };
    if (month != null) body['month'] = month;
    if (categoryId != null) body['category_id'] = categoryId;

    final res = await _dio.post('/finance/budgets', data: body);
    return BudgetModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteBudget(String id) async {
    await _dio.delete('/finance/budgets/$id');
  }

  Future<FinancialDashboard> getDashboard({int? month, int? year}) async {
    final now = DateTime.now();
    final Map<String, dynamic> params = {
      'month': month ?? now.month,
      'year': year ?? now.year,
    };

    final res = await _dio.get(
      '/finance/dashboard',
      queryParameters: params,
    );
    return FinancialDashboard.fromJson(res.data as Map<String, dynamic>);
  }
}
