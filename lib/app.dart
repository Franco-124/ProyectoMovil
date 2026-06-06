import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/invoices/presentation/screens/invoices_screen.dart';
import 'features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'features/invoices/presentation/screens/create_invoice_screen.dart';
import 'features/invoices/presentation/screens/invoice_emit_screen.dart';
import 'features/clients/presentation/screens/clients_screen.dart';
import 'features/emails/presentation/screens/emails_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/finance/presentation/screens/financial_dashboard_screen.dart';
import 'features/finance/presentation/screens/transactions_screen.dart';
import 'features/finance/presentation/screens/create_transaction_screen.dart';
import 'features/finance/presentation/screens/budgets_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'shared/widgets/bottom_nav.dart';
import 'shared/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/dashboard',
  refreshListenable: authStateListenable,
  redirect: (context, state) {
    // No inicializado aún → no redirigir (splash/loading state)
    if (!authStateListenable.isInitialized) return null;

    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    if (!authStateListenable.isAuthenticated && !isAuthRoute) return '/auth/login';
    if (authStateListenable.isAuthenticated && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/login',
      pageBuilder: (_, __) => const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/auth/register',
      pageBuilder: (_, __) => const NoTransitionPage(child: RegisterScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => BottomNavShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(
          path: '/invoices',
          builder: (_, __) => const InvoicesScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (_, __) => const CreateInvoiceScreen(),
            ),
            GoRoute(
              path: 'emit',
              builder: (_, __) => const InvoiceEmitScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => InvoiceDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
        GoRoute(path: '/emails', builder: (_, __) => const EmailsScreen()),
        GoRoute(
          path: '/finance',
          builder: (_, __) => const FinancialDashboardScreen(),
          routes: [
            GoRoute(
              path: 'transactions',
              builder: (_, __) => const TransactionsScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (_, __) => const CreateTransactionScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'budgets',
              builder: (_, __) => const BudgetsScreen(),
            ),
          ],
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);

class PayRemindApp extends ConsumerWidget {
  const PayRemindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'PayRemind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
