import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

/// Scaffold with Bottom Navigation Bar
/// Used with ShellRoute for persistent bottom navigation
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventaire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Recettes',
          ),
        ],
      ),
    );
  }

  /// Calculate which tab is currently selected based on current route
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppRoutes.inventory)) {
      return 0;
    }
    if (location.startsWith(AppRoutes.dashboard)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.recipes)) {
      return 2;
    }

    return 0; // Default to inventory
  }

  /// Handle bottom navigation tap
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.inventory);
        break;
      case 1:
        context.go(AppRoutes.dashboard);
        break;
      case 2:
        context.go(AppRoutes.recipes);
        break;
    }
  }
}
