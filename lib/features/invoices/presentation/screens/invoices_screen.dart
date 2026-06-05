import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import '../providers/invoice_provider.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/invoice_model.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String? _statusFilter;
  bool _isActionLoading = false;

  static const _filters = [
    (null, 'Todos'),
    ('pending', 'Pendiente'),
    ('overdue', 'Vencida'),
    ('paid', 'Pagada'),
    ('cancelled', 'Cancelada'),
  ];

  Future<void> _sendManualReminder(String id) async {
    setState(() => _isActionLoading = true);
    try {
      final result = await ref.read(invoiceRepositoryProvider).sendReminder(id);
      
      String toneLabel = result.tone;
      switch (result.tone.toLowerCase()) {
        case 'friendly': toneLabel = 'Amigable'; break;
        case 'firm':     toneLabel = 'Firme'; break;
        case 'final':    toneLabel = 'Final'; break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recordatorio enviado a ${result.to} (Tono: $toneLabel).'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getFriendlyMessage(e)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider(_statusFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/create'),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nueva factura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter chips
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final (value, label) = _filters[i];
                    final isSelected = _statusFilter == value;
                    return FilterChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF6366F1),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
                        ),
                      ),
                      onSelected: (_) => setState(() => _statusFilter = value),
                    );
                  },
                ),
              ),

              // Invoice list
              Expanded(
                child: invoicesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
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
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFF87171)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(invoicesProvider(_statusFilter)),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (invoices) => invoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _statusFilter == null 
                                  ? 'No hay facturas registradas' 
                                  : 'No hay facturas con este estado',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6366F1),
                        onRefresh: () => ref.refresh(
                          invoicesProvider(_statusFilter).future),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: invoices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _InvoiceCard(
                            invoice: invoices[i],
                            onTap: () => context.push('/invoices/${invoices[i].id}'),
                            onSendReminder: () => _sendManualReminder(invoices[i].id),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
          if (_isActionLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onTap;
  final VoidCallback onSendReminder;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
    required this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    ).format(invoice.amount);

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.tryParse(invoice.dueDate);
    } catch (_) {}
    
    final formattedDate = parsedDate != null 
        ? DateFormat('dd MMM, yyyy').format(parsedDate)
        : invoice.dueDate;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Factura #${invoice.invoiceNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  StatusBadge(invoice.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLIENTE',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          invoice.client.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'VENCIMIENTO',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$formattedAmount ${invoice.currency}',
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (invoice.status == 'pending' || invoice.status == 'overdue') ...[
                    TextButton.icon(
                      onPressed: onSendReminder,
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text('Recordatorio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF818CF8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Detalles',
                    style: TextStyle(color: Color(0xFF6366F1), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF6366F1), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
