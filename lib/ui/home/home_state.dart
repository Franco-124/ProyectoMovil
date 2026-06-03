sealed class HomeState { const HomeState(); }
class HomeIdle              extends HomeState { const HomeIdle(); }
class HomeNavigateSchedule  extends HomeState { const HomeNavigateSchedule(); }
class HomeNavigateProfile   extends HomeState { const HomeNavigateProfile(); }
class HomeNavigateWallet    extends HomeState { const HomeNavigateWallet(); }
class HomeNavigateTrips     extends HomeState { const HomeNavigateTrips(); }
class HomeNavigateSupport   extends HomeState { const HomeNavigateSupport(); }
class HomeLogout            extends HomeState { const HomeLogout(); }
