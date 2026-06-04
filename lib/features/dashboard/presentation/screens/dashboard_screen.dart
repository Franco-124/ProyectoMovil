import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoices/presentation/providers/invoice_provider.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../invoices/data/models/invoice_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider(null));
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'PayRemind',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8)),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Salir', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
        error: (e, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar dashboard: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFF87171)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(invoicesProvider(null)),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (invoices) {
          final pending = invoices.where((i) => i.status == 'pending').toList();
          final overdue = invoices.where((i) => i.status == 'overdue').toList();
          final totalPending = pending.fold<double>(0, (sum, i) => sum + i.amount);
          
          final userName = userAsync.value?.fullName ?? 'Freelancer';

          return RefreshIndicator(
            color: const Color(0xFF6366F1),
            onRefresh: () => ref.refresh(invoicesProvider(null).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Header Greeting
                Text(
                  '¡Hola, $userName! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aquí tienes el estado actual de tus facturas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Pendientes',
                        value: '${pending.length}',
                        icon: Icons.access_time_rounded,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Vencidas',
                        value: '${overdue.length}',
                        icon: Icons.warning_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  label: 'Monto pendiente total',
                  value: '\$${totalPending.toStringAsFixed(2)} USD',
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF22C55E),
                  fullWidth: true,
                ),
                const SizedBox(height: 28),

                // Recent Activity Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Actividad reciente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/invoices'),
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (invoices.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay facturas registradas',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Crea una factura para comenzar a enviar recordatorios.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/invoices/create'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nueva factura'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...invoices.take(5).map((inv) => _InvoiceListTile(invoice: inv)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceListTile extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceListTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(invoice.amount);

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.tryParse(invoice.dueDate);
    } catch (_) {}
    
    final formattedDate = parsedDate != null 
        ? DateFormat('dd MMM, yyyy').format(parsedDate)
        : invoice.dueDate;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/invoices/${invoice.id}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_outlined,
            color: Color(0xFF6366F1),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Factura #${invoice.invoiceNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            StatusBadge(invoice.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.client.name,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              Text(
                'Vence: $formattedDate',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$formattedAmount ${invoice.currency}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF475569), size: 20),
          ],
        ),
      ),
    );
  }
}
