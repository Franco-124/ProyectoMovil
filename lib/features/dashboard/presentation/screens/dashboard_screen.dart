import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import 'package:payremind/core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../invoices/presentation/providers/invoice_provider.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../invoices/data/models/invoice_model.dart';

Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Cerrar Sesión'),
      content: const Text('¿Estás seguro de que deseas salir?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await ref.read(authProvider.notifier).logout();
    // El router navega automáticamente via refreshListenable
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider(null));
    final userAsync     = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text('PayRemind'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => _ErrorState(
          message: ErrorHandler.getFriendlyMessage(e),
          onRetry: () => ref.refresh(invoicesProvider(null)),
        ),
        data: (invoices) {
          final pending = invoices.where((i) => i.status == 'pending').toList();
          final overdue = invoices.where((i) => i.status == 'overdue').toList();
          final totalPending =
              pending.fold<double>(0, (s, i) => s + i.amount) +
              overdue.fold<double>(0,  (s, i) => s + i.amount);
          final firstName = userAsync.value?.fullName.split(' ').first ?? 'Freelancer';

          return RefreshIndicator(
            onRefresh: () => ref.refresh(invoicesProvider(null).future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // ── Greeting ──────────────────────────────────────────────
                Text(
                  '¡Hola, $firstName!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aquí está el resumen de tus cobros.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // ── Hero Card ─────────────────────────────────────────────
                _HeroCard(
                  totalPending:  totalPending,
                  pendingCount:  pending.length,
                  overdueCount:  overdue.length,
                ),
                const SizedBox(height: 28),

                // ── Recent Activity ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Actividad reciente',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/invoices'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (invoices.isEmpty)
                  _EmptyState(onAction: () => context.push('/invoices/create'))
                else
                  ...invoices.take(5).map((inv) => _InvoiceTile(invoice: inv)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final double totalPending;
  final int pendingCount;
  final int overdueCount;

  const _HeroCard({
    required this.totalPending,
    required this.pendingCount,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(symbol: '\$', decimalDigits: 0)
        .format(totalPending);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withOpacity(0.65),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Total pendiente de cobro',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            formatted,
            style: const TextStyle(
              color:       Colors.white,
              fontSize:    34,
              fontWeight:  FontWeight.w800,
              letterSpacing: -1.2,
              height:      1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'COP',
            style: TextStyle(
              color:      Colors.white.withOpacity(0.4),
              fontSize:   13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                label:     '$pendingCount pendientes',
                icon:      Icons.access_time_rounded,
                bgColor:   Colors.white.withOpacity(0.14),
                textColor: Colors.white,
              ),
              if (overdueCount > 0)
                _HeroChip(
                  label:     '$overdueCount vencidas',
                  icon:      Icons.warning_amber_rounded,
                  bgColor:   AppColors.error.withOpacity(0.22),
                  textColor: const Color(0xFFFCA5A5),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _HeroChip({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color:      textColor,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Invoice Tile ─────────────────────────────────────────────────────────────

class _InvoiceTile extends StatelessWidget {
  final InvoiceModel invoice;
  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final amount    = NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(invoice.amount);
    final parsedDate = DateTime.tryParse(invoice.dueDate);
    final dueDate   = parsedDate != null
        ? DateFormat('dd MMM, yyyy').format(parsedDate)
        : invoice.dueDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/invoices/${invoice.id}'),
          borderRadius: BorderRadius.circular(14),
          splashColor:  AppColors.primaryGlow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:        AppColors.primaryGlow,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.receipt_outlined,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        invoice.client.name,
                        style: const TextStyle(
                          color:      AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize:   14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vence $dueDate',
                        style: const TextStyle(
                          color:   AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(invoice.status),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          amount,
                          style: const TextStyle(
                            color:      AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize:   14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.borderStrong, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;
  const _EmptyState({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryGlow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin facturas aún',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crea tu primera factura para empezar\na enviar recordatorios automáticos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon:  const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nueva factura'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String   message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
