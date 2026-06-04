import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'bikes_provider.dart';
import 'home_notifier.dart';
import 'home_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikesAsync = ref.watch(bikesProvider);

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
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),

              // Unlock button
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock E-Bike'),
                onPressed: () => ref.read(homeProvider.notifier).onUnlockPressed(),
              ),
              const SizedBox(height: 24),

              // Interactive E-Bike Map
              const Text('Nearby E-Bikes',
                  style: TextStyle(color: AppColors.textWhite,
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: bikesAsync.when(
                    data: (bikes) => FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(6.244203, -75.571431),
                        initialZoom: 14.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.clase21.ebike_rentals',
                        ),
                        MarkerLayer(
                          markers: bikes.map((bike) {
                            final lat = (bike['latitude'] as num).toDouble();
                            final lng = (bike['longitude'] as num).toDouble();
                            return Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showBikeDetails(context, bike, ref),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentTeal,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.directions_bike,
                                    color: AppColors.bgDark,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accentTeal),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error al cargar mapa: $err',
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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

  void _showBikeDetails(BuildContext context, Map<String, dynamic> bike, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final battery = bike['battery_level'] as int;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bike['code'] as String? ?? 'E-BIKE',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        battery > 50 ? Icons.battery_charging_full : Icons.battery_alert,
                        color: battery > 20 ? AppColors.statusCompleted : AppColors.statusCancelled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$battery%',
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Costo base: \$1.50 + \$0.15/min',
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Bicicleta ${bike['code']} desbloqueada! Viaje iniciado.'),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                },
                child: const Text('DESBLOQUEAR Y COMENZAR VIAJE'),
              ),
            ],
          ),
        );
      },
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
