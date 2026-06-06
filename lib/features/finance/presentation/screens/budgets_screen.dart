import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../widgets/category_icon_widget.dart';
import '../../../../models/finance/budget_model.dart';
import '../../../../models/finance/category_model.dart';
import '../../../../core/network/error_handler.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late int _selectedYear;

  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
  }

  void _nextYear() {
    setState(() {
      _selectedYear++;
    });
  }

  Future<void> _deleteBudget(BudgetModel budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar presupuesto?'),
        content: const Text('¿Estás seguro de que deseas eliminar este presupuesto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(budgetNotifierProvider.notifier).deleteBudget(budget.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presupuesto eliminado correctamente'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      } else {
        final error = ref.read(budgetNotifierProvider).error?.toString() ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar presupuesto: $error'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showCreateBudgetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CreateBudgetBottomSheet(
        selectedYear: _selectedYear,
        monthsList: _months,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsProvider(_selectedYear));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBudgetBottomSheet,
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Year Selector
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
                      onPressed: _previousYear,
                    ),
                    Text(
                      'Año $_selectedYear',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF818CF8)),
                      onPressed: _nextYear,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Budgets List
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF6366F1),
              onRefresh: () => ref.refresh(budgetsProvider(_selectedYear).future),
              child: budgetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                        const SizedBox(height: 16),
                        Text(
                          ErrorHandler.getFriendlyMessage(e),
                          style: const TextStyle(color: Color(0xFFF87171)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(budgetsProvider(_selectedYear)),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (budgets) {
                  if (budgets.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'No hay presupuestos para este año',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      final categoryName = budget.category?.name ?? 'Presupuesto general';
                      
                      final periodText = budget.periodType == 'monthly'
                          ? 'Mensual - ${_months[budget.month! - 1]} ${budget.year}'
                          : 'Anual - ${budget.year}';

                      final amountFormatted = NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(budget.amount);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: budget.category != null
                              ? CategoryIconWidget(category: budget.category!)
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF6366F1),
                                      size: 20,
                                    ),
                                  ),
                                ),
                          title: Text(
                            categoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  periodText,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Límite: $amountFormatted ${budget.currency}',
                                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                            onPressed: () => _deleteBudget(budget),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateBudgetBottomSheet extends ConsumerStatefulWidget {
  final int selectedYear;
  final List<String> monthsList;

  const CreateBudgetBottomSheet({
    super.key,
    required this.selectedYear,
    required this.monthsList,
  });

  @override
  ConsumerState<CreateBudgetBottomSheet> createState() => _CreateBudgetBottomSheetState();
}

class _CreateBudgetBottomSheetState extends ConsumerState<CreateBudgetBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isMonthly = true;
  int _selectedMonth = DateTime.now().month;
  CategoryModel? _selectedCategory; // null = General
  final _amountController = TextEditingController();
  String _selectedCurrency = 'COP';

  final List<String> _currencies = ['COP'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto debe ser un número válido mayor que 0'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final success = await ref.read(budgetNotifierProvider.notifier).createBudget(
      amount: amount,
      periodType: _isMonthly ? 'monthly' : 'annual',
      year: widget.selectedYear,
      month: _isMonthly ? _selectedMonth : null,
      categoryId: _selectedCategory?.id,
      currency: _selectedCurrency,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presupuesto creado correctamente'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(budgetNotifierProvider).error?.toString() ?? 'Error desconocido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear presupuesto: $error'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider('expense'));
    final budgetState = ref.watch(budgetNotifierProvider);
    final isLoading = budgetState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crear Presupuesto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Toggle Mensual / Anual
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Mensual'),
                        icon: Icon(Icons.calendar_view_month_rounded),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Anual'),
                        icon: Icon(Icons.calendar_today_rounded),
                      ),
                    ],
                    selected: {_isMonthly},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _isMonthly = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0xFF6366F1),
                      selectedForegroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Month picker (if monthly)
              if (_isMonthly) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona el mes',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(widget.monthsList[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 3. Category Picker (expenses only, plus "General" option)
              const Text(
                'Categoría de Gasto',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                child: categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                  error: (e, _) => Center(child: Text(ErrorHandler.getFriendlyMessage(e), style: const TextStyle(color: Color(0xFFEF4444)))),
                  data: (categories) {
                    // Combine a dummy Category representing "General/Global" at the start
                    final allItems = [
                      null, // representing general
                      ...categories,
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final cat = allItems[index];
                        final isSelected = _selectedCategory?.id == cat?.id;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6366F1).withOpacity(0.15) : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (cat == null)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6366F1), size: 16),
                                  )
                                else
                                  CategoryIconWidget(category: cat, size: 32, iconSize: 16),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    cat?.name ?? 'General',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 4. Amount and Currency Fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Límite de monto',
                        hintText: '0.00',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa el monto';
                        }
                        final amount = double.tryParse(val.trim());
                        if (amount == null || amount <= 0) {
                          return 'Debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      isExpanded: true,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Moneda',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Save Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Crear Presupuesto',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
