import 'package:go_router/go_router.dart';
import '../../ui/home/home_screen.dart';

abstract class AppRoutes {
  static const home = '/';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (_, __) => const HomeScreen(),
    ),
  ],
);
