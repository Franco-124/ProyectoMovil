import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/login/login_screen.dart';
import '../../ui/signup/signup_screen.dart';
import '../../ui/forgot_password/forgot_password_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/schedule/schedule_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/wallet/wallet_screen.dart';
import '../../ui/trips/trips_screen.dart';
import '../../ui/support/support_screen.dart';

// Rutas nombradas — equivalente a los IDs del nav_graph
abstract class AppRoutes {
  static const login          = '/login';
  static const signup         = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home           = '/home';
  static const schedule       = '/schedule';
  static const profile        = '/profile';
  static const wallet         = '/wallet';
  static const trips          = '/trips';
  static const support        = '/support';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = session != null;
    final onAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.signup ||
        state.matchedLocation == AppRoutes.forgotPassword;

    // Si no está autenticado y no está en ruta de auth → al login
    if (!isAuth && !onAuthRoute) return AppRoutes.login;
    // Si ya está autenticado y va al login o alguna ruta de auth → al home
    if (isAuth && onAuthRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.login,          builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.signup,         builder: (_, __) => const SignUpScreen()),
    GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: AppRoutes.home,           builder: (_, __) => const HomeScreen()),
    GoRoute(path: AppRoutes.schedule,       builder: (_, __) => const ScheduleScreen()),
    GoRoute(path: AppRoutes.profile,        builder: (_, __) => const ProfileScreen()),
    GoRoute(path: AppRoutes.wallet,         builder: (_, __) => const WalletScreen()),
    GoRoute(path: AppRoutes.trips,          builder: (_, __) => const TripsScreen()),
    GoRoute(path: AppRoutes.support,        builder: (_, __) => const SupportScreen()),
  ],
);
