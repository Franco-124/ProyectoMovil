import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import '../providers/invoice_provider.dart';
import '../../../../shared/widgets/status_badge.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const InvoiceDetailScreen({super.key, required this.id});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isActionLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendReminder() async {
    setState(() => _isActionLoading = true);
    try {
      final result = await ref.read(invoiceRepositoryProvider).sendReminder(widget.id);
      
      String toneLabel = result.tone;
      switch (result.tone.toLowerCase()) {
        case 'friendly': toneLabel = 'Amigable'; break;
        case 'firm':     toneLabel = 'Firme'; break;
        case 'final':    toneLabel = 'Final'; break;
      }
      
      _showSnackBar('Recordatorio enviado a ${result.to} (Tono: $toneLabel).');
      ref.invalidate(invoiceDetailProvider(widget.id));
    } catch (e) {
      _showSnackBar(ErrorHandler.getFriendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _toggleReminders() async {
    setState(() => _isActionLoading = true);
    try {
      await ref.read(invoiceRepositoryProvider).toggleReminders(widget.id);
      ref.invalidate(invoiceDetailProvider(widget.id));
      _showSnackBar('Configuración de recordatorios actualizada.');
    } catch (e) {
      _showSnackBar(ErrorHandler.getFriendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isActionLoading = true);
    try {
      await ref.read(invoiceRepositoryProvider).updateStatus(widget.id, newStatus);
      ref.invalidate(invoiceDetailProvider(widget.id));
      ref.invalidate(invoicesProvider(null));
      _showSnackBar('Estado de la factura actualizado.');
    } catch (e) {
      _showSnackBar(ErrorHandler.getFriendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Factura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Eliminar Factura',
            onPressed: _isActionLoading ? null : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Factura'),
                  content: const Text('¿Estás seguro de que deseas eliminar esta factura de forma permanente? Esta acción no se puede deshacer.'),
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
                      child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                setState(() => _isActionLoading = true);
                try {
                  await ref.read(invoiceRepositoryProvider).deleteInvoice(widget.id);
                  ref.invalidate(invoicesProvider(null));
                  if (context.mounted) {
                    _showSnackBar('Factura eliminada con éxito.');
                    context.pop();
                  }
                } catch (e) {
                  _showSnackBar(ErrorHandler.getFriendlyMessage(e), isError: true);
                } finally {
                  if (mounted) setState(() => _isActionLoading = false);
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 16),
              Text(ErrorHandler.getFriendlyMessage(e), style: const TextStyle(color: Color(0xFFF87171))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(invoiceDetailProvider(widget.id)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (invoice) {
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

          final reminderConfig = invoice.reminderConfig;
          final isReminderActive = reminderConfig['active'] as bool? ?? false;
          final intervals = reminderConfig['intervals'] as List? ?? [];

          return Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFF6366F1),
                onRefresh: () => ref.refresh(invoiceDetailProvider(widget.id).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Main Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Factura #${invoice.invoiceNumber}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(invoice.status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              formattedAmount,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            Text(
                              'Moneda: ${invoice.currency.toUpperCase()}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                            if (invoice.description != null && invoice.description!.isNotEmpty) ...[
                              const Divider(color: Color(0xFF334155), height: 32),
                              const Text(
                                'DESCRIPCIÓN',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                invoice.description!,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Client Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INFORMACIÓN DEL CLIENTE',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Divider(color: Color(0xFF334155), height: 24),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                                child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1)),
                              ),
                              title: Text(
                                invoice.client.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                invoice.client.email,
                                style: const TextStyle(color: Color(0xFF94A3B8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (invoice.client.company != null && invoice.client.company!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.business_rounded, size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      invoice.client.company!,
                                      style: const TextStyle(color: Color(0xFF94A3B8)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reminders & Due Date Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PROGRAMACIÓN Y VENCIMIENTO',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Divider(color: Color(0xFF334155), height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Fecha de Vencimiento',
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF334155), height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Recordatorios Automáticos',
                                        style: TextStyle(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isReminderActive 
                                            ? 'Activo (Intervalos: ${intervals.join(", ")} días)' 
                                            : 'Desactivado',
                                        style: TextStyle(
                                          color: isReminderActive ? const Color(0xFF22C55E) : const Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isReminderActive,
                                  activeColor: const Color(0xFF6366F1),
                                  onChanged: _isActionLoading ? null : (_) => _toggleReminders(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions Group
                    const Text(
                      'ACCIONES RÁPIDAS',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isActionLoading ? null : _sendReminder,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Enviar Recordatorio Manual Ahora'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isActionLoading || invoice.status == 'paid'
                                ? null 
                                : () => _updateStatus('paid'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF22C55E)),
                              foregroundColor: const Color(0xFF22C55E),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Marcar Pagada'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isActionLoading || invoice.status == 'cancelled'
                                ? null 
                                : () => _updateStatus('cancelled'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              foregroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (_isActionLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
