import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import 'package:payremind/core/theme/app_colors.dart';
import '../providers/email_provider.dart';
import '../../data/models/email_log_model.dart';

class EmailsScreen extends ConsumerWidget {
  const EmailsScreen({super.key});

  static const _statusConfig = {
    'opened': ('Abierto', Color(0x2600D4A1), Color(0xFF2DD4BF)),
    'failed': ('Fallido', Color(0x26F05060), Color(0xFFF87171)),
    'sent':   ('Enviado', Color(0x267B5CF5), Color(0xFF9E82FF)),
  };

  void _showEmailContentDialog(BuildContext context, EmailLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log.subject ?? 'Sin Asunto'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MetaRow(label: 'Para', value: '${log.client.name} (${log.client.email})'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MetaRow(label: 'Tono', value: log.toneLabel),
                    const SizedBox(width: 20),
                    _MetaRow(label: 'Días vencidos', value: '${log.reminderDay}d'),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'MENSAJE ENVIADO',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  log.body ?? 'Sin cuerpo del mensaje.',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                ),
                if (log.errorMessage != null && log.errorMessage!.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'ERROR',
                    style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.7),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.errorMessage!,
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(emailLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Correos')),
      body: logsAsync.when(
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
                  onPressed: () => ref.refresh(emailLogsProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGlow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.primaryLight, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sin correos enviados',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los recordatorios automáticos y manuales aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = List<EmailLogModel>.from(logs)
            ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

          return RefreshIndicator(
            onRefresh: () => ref.refresh(emailLogsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _EmailCard(
                log: sorted[i],
                statusConfig: _statusConfig,
                onTap: () => _showEmailContentDialog(context, sorted[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Email Card ───────────────────────────────────────────────────────────────

class _EmailCard extends StatelessWidget {
  final EmailLogModel log;
  final Map<String, (String, Color, Color)> statusConfig;
  final VoidCallback onTap;

  const _EmailCard({
    required this.log,
    required this.statusConfig,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd MMM yyyy, hh:mm a').format(log.sentAt);
    final statusKey = log.status.toLowerCase();
    final (statusLabel, badgeBg, badgeFg) =
        statusConfig[statusKey] ?? ('Enviado', const Color(0x267B5CF5), AppColors.primaryLight);

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
                // ── Header row ───────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recordatorio ${log.reminderDay}d · ${log.toneLabel}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color:        badgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border:       Border.all(color: badgeFg.withOpacity(0.25)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color:      badgeFg,
                          fontSize:   10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Subject ──────────────────────────────────────────────
                Text(
                  log.subject ?? 'Sin Asunto',
                  style: const TextStyle(
                    color:      AppColors.textPrimary,
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // ── Meta ─────────────────────────────────────────────────
                _MetaRow(
                  label: 'Para',
                  value: '${log.client.name} · ${log.client.email}',
                ),
                const SizedBox(height: 4),
                _MetaRow(
                  label: 'Factura',
                  value: '#${log.invoice.invoiceNumber} · \$${log.invoice.amount.toStringAsFixed(0)} ${log.invoice.currency}',
                ),

                if (log.errorMessage != null && log.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 13, color: AppColors.error),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          log.errorMessage!,
                          style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const Divider(height: 20),

                // ── Footer ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Ver correo completo',
                          style: TextStyle(
                            color:      AppColors.primary,
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.open_in_new_rounded, color: AppColors.primary, size: 12),
                      ],
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
