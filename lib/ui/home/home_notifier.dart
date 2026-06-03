import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeIdle());

  void onUnlockPressed()   => state = const HomeNavigateSchedule();
  void onSchedulePressed() => state = const HomeNavigateSchedule();
  void onProfilePressed()  => state = const HomeNavigateProfile();
  void onWalletPressed()   => state = const HomeNavigateWallet();
  void onTripsPressed()    => state = const HomeNavigateTrips();
  void onSupportPressed()  => state = const HomeNavigateSupport();
  void onLogoutPressed()   => state = const HomeLogout();
  void reset()             => state = const HomeIdle();
}

final homeProvider = StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
