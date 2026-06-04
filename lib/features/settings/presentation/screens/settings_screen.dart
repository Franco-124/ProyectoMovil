import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _mockEmailNotifications = true;
  bool _mockPushNotifications = false;

  void _showMockDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (e, _) => Center(child: Text('Error al cargar perfil: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Sesión no encontrada. Por favor, inicia sesión de nuevo.'));
          }

          final createdDate = DateFormat('dd MMMM, yyyy').format(user.createdAt);
          final isPro = user.plan.toLowerCase() == 'pro';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User profile header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
                        child: Text(
                          user.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPro 
                                    ? const Color(0xFF22C55E).withOpacity(0.15) 
                                    : const Color(0xFF64748B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPro 
                                      ? const Color(0xFF22C55E).withOpacity(0.3) 
                                      : const Color(0xFF64748B).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPro ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 14,
                                    color: isPro ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPro ? 'Plan PRO Activo' : 'Plan Free',
                                    style: TextStyle(
                                      color: isPro ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Plan & Billing Section
              const Text(
                'FACTURACIÓN Y PLAN',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.credit_card_rounded, color: Color(0xFF6366F1)),
                      title: const Text('Detalles de Suscripción'),
                      subtitle: Text(
                        isPro 
                            ? 'Facturación mensual activa' 
                            : 'Límite de 3 clientes activos en plan gratuito',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF475569)),
                      onTap: () => _showMockDialog(
                        'Facturación', 
                        isPro 
                            ? 'Tu plan PRO se encuentra al día. Facturado a través de Railway/Stripe.'
                            : 'Estás utilizando el plan Free. Puedes registrar hasta 3 clientes y 5 facturas.',
                      ),
                    ),
                    if (!isPro) ...[
                      const Divider(color: Color(0xFF334155), height: 1),
                      ListTile(
                        leading: const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B)),
                        title: const Text('Mejorar a Plan PRO', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                        subtitle: const Text('Clientes ilimitados, recordatorios por WhatsApp y plantillas personalizadas.', style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFF59E0B)),
                        onTap: () => _showMockDialog(
                          'Upgrade a PRO', 
                          '¡Excelente elección! Esta funcionalidad te redirigirá a Stripe Checkout en producción para activar tu plan PRO.',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notification Preferences
              const Text(
                'PREFERENCIAS DE NOTIFICACIÓN',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.email_outlined, color: Color(0xFF6366F1)),
                      title: const Text('Notificar por Correo'),
                      subtitle: const Text('Recibe un correo cuando un cliente reciba un recordatorio.', style: TextStyle(fontSize: 12)),
                      value: _mockEmailNotifications,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) {
                        setState(() {
                          _mockEmailNotifications = val;
                        });
                      },
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.phonelink_ring_rounded, color: Color(0xFF6366F1)),
                      title: const Text('Notificaciones Push'),
                      subtitle: const Text('Notificaciones en tu dispositivo móvil al cambiar el estado de facturas.', style: TextStyle(fontSize: 12)),
                      value: _mockPushNotifications,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) {
                        setState(() {
                          _mockPushNotifications = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account & Meta info Section
              const Text(
                'CUENTA',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B)),
                      title: const Text('Fecha de registro'),
                      trailing: Text(createdDate, style: const TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                      title: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                      onTap: () async {
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
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
