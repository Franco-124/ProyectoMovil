import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bike_repository.dart';

final bikesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return BikeRepository().getAvailableBikes();
});
