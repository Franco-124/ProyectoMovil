import '../../data/models/trip_model.dart';

sealed class TripsState { const TripsState(); }
class TripsIdle    extends TripsState { const TripsIdle(); }
class TripsLoading extends TripsState { const TripsLoading(); }
class TripsSuccess extends TripsState {
  final List<TripModel> trips;
  const TripsSuccess(this.trips);
}
class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
}
