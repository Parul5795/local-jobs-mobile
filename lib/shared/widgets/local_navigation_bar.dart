import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';

class LocalNavigationBar extends StatelessWidget {
  final int selectedIndex;
  const LocalNavigationBar({super.key, required this.selectedIndex});

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Ads'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.home);
        break;
      case 1:
        context.goNamed(RouteNames.localSearch);
        break;
      case 2:
        context.goNamed(RouteNames.localAds);
        break;
      case 3:
        context.goNamed(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    destinations: _destinations,
    onDestinationSelected: (index) => _go(context, index),
  );
}
