import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/trip_model.dart';
import 'trips_notifier.dart';
import 'trips_state.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Previous Trips',
            style: TextStyle(color: AppColors.textWhite)),
      ),
      body: switch (state) {
        TripsLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        TripsSuccess(:final trips) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: trips.length,
          itemBuilder: (_, i) => _TripCard(trips[i]),
        ),
        TripsError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard(this.trip);

  Color get _statusColor => switch (trip.status) {
    'COMPLETED' => AppColors.statusCompleted,
    'CANCELLED' => AppColors.statusCancelled,
    _           => AppColors.statusPending,
  };

  String get _statusLabel => switch (trip.status) {
    'COMPLETED' => 'Completado',
    'CANCELLED' => 'Cancelado',
    _           => 'Pendiente',
  };

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(trip.date, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_statusLabel,
              style: TextStyle(color: _statusColor, fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.radio_button_checked, color: AppColors.accentTeal, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(trip.origin,
            style: const TextStyle(color: AppColors.textWhite))),
      ]),
      Padding(
        padding: const EdgeInsets.only(left: 7),
        child: Container(height: 16, width: 1, color: AppColors.textGray),
      ),
      Row(children: [
        const Icon(Icons.location_on, color: AppColors.accentBlue, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(trip.destination,
            style: const TextStyle(color: AppColors.textWhite))),
      ]),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight,
          child: Text('\$${trip.cost}',
              style: const TextStyle(color: AppColors.textWhite,
                  fontWeight: FontWeight.bold, fontSize: 16))),
    ]),
  );
}
