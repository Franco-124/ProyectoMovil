class RideScheduleModel {
  final DateTime date;
  final String timeSlot;
  final String duration;
  final String? pickupLocation;

  const RideScheduleModel({
    required this.date,
    required this.timeSlot,
    required this.duration,
    this.pickupLocation,
  });
}
