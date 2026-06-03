import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'home_notifier.dart';
import 'home_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen<HomeState>(homeProvider, (_, next) {
      switch (next) {
        case HomeNavigateSchedule():
          context.push(AppRoutes.schedule);
          ref.read(homeProvider.notifier).reset();
          break;
        case HomeNavigateProfile():
          context.push(AppRoutes.profile);
          ref.read(homeProvider.notifier).reset();
          break;
        case HomeNavigateWallet():
          context.push(AppRoutes.wallet);
          ref.read(homeProvider.notifier).reset();
          break;
        case HomeNavigateTrips():
          context.push(AppRoutes.trips);
          ref.read(homeProvider.notifier).reset();
          break;
        case HomeNavigateSupport():
          context.push(AppRoutes.support);
          ref.read(homeProvider.notifier).reset();
          break;
        case HomeLogout():
          context.go(AppRoutes.login);
          break;
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgNavy,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.textGray,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) ref.read(homeProvider.notifier).onSchedulePressed();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-BIKE RENTALS',
                          style: TextStyle(color: AppColors.accentTeal,
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Dashboard',
                          style: TextStyle(color: AppColors.textGray)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.textGray),
                        onPressed: () => ref.read(homeProvider.notifier).onLogoutPressed(),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(homeProvider.notifier).onProfilePressed(),
                        child: const CircleAvatar(
                          backgroundColor: AppColors.accentTeal,
                          child: Icon(Icons.person, color: AppColors.bgDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Unlock button
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock E-Bike'),
                onPressed: () => ref.read(homeProvider.notifier).onUnlockPressed(),
              ),
              const SizedBox(height: 32),

              // Grid de acciones
              const Text('Find a Ride',
                  style: TextStyle(color: AppColors.textWhite,
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: Icons.history,
                    label: 'Previous\nTrips',
                    onTap: () => ref.read(homeProvider.notifier).onTripsPressed(),
                  ),
                  _ActionButton(
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    onTap: () => ref.read(homeProvider.notifier).onWalletPressed(),
                  ),
                  _ActionButton(
                    icon: Icons.support_agent,
                    label: 'Support',
                    onTap: () => ref.read(homeProvider.notifier).onSupportPressed(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accentTeal, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 11)),
        ],
      ),
    ),
  );
}
