import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min;
import 'package:payremind/core/theme/app_colors.dart';
import '../providers/finance_provider.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/transaction_tile.dart';
import '../../../../models/finance/dashboard_model.dart';
import '../../../../core/network/error_handler.dart';

class FinancialDashboardScreen extends ConsumerStatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  ConsumerState<FinancialDashboardScreen> createState() =>
      _FinancialDashboardScreenState();
}

class _FinancialDashboardScreenState
    extends ConsumerState<FinancialDashboardScreen> {
  late int _month;
  late int _year;

  static const _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year  = now.year;
  }

  void _prev() => setState(() {
        if (_month == 1) { _month = 12; _year--; } else { _month--; }
      });

  void _next() => setState(() {
        if (_month == 12) { _month = 1; _year++; } else { _month++; }
      });

  @override
  Widget build(BuildContext context) {
    final period       = DashboardPeriod(month: _month, year: _year);
    final dashboardAsync = ref.watch(financialDashboardProvider(period));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        actions: [
          IconButton(
            icon:    const Icon(Icons.receipt_long_outlined),
            tooltip: 'Transacciones',
            onPressed: () => context.push('/finance/transactions'),
          ),
          IconButton(
            icon:    const Icon(Icons.track_changes_rounded),
            tooltip: 'Presupuestos',
            onPressed: () => context.push('/finance/budgets'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await context.push<bool>('/finance/transactions/create');
          if (ok == true) ref.invalidate(financialDashboardProvider(period));
        },
        icon:  const Icon(Icons.add_rounded),
        label: const Text('Nueva transacción'),
      ),
      body: Column(
        children: [
          // ── Month Selector ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color:        AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon:      const Icon(Icons.chevron_left_rounded, color: AppColors.primaryLight),
                    onPressed: _prev,
                  ),
                  Expanded(
                    child: Text(
                      '${_months[_month - 1]} $_year',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:      const Icon(Icons.chevron_right_rounded, color: AppColors.primaryLight),
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: dashboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        ErrorHandler.getFriendlyMessage(e),
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => ref.refresh(financialDashboardProvider(period)),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) {
                final s = data.summary;
                String fmt(double v) =>
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(v);

                final balanceColor = s.balance >= 0 ? AppColors.income : AppColors.error;

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(financialDashboardProvider(period).future),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    children: [
                      // ── Summary Cards ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Ingresos',
                              value: fmt(s.totalIncome),
                              color: AppColors.income,
                              icon:  Icons.trending_up_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Gastos',
                              value: fmt(s.totalExpenses),
                              color: AppColors.error,
                              icon:  Icons.trending_down_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _SummaryCard(
                        label:    'Balance del mes',
                        value:    fmt(s.balance),
                        color:    balanceColor,
                        icon:     Icons.account_balance_rounded,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 28),

                      // ── Budgets ─────────────────────────────────────────
                      if (data.budgetStatus.isNotEmpty) ...[
                        _SectionHeader(
                          title:       'Presupuestos',
                          actionLabel: 'Ver todos',
                          onAction:    () => context.push('/finance/budgets'),
                        ),
                        const SizedBox(height: 10),
                        ...data.budgetStatus.map((s) => _BudgetCard(status: s)),
                        const SizedBox(height: 28),
                      ],

                      // ── Expenses by category ────────────────────────────
                      if (data.expensesByCategory.isNotEmpty) ...[
                        const _SectionHeader(title: 'Gastos por categoría'),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color:        AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border:       Border.all(color: AppColors.borderDefault),
                          ),
                          child: Column(
                            children: data.expensesByCategory.asMap().entries.map((e) {
                              final isLast = e.key == data.expensesByCategory.length - 1;
                              final cs     = e.value;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: _CategoryRow(
                                      cs:    cs,
                                      total: fmt(cs.total),
                                    ),
                                  ),
                                  if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Recent Transactions ─────────────────────────────
                      if (data.recentTransactions.isNotEmpty) ...[
                        _SectionHeader(
                          title:       'Últimas transacciones',
                          actionLabel: 'Ver todas',
                          onAction:    () => context.push('/finance/transactions'),
                        ),
                        const SizedBox(height: 8),
                        ...data.recentTransactions
                            .map((tx) => TransactionTile(transaction: tx)),
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
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final IconData icon;
  final bool fullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.borderDefault),
      ),
      child: fullWidth
          ? Row(
              children: [
                _IconBox(color: color, icon: icon, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(label),
                      const SizedBox(height: 2),
                      _Value(value, color: color, size: 22),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(color: color, icon: icon, size: 16),
                const SizedBox(height: 10),
                _Label(label),
                const SizedBox(height: 2),
                _Value(value, color: color, size: 20),
              ],
            ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final Color color; final IconData icon; final double size;
  const _IconBox({required this.color, required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

class _Value extends StatelessWidget {
  final String text; final Color color; final double size;
  const _Value(this.text, {required this.color, required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700),
          ),
        ),
      );
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String  title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      );
}

// ── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final CategorySummary cs;
  final String total;

  const _CategoryRow({required this.cs, required this.total});

  @override
  Widget build(BuildContext context) {
    final barColor = _hexColor(cs.category.color) ?? AppColors.primary;

    return Row(
      children: [
        CategoryIconWidget(category: cs.category, size: 38, iconSize: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cs.category.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$total ${cs.currency}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:      cs.percentage / 100,
                  minHeight:  5,
                  backgroundColor: AppColors.borderDefault,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${cs.percentage.toStringAsFixed(0)}% del total',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color? _hexColor(String? hex) {
    if (hex == null) return null;
    try { return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16)); }
    catch (_) { return null; }
  }
}

// ── Budget Card ──────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final BudgetStatus status;
  const _BudgetCard({required this.status});

  @override
  Widget build(BuildContext context) {
    String fmt(double v) =>
        NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(v);
    final progress = min(status.percentageUsed / 100, 1.0);
    final pct      = status.percentageUsed;

    final Color barColor;
    if (pct >= 100) {
      barColor = AppColors.error;
    } else if (pct >= 80)  barColor = AppColors.warning;
    else                 barColor = AppColors.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status.budget.category?.name ?? 'General',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
              if (status.isExceeded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:  AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Excedido',
                    style: TextStyle(color: Color(0xFFF87171), fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:      progress,
              minHeight:  8,
              backgroundColor: AppColors.borderDefault,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${fmt(status.spent)} de ${fmt(status.budget.amount)} ${status.budget.currency}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(color: barColor, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
