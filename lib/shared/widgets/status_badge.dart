import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  static const _config = {
    'pending':   ('Pendiente', AppColors.pendingBg,   AppColors.pendingFg),
    'overdue':   ('Vencida',   AppColors.overdueBg,   AppColors.overdueFg),
    'paid':      ('Pagada',    AppColors.paidBg,      AppColors.paidFg),
    'cancelled': ('Cancelada', AppColors.cancelledBg, AppColors.cancelledFg),
  };

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _config[status] ??
        ('Desconocido', AppColors.cancelledBg, AppColors.cancelledFg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
