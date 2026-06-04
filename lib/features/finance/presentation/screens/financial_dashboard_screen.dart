import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min;
import '../providers/finance_provider.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/transaction_tile.dart';
import '../../../../models/finance/dashboard_model.dart';
import '../../../../core/network/error_handler.dart';

class FinancialDashboardScreen extends ConsumerStatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  ConsumerState<FinancialDashboardScreen> createState() => _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState extends ConsumerState<FinancialDashboardScreen> {
  late int _month;
  late int _year;

  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
  }

  void _previousMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final period = DashboardPeriod(month: _month, year: _year);
    final dashboardAsync = ref.watch(financialDashboardProvider(period));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Transacciones',
            onPressed: () => context.push('/finance/transactions'),
          ),
          IconButton(
            icon: const Icon(Icons.track_changes_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Presupuestos',
            onPressed: () => context.push('/finance/budgets'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>('/finance/transactions/create');
          if (result == true) {
            ref.invalidate(financialDashboardProvider(period));
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva transacción', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Column(
        children: [
          // Period Selector Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF818CF8)),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_months[_month - 1]} $_year',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF818CF8)),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 16),
                      Text(ErrorHandler.getFriendlyMessage(e), style: const TextStyle(color: Color(0xFFF87171)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(financialDashboardProvider(period)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) {
                final summary = data.summary;
                
                final formattedIncome = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(summary.totalIncome);
                final formattedExpenses = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(summary.totalExpenses);
                final formattedBalance = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(summary.balance);

                final balanceColor = summary.balance >= 0 ? const Color(0xFF6366F1) : const Color(0xFFEF4444);

                return RefreshIndicator(
                  color: const Color(0xFF6366F1),
                  onRefresh: () => ref.refresh(financialDashboardProvider(period).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    children: [
                      // Summary Row (3 mini cards)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniSummaryCard(
                              label: 'Ingresos',
                              value: formattedIncome,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniSummaryCard(
                              label: 'Gastos',
                              value: formattedExpenses,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniSummaryCard(
                              label: 'Balance',
                              value: formattedBalance,
                              color: balanceColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Budget Status Section
                      if (data.budgetStatus.isNotEmpty) ...[
                        _buildSectionHeader('Presupuestos'),
                        const SizedBox(height: 8),
                        ...data.budgetStatus.map((status) => _buildBudgetStatusCard(status)),
                        const SizedBox(height: 24),
                      ],

                      // Expenses by category Section
                      if (data.expensesByCategory.isNotEmpty) ...[
                        _buildSectionHeader('Gastos por categoría'),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: data.expensesByCategory.map((categorySummary) {
                                final totalFormatted = NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(categorySummary.total);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      CategoryIconWidget(category: categorySummary.category, size: 36, iconSize: 18),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  categorySummary.category.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                                ),
                                                Text(
                                                  '$totalFormatted ${categorySummary.currency}',
                                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: categorySummary.percentage / 100,
                                                minHeight: 6,
                                                backgroundColor: const Color(0xFF334155),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  categorySummary.category.color != null
                                                      ? _getColor(categorySummary.category.color)
                                                      : const Color(0xFF6366F1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recent Transactions Section
                      if (data.recentTransactions.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Últimas transacciones',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () => context.push('/finance/transactions'),
                              child: const Text('Ver todas', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...data.recentTransactions.map((tx) => TransactionTile(transaction: tx)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBudgetStatusCard(BudgetStatus status) {
    final spentFormatted = NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(status.spent);
    final limitFormatted = NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(status.budget.amount);
    
    final categoryName = status.budget.category?.name ?? 'General';
    final progress = min(status.percentageUsed / 100, 1.0);

    Color progressColor = const Color(0xFF22C55E); // green
    if (status.percentageUsed >= 100.0) {
      progressColor = const Color(0xFFEF4444); // red
    } else if (status.percentageUsed >= 80.0) {
      progressColor = const Color(0xFFF59E0B); // yellow
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
                if (status.isExceeded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Excedido',
                      style: TextStyle(color: Color(0xFFF87171), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF334155),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$spentFormatted de $limitFormatted ${status.budget.currency}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                Text(
                  '${status.percentageUsed.toStringAsFixed(0)}%',
                  style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String? hexColor) {
    if (hexColor == null) return Colors.grey;
    final hex = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
