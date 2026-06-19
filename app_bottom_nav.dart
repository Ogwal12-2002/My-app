import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Shared bottom nav bar for the three top-level destinations. Each screen
/// passes its own index; selecting a different tab navigates accordingly.
/// Scan is the root route, so selecting it pops back to root rather than
/// pushing a duplicate.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Navigator.of(context).popUntil((route) => route.isFirst);
            break;
          case 1:
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.history,
              (route) => route.isFirst,
            );
            break;
          case 2:
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.generator,
              (route) => route.isFirst,
            );
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'Generate'),
      ],
    );
  }
}
