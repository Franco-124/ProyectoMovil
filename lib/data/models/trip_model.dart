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
}
