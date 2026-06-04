import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/email_provider.dart';
import '../../data/models/email_log_model.dart';

class EmailsScreen extends ConsumerWidget {
  const EmailsScreen({super.key});

  void _showEmailContentDialog(BuildContext context, EmailLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          log.subject ?? 'Sin Asunto',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Para: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    Expanded(
                      child: Text(
                        '${log.client.name} (${log.client.email})',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Tono: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    Text(log.toneLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Text('Días vencidos: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    Text('${log.reminderDay}d', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const Divider(color: Color(0xFF334155), height: 24),
                const Text('MENSAJE ENVIADO:', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(
                  log.body ?? 'Sin cuerpo del mensaje.',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.4),
                ),
                if (log.errorMessage != null && log.errorMessage!.isNotEmpty) ...[
                  const Divider(color: Color(0xFF334155), height: 24),
                  const Text('DETALLE DEL ERROR:', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(emailLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Correos'),
      ),
      body: logsAsync.when(
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
                  'Error al cargar historial: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFF87171)),
                ),
                const SizedBox(height: 16),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined, color: Color(0xFF64748B), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin correos enviados',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Cuando el sistema envíe recordatorios automáticos o manuales, verás los registros reales aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort logs by sent date descending
          final sortedLogs = List<EmailLogModel>.from(logs)
            ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

          return RefreshIndicator(
            color: const Color(0xFF6366F1),
            onRefresh: () => ref.refresh(emailLogsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedLogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = sortedLogs[index];
                final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(log.sentAt);

                Color badgeBg;
                Color badgeText;
                String statusLabel;

                switch (log.status.toLowerCase()) {
                  case 'opened':
                    statusLabel = 'Abierto';
                    badgeBg = const Color(0xFFDCFCE7);
                    badgeText = const Color(0xFF166534);
                    break;
                  case 'failed':
                    statusLabel = 'Fallido';
                    badgeBg = const Color(0xFFFEE2E2);
                    badgeText = const Color(0xFF991B1B);
                    break;
                  case 'sent':
                  default:
                    statusLabel = 'Enviado';
                    badgeBg = const Color(0xFFE0F2FE);
                    badgeText = const Color(0xFF0369A1);
                    break;
                }

                return Card(
                  child: InkWell(
                    onTap: () => _showEmailContentDialog(context, log),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Recordatorio - ${log.reminderDay}d (${log.toneLabel})',
                                  style: const TextStyle(color: Color(0xFF818CF8), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: badgeText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            log.subject ?? 'Sin Asunto',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Destinatario: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              Expanded(
                                child: Text(
                                  '${log.client.name} (${log.client.email})',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Factura: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              Text(
                                '#${log.invoice.invoiceNumber} (\$${log.invoice.amount.toStringAsFixed(2)} ${log.invoice.currency})',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          if (log.errorMessage != null && log.errorMessage!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.error_outline, size: 14, color: Color(0xFFEF4444)),
                                const SizedBox(width: 6),
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
                          const Divider(color: Color(0xFF334155), height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Ver correo completo',
                                    style: TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.open_in_new_rounded, color: Color(0xFF6366F1), size: 12),
                                ],
                              ),
                              Text(
                                formattedTime,
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
