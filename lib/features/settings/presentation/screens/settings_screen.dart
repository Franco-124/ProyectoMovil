import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:payremind/core/network/error_handler.dart';
import 'package:payremind/core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = false;

  void _showInfoDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              ErrorHandler.getFriendlyMessage(e),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Sesión no encontrada. Inicia sesión de nuevo.'),
            );
          }

          final createdDate = DateFormat('dd MMMM, yyyy').format(user.createdAt);
          final isPro       = user.plan.toLowerCase() == 'pro';
          final initial     = user.fullName.substring(0, 1).toUpperCase();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Profile Card ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:        AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize:   26,
                            fontWeight: FontWeight.w800,
                            color:      Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize:   18,
                              fontWeight: FontWeight.w700,
                              color:      AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _PlanBadge(isPro: isPro),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Billing ─────────────────────────────────────────────────
              const _SectionLabel('FACTURACIÓN Y PLAN'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color:        AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon:    Icons.credit_card_rounded,
                      iconColor: AppColors.primary,
                      title:   'Detalles de Suscripción',
                      subtitle: isPro ? 'Facturación mensual activa' : 'Hasta 3 clientes en plan gratuito',
                      onTap: () => _showInfoDialog(
                        'Facturación',
                        isPro
                            ? 'Tu plan PRO se encuentra al día.'
                            : 'Estás en el plan Free. Registra hasta 3 clientes y 5 facturas.',
                      ),
                    ),
                    if (!isPro) ...[
                      const Divider(indent: 16, endIndent: 16),
                      _SettingsTile(
                        icon:    Icons.bolt_rounded,
                        iconColor: AppColors.warning,
                        title:   'Mejorar a Plan PRO',
                        titleStyle: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 14),
                        subtitle: 'Clientes ilimitados, WhatsApp y plantillas personalizadas.',
                        trailingColor: AppColors.warning,
                        onTap: () => _showInfoDialog(
                          'Upgrade a PRO',
                          'Te redirigirá a Stripe Checkout para activar el plan PRO.',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Notifications ────────────────────────────────────────────
              const _SectionLabel('NOTIFICACIONES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color:        AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.borderDefault),
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phonelink_ring_rounded, color: AppColors.primaryLight, size: 18),
                  ),
                  title:    const Text('Notificaciones Push'),
                  subtitle: const Text('Alertas al cambiar el estado de facturas.'),
                  value:    _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
              ),
              const SizedBox(height: 28),

              // ── Account ──────────────────────────────────────────────────
              const _SectionLabel('CUENTA'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color:        AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20),
                      title: const Text('Fecha de registro'),
                      trailing: Text(
                        createdDate,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      ),
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  final bool isPro;
  const _PlanBadge({required this.isPro});

  @override
  Widget build(BuildContext context) {
    final color = isPro ? AppColors.income : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPro ? Icons.star_rounded : Icons.star_border_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            isPro ? 'Plan PRO' : 'Plan Free',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color:       AppColors.textMuted,
          fontSize:    11,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.7,
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData   icon;
  final Color      iconColor;
  final String     title;
  final TextStyle? titleStyle;
  final String?    subtitle;
  final Color      trailingColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.trailingColor = AppColors.textMuted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: titleStyle),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: trailingColor, size: 20),
      onTap: onTap,
    );
  }
}
