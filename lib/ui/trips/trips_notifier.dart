import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_model.dart';
import 'trips_state.dart';

class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier() : super(const TripsIdle()) { _load(); }

  Future<void> _load() async {
    state = const TripsLoading();
    await Future.delayed(const Duration(milliseconds: 1200));
    state = const TripsSuccess([
      TripModel(id:'1', date:'22 Oct 2023', origin:'Av. Principal 123',    destination:'Calle Luna 456',       cost:12.00, status:'COMPLETED'),
      TripModel(id:'2', date:'20 Oct 2023', origin:'Parque Central',       destination:'Centro Comercial',     cost:8.50,  status:'COMPLETED'),
      TripModel(id:'3', date:'18 Oct 2023', origin:'Estación Norte',       destination:'Aeropuerto',           cost:25.00, status:'CANCELLED'),
      TripModel(id:'4', date:'15 Oct 2023', origin:'Plaza Mayor',          destination:'Biblioteca Nacional',  cost:5.00,  status:'COMPLETED'),
    ]);
  }
}

final tripsProvider = StateNotifierProvider.autoDispose<TripsNotifier, TripsState>(
  (ref) => TripsNotifier(),
);
