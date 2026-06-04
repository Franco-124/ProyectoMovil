import '../../core/supabase/supabase_client.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        final email = supabase.auth.currentUser?.email ?? 'user@ebike.com';
        final newProfile = {
          'id': userId,
          'full_name': email.split('@').first.toUpperCase(),
          'user_level': 'Premium Member',
          'rating': 4.90,
        };
        await supabase.from('profiles').insert(newProfile);
        return newProfile;
      }
      return Map<String, dynamic>.from(response);
    } catch (e) {
      final email = supabase.auth.currentUser?.email ?? 'user@ebike.com';
      return {
        'id': userId,
        'full_name': email.split('@').first.toUpperCase(),
        'user_level': 'Premium Member',
        'rating': 4.90,
      };
    }
  }
}
