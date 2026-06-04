import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/finance_provider.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedType; // null = Todos, 'income' = Ingresos, 'expense' = Gastos

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filter = TransactionFilter(
      type: _selectedType,
      month: now.month,
      year: now.year,
    );

    final transactionsAsync = ref.watch(transactionsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>('/finance/transactions/create');
          if (result == true) {
            ref.invalidate(transactionsProvider(filter));
          }
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  value: null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ingresos',
                  value: 'income',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Gastos',
                  value: 'expense',
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF6366F1),
              onRefresh: () => ref.refresh(transactionsProvider(filter).future),
              child: transactionsAsync.when(
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
                          'Error: $e',
                          style: const TextStyle(color: Color(0xFFF87171)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(transactionsProvider(filter)),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'No hay transacciones en este mes',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('¿Eliminar transacción?'),
                              content: const Text('Esta acción no se puede deshacer.'),
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
                        },
                        onDismissed: (direction) async {
                          final success = await ref
                              .read(transactionNotifierProvider.notifier)
                              .deleteTransaction(tx.id);
                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transacción eliminada exitosamente'),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                          } else {
                            final error = ref.read(transactionNotifierProvider).error?.toString() ?? 'Error desconocido';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al eliminar: $error'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                            // Invalidate to reload the list
                            ref.invalidate(transactionsProvider(filter));
                          }
                        },
                        child: TransactionTile(transaction: tx),
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

  Widget _buildFilterChip({
    required String label,
    required String? value,
  }) {
    final isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = value;
          });
        }
      },
      selectedColor: const Color(0xFF6366F1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
        ),
      ),
      showCheckmark: false,
    );
  }
}
