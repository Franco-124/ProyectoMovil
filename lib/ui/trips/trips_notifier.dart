import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/repositories/trip_repository.dart';
import 'trips_state.dart';

class TripsNotifier extends StateNotifier<TripsState> {
  final TripRepository _repo;
  TripsNotifier(this._repo) : super(const TripsIdle()) {
    _load();
  }

  Future<void> _load() async {
    state = const TripsLoading();
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      state = const TripsError('Usuario no autenticado.');
      return;
    }

    try {
      final list = await _repo.getTrips(userId);
      state = TripsSuccess(list);
    } catch (e) {
      state = TripsError(e.toString());
    }
  }
}

final tripsProvider = StateNotifierProvider.autoDispose<TripsNotifier, TripsState>(
  (ref) => TripsNotifier(TripRepository()),
);
