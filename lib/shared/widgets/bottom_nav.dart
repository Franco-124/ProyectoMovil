import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;
  const BottomNavShell({super.key, required this.child});

  static const _destinations = [
    (path: '/dashboard', icon: Icons.dashboard_outlined,            activeIcon: Icons.dashboard_rounded,              label: 'Inicio'),
    (path: '/invoices',  icon: Icons.receipt_long_outlined,         activeIcon: Icons.receipt_long_rounded,           label: 'Facturas'),
    (path: '/clients',   icon: Icons.people_outline_rounded,        activeIcon: Icons.people_rounded,                 label: 'Clientes'),
    (path: '/emails',    icon: Icons.mark_email_unread_outlined,    activeIcon: Icons.mark_email_read_rounded,        label: 'Correos'),
    (path: '/finance',   icon: Icons.account_balance_wallet_outlined,activeIcon: Icons.account_balance_wallet_rounded, label: 'Finanzas'),
    (path: '/settings',  icon: Icons.settings_outlined,             activeIcon: Icons.settings_rounded,               label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) {
        currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ScaffoldMessenger.of(context).clearMaterialBanners();
            context.go(_destinations[index].path);
          },
          destinations: _destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.activeIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
