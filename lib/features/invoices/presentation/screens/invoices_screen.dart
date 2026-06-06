import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import 'package:payremind/core/theme/app_colors.dart';
import '../providers/invoice_provider.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/invoice_model.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String? _filter;
  bool    _actionLoading = false;

  static const _filters = [
    (null,        'Todos'),
    ('pending',   'Pendiente'),
    ('overdue',   'Vencida'),
    ('paid',      'Pagada'),
    ('cancelled', 'Cancelada'),
  ];

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Nueva factura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: AppColors.primary),
              title: const Text('Registrar factura'),
              subtitle: const Text('Trackear una factura que ya existe'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/invoices/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.send_rounded, color: AppColors.income),
              title: const Text('Emitir factura'),
              subtitle: const Text('Crear y enviar una factura con PDF al cliente'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/invoices/emit');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _sendReminder(String id) async {
    setState(() => _actionLoading = true);
    try {
      final result = await ref.read(invoiceRepositoryProvider).sendReminder(id);
      String tone = result.tone;
      switch (tone.toLowerCase()) {
        case 'friendly': tone = 'Amigable'; break;
        case 'firm':     tone = 'Firme';    break;
        case 'final':    tone = 'Final';    break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Recordatorio enviado a ${result.to} (Tono: $tone)'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorHandler.getFriendlyMessage(e)),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Facturas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        icon:  const Icon(Icons.add_rounded),
        label: const Text('Nueva factura'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Filter chips ───────────────────────────────────────────
              SizedBox(
                height: 58,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final (value, label) = _filters[i];
                    final selected = _filter == value;
                    return FilterChip(
                      label:         Text(label),
                      selected:      selected,
                      onSelected:    (_) => setState(() => _filter = value),
                      selectedColor: AppColors.primaryGlow,
                      checkmarkColor:AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color:      selected ? AppColors.primaryLight : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        fontSize:   13,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.borderDefault,
                      ),
                    );
                  },
                ),
              ),

              // ── List ───────────────────────────────────────────────────
              Expanded(
                child: invoicesAsync.when(
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
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => ref.refresh(invoicesProvider(_filter)),
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
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGlow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryLight, size: 36),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filter == null
                                    ? 'Sin facturas registradas'
                                    : 'Sin facturas con este estado',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref.refresh(invoicesProvider(_filter).future),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                            itemCount: invoices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _InvoiceCard(
                              invoice:       invoices[i],
                              onTap:         () => context.push('/invoices/${invoices[i].id}'),
                              onSendReminder:() => _sendReminder(invoices[i].id),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          if (_actionLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ── Invoice Card ─────────────────────────────────────────────────────────────

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
    final amount = NumberFormat.currency(symbol: '\$', decimalDigits: 0)
        .format(invoice.amount);
    final parsedDate = DateTime.tryParse(invoice.dueDate);
    final dueDate = parsedDate != null
        ? DateFormat('dd MMM, yyyy').format(parsedDate)
        : invoice.dueDate;

    final canRemind = invoice.status == 'pending' || invoice.status == 'overdue';

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor:  AppColors.primaryGlow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Factura #${invoice.invoiceNumber}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    StatusBadge(invoice.status),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Meta row ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CLIENTE',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            invoice.client.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
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
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dueDate,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 20, color: AppColors.borderSubtle),

                // ── Amount + actions ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$amount ${invoice.currency}',
                      style: const TextStyle(
                        color:      AppColors.income,
                        fontWeight: FontWeight.w800,
                        fontSize:   18,
                      ),
                    ),
                    Row(
                      children: [
                        if (canRemind) ...[
                          _ActionChip(
                            icon:     Icons.send_rounded,
                            label:    'Recordatorio',
                            onTap:    onSendReminder,
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Text(
                          'Detalles',
                          style: TextStyle(
                            color:      AppColors.primary,
                            fontSize:   13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        AppColors.primaryGlow,
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.primaryLight),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color:      AppColors.primaryLight,
                fontSize:   12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
