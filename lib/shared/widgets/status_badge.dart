import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  static const _config = {
    'pending':   ('Pendiente',  Color(0xFFFEF9C3), Color(0xFF854D0E)),
    'overdue':   ('Vencida',    Color(0xFFFEE2E2), Color(0xFF991B1B)),
    'paid':      ('Pagada',     Color(0xFFDCFCE7), Color(0xFF166534)),
    'cancelled': ('Cancelada',  Color(0xFFF1F5F9), Color(0xFF475569)),
  };

  @override
  Widget build(BuildContext context) {
    final (label, bg, text) = _config[status] ??
      ('Desconocido', Colors.grey.shade200, Colors.grey.shade800);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
