import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_client.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    _loadUser();
  }

  void _loadUser() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final email = user.email ?? 'user@ebike.com';
      final name = email.split('@').first.toUpperCase();
      state = ProfileState(
        userName: name,
        userEmail: email,
        tripsCount: '42',
        totalDistance: '156.4',
        userLevel: 'Premium Member',
        co2Saved: '12kg',
        userRating: '4.9',
      );
    }
  }
}

final profileProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
