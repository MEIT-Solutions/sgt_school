import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';

/// Role-aware bottom navigation shell.
///
/// Wraps the active tab body with a [NavigationBar] whose destinations
/// change based on the logged-in user's [UserRole].
class AppShell extends StatelessWidget {
  final int currentIndex;
  final Widget child;
  final ValueChanged<int> onTabChanged;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final role = session.user?.role ?? UserRole.student;
    final destinations = _getDestinations(role);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabChanged,
        destinations: destinations,
      ),
    );
  }

  List<NavigationDestination> _getDestinations(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: 'home.home_title'.tr()),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: 'profile.title'.tr()),
        ];
      case UserRole.parent:
        return [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: 'home.home_title'.tr()),
          NavigationDestination(
              icon: const Icon(Icons.family_restroom_outlined),
              selectedIcon: const Icon(Icons.family_restroom),
              label: 'children.title'.tr()),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: 'profile.title'.tr()),
        ];
      case UserRole.teacher:
        return [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: 'home.home_title'.tr()),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: 'profile.title'.tr()),
        ];
    }
  }
}
