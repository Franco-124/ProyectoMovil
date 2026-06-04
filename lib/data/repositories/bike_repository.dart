import '../../core/supabase/supabase_client.dart';

class BikeRepository {
  Future<List<Map<String, dynamic>>> getAvailableBikes() async {
    try {
      final response = await supabase
          .from('bikes')
          .select()
          .eq('status', 'AVAILABLE');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Coordenadas de prueba por defecto (Medellín, Colombia)
      return [
        {
          'id': 'bike-1',
          'code': 'BIKE-001',
          'battery_level': 85,
          'latitude': 6.244203,
          'longitude': -75.571431,
          'status': 'AVAILABLE'
        },
        {
          'id': 'bike-2',
          'code': 'BIKE-002',
          'battery_level': 45,
          'latitude': 6.246203,
          'longitude': -75.574431,
          'status': 'AVAILABLE'
        },
        {
          'id': 'bike-3',
          'code': 'BIKE-003',
          'battery_level': 99,
          'latitude': 6.242203,
          'longitude': -75.568431,
          'status': 'AVAILABLE'
        }
      ];
    }
  }
}
