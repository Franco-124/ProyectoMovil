import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/trip_repository.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepo;
  final TripRepository _tripRepo;

  ProfileNotifier(this._profileRepo, this._tripRepo) : super(const ProfileState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    state = const ProfileState(isLoading: true);
    try {
      final profile = await _profileRepo.getProfile(user.id);
      final trips = await _tripRepo.getTrips(user.id);

      final tripsCount = trips.length;
      final totalDistanceVal = tripsCount * 3.7; // Simulado: 3.7 km promedio por viaje
      final co2Val = totalDistanceVal * 0.12;     // Simulado: 0.12 kg de CO2 por km

      state = ProfileState(
        isLoading: false,
        userName: profile['full_name']?.toString() ?? user.email?.split('@').first.toUpperCase() ?? 'USER',
        userEmail: user.email ?? 'user@ebike.com',
        userLevel: profile['user_level']?.toString() ?? 'Member',
        userRating: (profile['rating'] as num?)?.toStringAsFixed(1) ?? '5.0',
        tripsCount: tripsCount.toString(),
        totalDistance: totalDistanceVal.toStringAsFixed(1),
        co2Saved: '${co2Val.toStringAsFixed(1)}kg',
      );
    } catch (e) {
      state = ProfileState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final profileProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ProfileRepository(), TripRepository()),
);
