import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile', style: TextStyle(color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textGray),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon'))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + nombre
            const CircleAvatar(radius: 48,
                backgroundColor: AppColors.accentTeal,
                child: Icon(Icons.person, size: 48, color: AppColors.bgDark)),
            const SizedBox(height: 12),
            Text(state.userName,
                style: const TextStyle(color: AppColors.textWhite,
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(state.userLevel,
                style: const TextStyle(color: AppColors.accentTeal)),
            Text(state.userEmail,
                style: const TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _StatCard(label: 'Total Trips', value: state.tripsCount),
                _StatCard(label: 'Distance (km)', value: state.totalDistance),
                _StatCard(label: 'CO₂ Saved', value: state.co2Saved),
                _StatCard(label: 'Rating', value: state.userRating),
              ],
            ),
            const SizedBox(height: 24),

            // Opciones
            _ProfileOption(icon: Icons.person, label: 'Personal Info',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Personal Info')))),
            _ProfileOption(icon: Icons.payment, label: 'Payment Methods',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Methods')))),
            _ProfileOption(icon: Icons.notifications, label: 'Notifications',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification Settings')))),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value, style: const TextStyle(color: AppColors.accentTeal,
          fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
    ]),
  );
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.accentTeal),
    title: Text(label, style: const TextStyle(color: AppColors.textWhite)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textGray),
    onTap: onTap,
  );
}
