class TripModel {
  final String id;
  final String date;
  final String origin;
  final String destination;
  final double cost;
  final String status; // 'COMPLETED' | 'CANCELLED' | 'PENDING'

  const TripModel({
    required this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.cost,
    required this.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['start_time'] as String?;
    String formattedDate = '';
    if (rawDate != null) {
      try {
        final parsed = DateTime.parse(rawDate).toLocal();
        formattedDate = '${parsed.day} ${_getMonthName(parsed.month)} ${parsed.year}';
      } catch (_) {
        formattedDate = rawDate.split('T').first;
      }
    }

    return TripModel(
      id: json['id']?.toString() ?? '',
      date: formattedDate,
      origin: json['origin'] as String? ?? 'Origen Desconocido',
      destination: json['destination'] as String? ?? 'Destino Desconocido',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
    );
  }

  static String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
