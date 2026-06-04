import '../../core/supabase/supabase_client.dart';
import '../models/trip_model.dart';

class TripRepository {
  Future<List<TripModel>> getTrips(String userId) async {
    try {
      final response = await supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback
      return [
        const TripModel(id:'1', date:'22 Oct 2023', origin:'Av. Principal 123',    destination:'Calle Luna 456',       cost:12.00, status:'COMPLETED'),
        const TripModel(id:'2', date:'20 Oct 2023', origin:'Parque Central',       destination:'Centro Comercial',     cost:8.50,  status:'COMPLETED'),
        const TripModel(id:'3', date:'18 Oct 2023', origin:'Estación Norte',       destination:'Aeropuerto',           cost:25.00, status:'CANCELLED'),
        const TripModel(id:'4', date:'15 Oct 2023', origin:'Plaza Mayor',          destination:'Biblioteca Nacional',  cost:5.00,  status:'COMPLETED'),
      ];
    }
  }

  Future<void> startTrip(String userId, String bikeId, String origin) async {
    await supabase.from('trips').insert({
      'user_id': userId,
      'bike_id': bikeId,
      'origin': origin,
      'status': 'PENDING',
      'cost': 0.00,
    });

    await supabase.from('bikes').update({
      'status': 'RENTED',
    }).eq('id', bikeId);
  }

  Future<void> endTrip(String tripId, String bikeId, String destination, double cost) async {
    await supabase.from('trips').update({
      'destination': destination,
      'cost': cost,
      'status': 'COMPLETED',
      'end_time': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', tripId);

    await supabase.from('bikes').update({
      'status': 'AVAILABLE',
    }).eq('id', bikeId);
  }
}
